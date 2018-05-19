import 'package:flutter/material.dart';
import 'dart:math';
import 'four_in_a_vector.dart';

const Color FrameColor = Color(0xff416ff1);
const Color FrameHighlightColor = Color(0xff33ff33);
const Color FrameColorEdges = Color(0xff233b80);
const Color RedChipColor = Color(0xfff14155);
const Color YellowChipColor = Color(0xfff1e741);


class BoardPainter extends CustomPainter {

  int lastGameChangeCount;
  int rows;
  int columns;
  FourInAVector game;

  double minPadding = 4.0;
  Color frameColor = FrameColor;
  Color frameEdgeColor = FrameColorEdges;
  Color frameHighlight = FrameHighlightColor;
  Color chipColor = RedChipColor;

  List<Rect> columnRects;

  BoardPainter( this.rows, this.columns, this.game ) {
    columnRects = List<Rect>();
  }


  int tapToColumns( Offset o ) {
    for (int i=0;i< columnRects.length; i++){
      if ( columnRects[i].contains(o)) {
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

    for (int row = -1; row < rows; row++) {
      for (int column = 0; column < columns; column++) {

        Offset cellOffset = Offset(
          ( column ) * columnWidth,
          ( row + 1 ) * rowHeight
        );

        Rect cellRect = cellOffset & cell;

        if (row == -1) {
          if (game.state!=null) {
            if (game.validDrop(column)) {
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
    return false;
  }

  @override
  bool shouldRebuildSemantics(BoardPainter oldDelegate) => false;

}
typedef void ColumnTappedCB(int column) ;

class GameBoard extends StatefulWidget {

  final FourInAVector game;
  final ColumnTappedCB onTapped;

  GameBoard({
    this.game,
    this.onTapped
  });

  @override
  GameBoardState createState() => GameBoardState(game, onTapped);
}


class GameBoardState extends State<GameBoard> {

  int _rows;
  int _columns;
  final FourInAVector game;
  final ColumnTappedCB onTapped;

  GameBoardState(this.game, this.onTapped) {
    this._columns = game.columns;
    this._rows = game.rows;
  }

  @override
  Widget build(BuildContext context) {

    var bp = BoardPainter(_rows, _columns, game);

    return CustomPaint(
      child: GestureDetector (
        onTapUp: (TapUpDetails d) {
          final RenderBox referenceBox = context.findRenderObject();
          var pos = referenceBox.globalToLocal(d.globalPosition);
          var col = bp.tapToColumns(pos);
          if ( onTapped != null ) {
            onTapped(col);
          }
        },
      ),
      painter: bp,
    );
  }
}
