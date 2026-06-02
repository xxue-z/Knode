import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:wiki/utils/offset_calculator.dart';

void main() {
  group('OffsetCalculator Tests', () {
    test('should calculate offsets for simple text', () {
      const text = 'Hello\nWorld';
      const style = TextStyle(fontSize: 14);
      const maxWidth = 200.0;

      final calculator = OffsetCalculator(
        text: text,
        style: style,
        maxWidth: maxWidth,
      );

      expect(calculator.text, equals(text));
      calculator.dispose();
    });

    test('should return position for valid offset', () {
      const text = 'Hello World';
      const style = TextStyle(fontSize: 14);
      const maxWidth = 200.0;

      final calculator = OffsetCalculator(
        text: text,
        style: style,
        maxWidth: maxWidth,
      );

      final result = calculator.offsetToPosition(5);

      expect(result, isNotNull);
      expect(result!.y, greaterThanOrEqualTo(0));
      expect(result.height, greaterThan(0));

      calculator.dispose();
    });

    test('should return null for invalid offset', () {
      const text = 'Hello';
      const style = TextStyle(fontSize: 14);
      const maxWidth = 200.0;

      final calculator = OffsetCalculator(
        text: text,
        style: style,
        maxWidth: maxWidth,
      );

      final result = calculator.offsetToPosition(100);

      expect(result, isNull);

      calculator.dispose();
    });

    test('should handle multi-line text', () {
      const text = 'Line 1\nLine 2\nLine 3';
      const style = TextStyle(fontSize: 14);
      const maxWidth = 200.0;

      final calculator = OffsetCalculator(
        text: text,
        style: style,
        maxWidth: maxWidth,
      );

      final result1 = calculator.offsetToPosition(0);
      final result2 = calculator.offsetToPosition(7);
      final result3 = calculator.offsetToPosition(14);

      expect(result1, isNotNull);
      expect(result2, isNotNull);
      expect(result3, isNotNull);

      calculator.dispose();
    });

    test('should handle empty text', () {
      const text = '';
      const style = TextStyle(fontSize: 14);
      const maxWidth = 200.0;

      final calculator = OffsetCalculator(
        text: text,
        style: style,
        maxWidth: maxWidth,
      );

      final result = calculator.offsetToPosition(0);

      expect(result, isNull);

      calculator.dispose();
    });
  });
}
