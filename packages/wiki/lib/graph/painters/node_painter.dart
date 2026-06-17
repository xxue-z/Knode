import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/graph_node.dart';

class NodePainter {
  static void paintNode({
    required Canvas canvas,
    required V2GraphNode node,
    required Offset screenPos,
    bool isHighlighted = false,
  }) {
    final radius = node.size * node.scale;

    if (node.glow > 0 || isHighlighted) {
      final glowRadius = radius * (2.0 + (isHighlighted ? 0.5 : 0.0));
      final glowPaint = Paint()
        ..shader = ui.Gradient.radial(
          screenPos,
          glowRadius,
          [
            (node.gradientColors?.last ?? node.color ?? Colors.blue)
                .withOpacity(isHighlighted ? 0.4 : 0.2 * node.glow),
            Colors.transparent,
          ],
        );
      canvas.drawCircle(screenPos, glowRadius, glowPaint);
    }

    switch (node.type) {
      case V2NodeType.galaxy:
        _drawPlanet(canvas, screenPos, radius, node, isHighlighted);
      case V2NodeType.article:
        _drawRing(canvas, screenPos, radius, node, isHighlighted);
    }
  }

  static void _drawPlanet(
    Canvas canvas,
    Offset center,
    double radius,
    V2GraphNode node,
    bool isHighlighted,
  ) {
    final colors = node.gradientColors ??
        [Colors.blue.shade400, Colors.blue.shade800];
    final gradient = RadialGradient(colors: colors);
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );
    canvas.drawCircle(center, radius, paint);

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center + Offset(2, 2), radius * 0.8, shadowPaint);

    final borderPaint = Paint()
      ..color = isHighlighted ? Colors.amber : Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isHighlighted ? 3.0 : 1.0;
    canvas.drawCircle(center, radius, borderPaint);
  }

  static void _drawRing(
    Canvas canvas,
    Offset center,
    double radius,
    V2GraphNode node,
    bool isHighlighted,
  ) {
    final color = node.color ?? Colors.grey;

    final outerPaint = Paint()
      ..color = color.withOpacity(isHighlighted ? 0.6 : 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius < 12 ? 1.0 : 2.0;
    canvas.drawCircle(center, radius, outerPaint);

    if (radius > 8) {
      final innerPaint = Paint()
        ..color = color.withOpacity(isHighlighted ? 0.8 : 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius < 16 ? 1.0 : 1.5;
      canvas.drawCircle(center, radius * 0.65, innerPaint);
    }

    final fillPaint = Paint()
      ..color = color.withOpacity(isHighlighted ? 0.7 : 0.4);
    canvas.drawCircle(center, radius * 0.45, fillPaint);

    final borderPaint = Paint()
      ..color = isHighlighted ? Colors.amber : Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isHighlighted ? 2.0 : 0.5;
    canvas.drawCircle(center, radius * 0.45, borderPaint);
  }

  static void paintLabel({
    required Canvas canvas,
    required V2GraphNode node,
    required Offset screenPos,
    bool showLabel = true,
  }) {
    if (!showLabel) return;

    final textPainter = TextPainter(
      text: TextSpan(
        text: node.label,
        style: TextStyle(
          color: Colors.white,
          fontSize: node.type == V2NodeType.galaxy ? 14 : 11,
          fontWeight: node.type == V2NodeType.galaxy
              ? FontWeight.w600
              : FontWeight.w400,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      textDirection: ui.TextDirection.ltr,
      maxLines: 1,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        screenPos.dx - textPainter.width / 2,
        screenPos.dy + node.size * node.scale + 6,
      ),
    );

    if (node.tags.isNotEmpty) {
      final tagText = node.tags.take(2).join(', ');
      final tagPainter = TextPainter(
        text: TextSpan(
          text: tagText,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 9,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
        maxLines: 1,
      )..layout();

      tagPainter.paint(
        canvas,
        Offset(
          screenPos.dx - tagPainter.width / 2,
          screenPos.dy + node.size * node.scale + 6 + textPainter.height + 2,
        ),
      );
    }
  }
}
