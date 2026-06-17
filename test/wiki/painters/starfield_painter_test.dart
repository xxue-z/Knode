import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wiki/graph/painters/starfield_painter.dart';

void main() {
  group('StarfieldPainter', () {
    test('paints without error (smoke test)', () {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(800, 600);

      final painter = StarfieldPainter(
        color: Colors.white,
        starCount: 200,
        brightness: Brightness.dark,
      );

      painter.paint(canvas, size);
      final picture = recorder.endRecording();

      expect(picture, isNotNull);
    });

    test('shouldRepaint returns true when parameters change', () {
      final a = StarfieldPainter(
        color: Colors.white,
        starCount: 200,
        brightness: Brightness.dark,
      );
      final b = StarfieldPainter(
        color: Colors.blue,
        starCount: 100,
        brightness: Brightness.light,
      );

      expect(a.shouldRepaint(b), isTrue);
    });

    test('shouldRepaint returns false when parameters are same', () {
      final a = StarfieldPainter(
        color: Colors.white,
        starCount: 200,
        brightness: Brightness.dark,
      );
      final b = StarfieldPainter(
        color: Colors.white,
        starCount: 200,
        brightness: Brightness.dark,
      );

      expect(a.shouldRepaint(b), isFalse);
    });
  });
}
