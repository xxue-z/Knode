import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/graph_edge.dart';

class EdgePainter {
  static void paintEdge({
    required Canvas canvas,
    required Offset from,
    required Offset to,
    required V2GraphEdge edge,
  }) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(edge.opacity * edge.weight)
      ..strokeWidth = 1.0 + edge.weight
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    switch (edge.type) {
      case V2EdgeType.reference:
        _drawSolid(canvas, from, to, paint);
      case V2EdgeType.similarity:
        _drawDashed(canvas, from, to, paint);
      case V2EdgeType.cluster:
        _drawDotted(canvas, from, to, paint);
    }
  }

  static void _drawSolid(Canvas canvas, Offset from, Offset to, Paint paint) {
    canvas.drawLine(from, to, paint);
  }

  static void _drawDashed(Canvas canvas, Offset from, Offset to, Paint paint) {
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len == 0) return;
    const dashLen = 6.0;
    const gapLen = 4.0;
    final total = dashLen + gapLen;
    final count = (len / total).floor();
    for (int i = 0; i < count; i++) {
      final t1 = (i * total) / len;
      final t2 = (i * total + dashLen) / len;
      canvas.drawLine(
        Offset(from.dx + dx * t1, from.dy + dy * t1),
        Offset(from.dx + dx * t2, from.dy + dy * t2),
        paint,
      );
    }
  }

  static void _drawDotted(Canvas canvas, Offset from, Offset to, Paint paint) {
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len == 0) return;
    const spacing = 8.0;
    final count = (len / spacing).floor();
    paint.strokeWidth = 1.0;
    for (int i = 0; i <= count; i++) {
      final t = i / count;
      canvas.drawCircle(
        Offset(from.dx + dx * t, from.dy + dy * t),
        1.5,
        paint,
      );
    }
  }
}
