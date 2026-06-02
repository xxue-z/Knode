import 'package:flutter_test/flutter_test.dart';
import 'package:core/models/highlight_style.dart';
import 'package:flutter/material.dart';

void main() {
  group('HighlightStyle Model Tests', () {
    test('HighlightStyle should be created with default values', () {
      const style = HighlightStyle(
        color: Color(0xFFFFF59D),
      );

      expect(style.type, equals(HighlightType.background));
      expect(style.color, equals(const Color(0xFFFFF59D)));
      expect(style.opacity, equals(0.3));
    });

    test('HighlightStyle should be created with custom values', () {
      const style = HighlightStyle(
        type: HighlightType.underline,
        color: Color(0xFFE57373),
        opacity: 0.5,
      );

      expect(style.type, equals(HighlightType.underline));
      expect(style.color, equals(const Color(0xFFE57373)));
      expect(style.opacity, equals(0.5));
    });

    test('HighlightStyle should serialize to JSON correctly', () {
      const style = HighlightStyle(
        type: HighlightType.background,
        color: Color(0xFFFFF59D),
        opacity: 0.3,
      );

      final json = style.toJson();

      expect(json, contains('type'));
      expect(json, contains('color'));
      expect(json, contains('opacity'));
      expect(json, contains('"type":"bg"'));
    });

    test('HighlightStyle should deserialize from JSON correctly', () {
      const original = HighlightStyle(
        type: HighlightType.background,
        color: Color(0xFFFFF59D),
        opacity: 0.3,
      );

      final json = original.toJson();
      final deserialized = HighlightStyle.fromJson(json);

      expect(deserialized.type, equals(original.type));
      expect(deserialized.color, equals(original.color));
      expect(deserialized.opacity, equals(original.opacity));
    });

    test('HighlightStyle should deserialize underline type correctly', () {
      const original = HighlightStyle(
        type: HighlightType.underline,
        color: Color(0xFFE57373),
        opacity: 0.5,
      );

      final json = original.toJson();
      final deserialized = HighlightStyle.fromJson(json);

      expect(deserialized.type, equals(HighlightType.underline));
    });

    test('HighlightStyle should return default on invalid JSON', () {
      final deserialized = HighlightStyle.fromJson('invalid json');

      expect(deserialized.type, equals(HighlightType.background));
    });

    test('HighlightStyle presets should contain 5 styles', () {
      expect(HighlightStyle.presets.length, equals(5));
    });

    test('HighlightStyle presets should have different colors', () {
      final colors = HighlightStyle.presets.map((s) => s.color).toSet();
      expect(colors.length, equals(5));
    });

    test('HighlightStyle presets should include both types', () {
      final types = HighlightStyle.presets.map((s) => s.type).toSet();
      expect(types, contains(HighlightType.background));
      expect(types, contains(HighlightType.underline));
    });
  });
}
