import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class StarfieldPainter extends CustomPainter {
  StarfieldPainter({
    required this.color,
    this.starCount = 200,
    this.brightness = Brightness.dark,
  });

  final Color color;
  final int starCount;
  final Brightness brightness;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < starCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.2 + 0.3;
      final opacity = random.nextDouble() * 0.5 + 0.15;
      paint.color = color.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    final brightCount = (starCount * 0.08).toInt().clamp(5, 20);
    for (int i = 0; i < brightCount; i++) {
      final cx = random.nextDouble() * size.width;
      final cy = random.nextDouble() * size.height;
      final center = Offset(cx, cy);

      final glowRadius = random.nextDouble() * 20 + 10;
      final glowPaint = Paint()
        ..shader = ui.Gradient.radial(
          center,
          glowRadius,
          [color.withOpacity(0.15), color.withOpacity(0.0)],
        );
      canvas.drawCircle(center, glowRadius, glowPaint);

      paint.color = color.withOpacity(0.8);
      canvas.drawCircle(center, random.nextDouble() * 1.5 + 1.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StarfieldPainter old) =>
      old.color != color || old.starCount != starCount || old.brightness != brightness;
}
