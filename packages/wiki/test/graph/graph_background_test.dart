import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wiki/utils/graph_theme.dart';

void main() {
  group('GraphBackground', () {
    test('light background first color is correct', () {
      expect(GraphTheme.lightBackground.first, equals(const Color(0xFFF5F7FA)));
    });

    test('dark background first color is correct', () {
      expect(GraphTheme.darkBackground.first, equals(const Color(0xFF0f0c29)));
    });

    test('dark star color has 50% opacity', () {
      expect(GraphTheme.darkStarColor.opacity, closeTo(0.5, 0.01));
    });

    test('background colors form a gradient (distinct colors)', () {
      final light = GraphTheme.lightBackground;
      expect(light[0], isNot(equals(light[2])));
      final dark = GraphTheme.darkBackground;
      expect(dark[0], isNot(equals(dark[2])));
    });

    test('getBackground returns exactly 3 colors', () {
      expect(GraphTheme.getBackground(Brightness.light).length, equals(3));
      expect(GraphTheme.getBackground(Brightness.dark).length, equals(3));
    });
  });
}
