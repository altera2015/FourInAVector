import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'four_in_a_vector.dart';
import 'player.dart';
import 'dart:async';
import 'dart:ui';

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
  var _frameCache;
  Size  _frameCacheSize = Size(0.0, 0.0);
  int _frameStateCount;
  
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


  // turns out drawing this whole board during the chip
  // drop animation is too slow. So only redraw the board
  // onto an internal image if the state has changed,
  // otherwise just keep what we have and copy it to
  // the active canvas. Nice speedup.
  void _buildFrame( Size size ) {

    PictureRecorder recorder = PictureRecorder();
    Offset o = Offset(0.0,0.0);
    Rect cull = o & size;
    Canvas canvas = Canvas(recorder, cull);

    double columnWidth = size.width / columns;
    double rowHeight = size.height / ( rows + 1 );
    Size cell = Size(columnWidth, rowHeight);

    columnRects.clear();

    for (int row = -1; row < rows; row++) {
      for (int column = 0; column < columns; column++) {

        Offset cellOffset = Offset(
            ( column ) * columnWidth,
            ( row + 1 ) * rowHeight
        );

        if ( row == -1 ) {

          if (game.state != null && game.validDrop(column) && dropChip == null) {
            Size fullColumn = Size(columnWidth, size.height);
            columnRects.add(cellOffset & fullColumn);
          } else {
            columnRects.add(null);
          }

          continue;
        }




        Rect cellRect = cellOffset & cell;

        FourPlayer chip = game.cellState(row, column);
        FourPlayer decoration = game.cellDecoration(row, column);
        if ( chip == null ) {
          drawFrame(canvas, cellRect);
        } else {
          drawChip(canvas, cellRect, true, decoration!=null, _playerToChipColor(chip));
        }
        
      }
    }

    Picture p = recorder.endRecording();
    _frameCache = p.toImage(size.width.toInt(), size.height.toInt());
    _frameCacheSize = size;
    _frameStateCount = game.stateCount;
  }




  @override
  void paint(Canvas canvas, Size size ) {

    if ( _frameCache == null || _frameCacheSize != size || _frameStateCount != game.stateCount ) {
      _buildFrame(size);
    }
    
    double columnWidth = size.width / columns;
    double rowHeight = size.height / ( rows + 1 );
    Size cell = Size(columnWidth, rowHeight);

    if ( dropChip != null ) {
      Offset o = Offset( columnWidth * dropChip.column, dropChip.y * rowHeight * ( dropChip.row + 1 )  );
      Rect r = o & cell;
      drawChip(canvas, r, false, false, _playerToChipColor(dropChip.player));
    }


    // this could still be optimized into the cache. Just need to keep
    // track of state of top row and cached top row.
    int row = -1;
    for (int column = 0; column < columns; column++) {
      Offset cellOffset = Offset(
          (column) * columnWidth,
          (row + 1) * rowHeight
      );

      Rect cellRect = cellOffset & cell;

      if (game.state != null && game.validDrop(column) && dropChip == null) {
        drawChip(canvas, cellRect, false, false, _playerToChipColor(game.state));
      }

    }

    canvas.drawImage(_frameCache, Offset(0.0, 0.0), Paint());
  }

  @override
  bool shouldRepaint(BoardPainter oldDelegate) {
    if ( game.stateCount != lastGameChangeCount ) {
      lastGameChangeCount = game.stateCount;
      return true;
    }
    lastGameChangeCount = game.stateCount;
    return false;
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

  GameBoardState(this.game, this.players) {
    this._columns = game.columns;
    this._rows = game.rows;
  }

  bool tryDropChip(int column) {

    if ( game.validDrop(column) && dropChip==null ) {

      game.setMovePending(true);
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

  int _undoListenerKey;
  void _undoListener( List<dynamic> args ) {

    if ( _turnStream != null ) {
      _turnStream.cancel();
      _turnStream = null;
    }
    setState(() {
      nextTurn();
    });
  }

  void nextTurn() {

    if ( game.state == null ) {
      return;
    }

    Future<int> f = players[game.state].makeMove(game);

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

    _undoListenerKey = game.undoPublisher.sub(_undoListener);

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
            game.setMovePending(false);
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
    game.undoPublisher.unsub(_undoListenerKey);
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    if (dropChip != null && animation.status == AnimationStatus.forward) {
      dropChip.y = animation.value;
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
