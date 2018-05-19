import 'package:flutter/material.dart';
import 'dart:math';

const Color FrameColor = Color(0xff416ff1);
const Color FrameColorEdges = Color(0xff233b80);
const Color RedChipColor = Color(0xfff14155);
const Color YellowChipColor = Color(0xfff1e741);

class FramePainter extends CustomPainter {

  double minPadding = 4.0;
  Color color = FrameColor;
  Color edgeColor = FrameColorEdges;

  @override
  void paint(Canvas canvas, Size size) {
    
    var radius = ( min(size.width, size.height) / 2.0 ) - minPadding;

    Paint p = Paint();
    p.color = color;
    p.style = PaintingStyle.fill;

    List<Offset> points = List<Offset>();
    points.add(Offset(minPadding, size.height/2.0));
    points.add(Offset(0.0, size.height/2.0));
    points.add(Offset(0.0, 0.0));
    points.add(Offset(size.width, 0.0));
    points.add(Offset(size.width, size.height));
    points.add(Offset(0.0, size.height));
    points.add(Offset(0.0, size.height/2.0));
    points.add(Offset(minPadding, size.height/2.0));
    
    Path path = new Path();
    path.fillType = PathFillType.evenOdd;
    path.addPolygon(points, false);

    Rect circle = Rect.fromCircle(
        center: Offset(size.width/2.0, size.height/2.0),
        radius: radius
    );

    path.addArc(circle, -pi, 2*pi);
    path.close();
    canvas.drawPath(path, p);

    p.color = edgeColor;
    p.style = PaintingStyle.stroke;

    Rect r = Offset(0.0, 0.0) & size;
    canvas.drawRect(r, p);
  }

  @override
  bool shouldRepaint(FramePainter oldDelegate) => false;
  @override
  bool shouldRebuildSemantics(FramePainter oldDelegate) => false;

}


class ChipPainter extends CustomPainter {

  double minPadding = 4.0;
  Color color = RedChipColor;
  bool drawFrame = true;
  Color frameColor = FrameColor;
  Color frameEdgeColor = FrameColorEdges;

  ChipPainter( this.color, this.drawFrame);

  @override
  void paint(Canvas canvas, Size size) {

    var radius = ( min(size.width, size.height) / 2.0 ) - minPadding;
    var center = Offset(size.width/2.0, size.height/2.0);

    Paint p = Paint();

    if ( drawFrame ) {
      p.style = PaintingStyle.fill;
      p.color = frameColor;
      Rect r = Offset(0.0, 0.0) & size;
      canvas.drawRect(r, p);

      p.style = PaintingStyle.stroke;
      p.color = frameEdgeColor;
      canvas.drawRect(r, p);
    }

    p.style = PaintingStyle.fill;
    p.color = color;
    canvas.drawCircle(center, radius, p);

  }

  @override
  bool shouldRepaint(ChipPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(ChipPainter oldDelegate) => false;

}