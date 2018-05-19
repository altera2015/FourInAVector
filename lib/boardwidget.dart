import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'four_in_a_vector.dart';
import 'player.dart';
import 'dart:async';

const Color FrameColor = Color(0xff416ff1);
const Color FrameHighlightColor = Color(0xff33ff33);
const Color FrameColorEdges = Color(0xff233b80);
const Color RedChipColor = Color(0xfff14155);
const Color YellowChipColor = Color(0xfff1e741);

class DropChip {
  int column;
  int row;
  double y;
  FourPlayer player;
  DropChip(this.row, this.column, this.player);
}

class BoardPainter extends CustomPainter {

  int lastGameChangeCount;
  int rows;
  int columns;
  FourInAVector game;
  DropChip dropChip;



  double minPadding = 4.0;
  Color frameColor = FrameColor;
  Color frameEdgeColor = FrameColorEdges;
  Color frameHighlight = FrameHighlightColor;
  Color chipColor = RedChipColor;

  List<Rect> columnRects;

  BoardPainter( this.rows, this.columns, this.game, this.dropChip ) {
    columnRects = List<Rect>();
  }


  int tapToColumns( Offset o ) {
    for (int i=0;i< columnRects.length; i++){
      if ( columnRects[i] != null && columnRects[i].contains(o)) {
        return i;
      }
    }
    return null;
  }

  void drawFrame(Canvas canvas, Rect rect) {

    var radius = ( min(rect.width, rect.height) / 2.0 ) - minPadding;

    Paint p = Paint();
    p.color = frameColor;
    p.style = PaintingStyle.fill;

    List<Offset> points = List<Offset>();
    points.add(Offset(rect.left + minPadding, rect.top + rect.height/2.0));
    points.add(Offset(rect.left,              rect.top + rect.height/2.0));
    points.add(Offset(rect.left,              rect.top ));
    points.add(Offset(rect.left + rect.width, rect.top ));
    points.add(Offset(rect.left + rect.width, rect.top + rect.height));
    points.add(Offset(rect.left,              rect.top + rect.height));
    points.add(Offset(rect.left,              rect.top + rect.height/2.0));
    points.add(Offset(rect.left + minPadding, rect.top + rect.height/2.0));

    Path path = new Path();
    path.fillType = PathFillType.evenOdd;
    path.addPolygon(points, false);

    Rect circle = Rect.fromCircle(
        center: rect.center,
        radius: radius
    );

    path.addArc(circle, -pi, 2*pi);
    path.close();
    canvas.drawPath(path, p);

    p.color = frameEdgeColor;
    p.style = PaintingStyle.stroke;
    canvas.drawRect(rect, p);
  }

  void drawChip(Canvas canvas, Rect rect, bool drawFrame, bool highlightFrame, Color color) {

    var radius = ( min(rect.width, rect.height) / 2.0 ) - minPadding;
    var center = rect.center;

    Paint p = Paint();

    if ( drawFrame ) {
      p.style = PaintingStyle.fill;
      p.color = highlightFrame ? frameHighlight : frameColor;

      canvas.drawRect(rect, p);

      p.style = PaintingStyle.stroke;
      p.color = frameEdgeColor;
      canvas.drawRect(rect, p);
    }

    p.style = PaintingStyle.fill;
    p.color = color;
    canvas.drawCircle(center, radius, p);

  }

  Color _playerToChipColor( FourPlayer player ) {
    switch ( player ) {
      case FourPlayer.RED:
        return RedChipColor;
      case FourPlayer.YELLOW:
        return YellowChipColor;
      default:
        return Color(0);
    }
  }

  @override
  void paint(Canvas canvas, Size size ) {

    double columnWidth = size.width / columns;
    double rowHeight = size.height / ( rows + 1 );
    Size cell = Size(columnWidth, rowHeight);

    if ( dropChip != null ) {
      Offset o = Offset( columnWidth * dropChip.column, dropChip.y * rowHeight * ( dropChip.row + 1 )  );
      Rect r = o & cell;
      drawChip(canvas, r, false, false, _playerToChipColor(dropChip.player));
    }


    for (int row = -1; row < rows; row++) {
      for (int column = 0; column < columns; column++) {

        Offset cellOffset = Offset(
          ( column ) * columnWidth,
          ( row + 1 ) * rowHeight
        );

        Rect cellRect = cellOffset & cell;

        if (row == -1) {
          if (game.state!=null) {
            if (game.validDrop(column) && dropChip == null) {
              drawChip(canvas, cellRect, false, false, _playerToChipColor(game.state));
              columnRects.add(cellRect);
            } else {
              columnRects.add(null);
            }
          }
        } else {

          FourPlayer chip = game.cellState(row, column);
          FourPlayer decoration = game.cellDecoration(row, column);
          if ( chip == null ) {
            drawFrame(canvas, cellRect);
          } else {
            drawChip(canvas, cellRect, true, decoration!=null, _playerToChipColor(chip));
          }

        }
      }
    }
  }

  @override
  bool shouldRepaint(BoardPainter oldDelegate) {
    if ( game.changeCount != lastGameChangeCount ) {
      lastGameChangeCount = game.changeCount;
      return true;
    }
    lastGameChangeCount = game.changeCount;
    return true;
  }

  @override
  bool shouldRebuildSemantics(BoardPainter oldDelegate) => false;

}

class GameBoard extends StatefulWidget {

  static GameBoardState of(BuildContext context) => context.ancestorStateOfType(const TypeMatcher<GameBoardState>());

  final FourInAVector game;
  final Map<FourPlayer, Player> players;
  GameBoard({
    this.game,
    this.players
  });

  @override
  GameBoardState createState() => GameBoardState(game, players);
}


class GameBoardState extends State<GameBoard> with SingleTickerProviderStateMixin {

  int _rows;
  int _columns;
  Animation<double> animation;
  AnimationController controller;
  DropChip dropChip;

  final FourInAVector game;
  final Map<FourPlayer, Player> players;
  StreamSubscription<int> _turnStream;
  FourPlayer _turnStreamPlayer;

  GameBoardState(this.game, this.players) {
    this._columns = game.columns;
    this._rows = game.rows;
  }

  bool tryDropChip(int column) {

    if ( game.validDrop(column) && dropChip==null ) {

      setState( () {
        int row = game.findFreeRow(column);
        dropChip = DropChip(row, column, game.state);
        controller.reset();
        controller.forward();
      });

      return true;
    }

    return false;

  }

  void nextTurn() {

    if ( game.state == null ) {
      _turnStreamPlayer = null;
      return;
    }

    Future<int> f = players[game.state].makeMove(game);

    _turnStreamPlayer = game.state;
    _turnStream = f.asStream().listen((column){

      _turnStream.cancel();
      _turnStream = null;
      if ( column >= 0 ) {
        if (!tryDropChip(column)) {
          nextTurn();
        }
      }

    });
  }

  initState() {

    super.initState();
    controller = new AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    final CurvedAnimation curve = new CurvedAnimation(parent: controller, curve: Curves.bounceOut );
    animation = new Tween(begin: 0.0, end: 1.0).animate(curve)
      ..addListener(() {
        setState(() {
        });
      });

    animation.addStatusListener((AnimationStatus status){

      if ( status == AnimationStatus.completed ) {

        if ( dropChip != null ) {

          setState(() {
            game.dropPiece(dropChip.column);
            dropChip = null;
            nextTurn();
          });

        }

      }
    });

    nextTurn();
  }

  dispose() {
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    if (animation.status == AnimationStatus.forward) {
      dropChip.y = animation.value;
    }

    if ( game.state != _turnStreamPlayer ) {
      nextTurn();
    }

    var bp = BoardPainter(_rows, _columns, game, dropChip);

    return CustomPaint(
      child: GestureDetector(
        onTapUp: (TapUpDetails d) {
          final RenderBox referenceBox = context.findRenderObject();
          var pos = referenceBox.globalToLocal(d.globalPosition);
          var column = bp.tapToColumns(pos);

          if (column != null) {
            players[game.state].columnClicked(column);
          }
        },
      ),
      painter: bp,
    );
  }
}
