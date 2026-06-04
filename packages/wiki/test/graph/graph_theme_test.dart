import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wiki/utils/graph_theme.dart';

void main() {
  group('GraphTheme', () {
    test('each category has corresponding gradient colors', () {
      for (int i = 1; i <= 5; i++) {
        expect(GraphTheme.getGradientForCategory(i), isNotEmpty);
      }
    });

    test('unknown category returns default gradient', () {
      final defaultGradient = GraphTheme.getGradientForCategory(999);
      expect(defaultGradient, equals(GraphTheme.categoryGradients[1]));
    });

    test('light background contains three colors', () {
      expect(GraphTheme.lightBackground.length, equals(3));
    });

    test('dark background contains three colors', () {
      expect(GraphTheme.darkBackground.length, equals(3));
    });

    test('getBackground returns correct colors for brightness', () {
      final lightColors = GraphTheme.getBackground(Brightness.light);
      final darkColors = GraphTheme.getBackground(Brightness.dark);
      expect(lightColors, equals(GraphTheme.lightBackground));
      expect(darkColors, equals(GraphTheme.darkBackground));
    });

    test('getStarColor returns correct color for brightness', () {
      final lightStar = GraphTheme.getStarColor(Brightness.light);
      final darkStar = GraphTheme.getStarColor(Brightness.dark);
      expect(lightStar, equals(GraphTheme.lightStarColor));
      expect(darkStar, equals(GraphTheme.darkStarColor));
    });
  });
}