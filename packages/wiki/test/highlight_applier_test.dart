import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:core/models/highlight.dart';
import 'package:core/models/highlight_style.dart';
import 'package:wiki/utils/highlight_applier.dart';

void main() {
  group('HighlightApplier Tests', () {
    test('should build spans without highlights', () {
      const text = 'Hello World';
      const baseStyle = TextStyle(fontSize: 14);

      final span = HighlightApplier.buildSpans(
        text: text,
        highlights: [],
        baseStyle: baseStyle,
      );

      // Empty highlights: full text is a single child span
      expect(span.children, isNotNull);
      expect(span.children!.length, equals(1));
      expect((span.children![0] as dynamic).text, equals(text));
      expect(span.style, equals(baseStyle));
    });

    test('should apply single highlight', () {
      const text = 'Hello World';
      const baseStyle = TextStyle(fontSize: 14);
      final highlights = [
        Highlight(
          id: 1,
          docId: 1,
          startPos: 0,
          endPos: 5,
          selectedText: 'Hello',
          style: const HighlightStyle(
            type: HighlightType.background,
            color: Color(0xFFFFF59D),
          ),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final span = HighlightApplier.buildSpans(
        text: text,
        highlights: highlights,
        baseStyle: baseStyle,
      );

      expect(span.children, isNotNull);
      expect(span.children!.length, greaterThan(0));
    });

    test('should apply multiple highlights', () {
      const text = 'Hello World Test';
      const baseStyle = TextStyle(fontSize: 14);
      final highlights = [
        Highlight(
          id: 1,
          docId: 1,
          startPos: 0,
          endPos: 5,
          selectedText: 'Hello',
          style: const HighlightStyle(
            type: HighlightType.background,
            color: Color(0xFFFFF59D),
          ),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Highlight(
          id: 2,
          docId: 1,
          startPos: 6,
          endPos: 11,
          selectedText: 'World',
          style: const HighlightStyle(
            type: HighlightType.underline,
            color: Color(0xFFE57373),
          ),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final span = HighlightApplier.buildSpans(
        text: text,
        highlights: highlights,
        baseStyle: baseStyle,
      );

      expect(span.children, isNotNull);
      expect(span.children!.length, greaterThanOrEqualTo(2));
    });

    test('should handle overlapping highlights', () {
      const text = 'Hello World';
      const baseStyle = TextStyle(fontSize: 14);
      final highlights = [
        Highlight(
          id: 1,
          docId: 1,
          startPos: 0,
          endPos: 8,
          selectedText: 'Hello Wo',
          style: const HighlightStyle(
            type: HighlightType.background,
            color: Color(0xFFFFF59D),
          ),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Highlight(
          id: 2,
          docId: 1,
          startPos: 5,
          endPos: 11,
          selectedText: 'World',
          style: const HighlightStyle(
            type: HighlightType.background,
            color: Color(0xFF81C784),
          ),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final span = HighlightApplier.buildSpans(
        text: text,
        highlights: highlights,
        baseStyle: baseStyle,
      );

      expect(span.children, isNotNull);
    });

    test('should handle highlight at text boundaries', () {
      const text = 'Hello';
      const baseStyle = TextStyle(fontSize: 14);
      final highlights = [
        Highlight(
          id: 1,
          docId: 1,
          startPos: 0,
          endPos: 5,
          selectedText: 'Hello',
          style: const HighlightStyle(
            type: HighlightType.background,
            color: Color(0xFFFFF59D),
          ),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final span = HighlightApplier.buildSpans(
        text: text,
        highlights: highlights,
        baseStyle: baseStyle,
      );

      expect(span.children, isNotNull);
    });

    test('should ignore invalid highlight positions', () {
      const text = 'Hello';
      const baseStyle = TextStyle(fontSize: 14);
      final highlights = [
        Highlight(
          id: 1,
          docId: 1,
          startPos: 10,
          endPos: 20,
          selectedText: 'invalid',
          style: const HighlightStyle(
            type: HighlightType.background,
            color: Color(0xFFFFF59D),
          ),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final span = HighlightApplier.buildSpans(
        text: text,
        highlights: highlights,
        baseStyle: baseStyle,
      );

      // Empty highlights: full text is a single child span
      expect(span.children, isNotNull);
      expect(span.children!.length, equals(1));
      expect((span.children![0] as dynamic).text, equals(text));
    });

    test('should apply underline style correctly', () {
      const text = 'Hello World';
      const baseStyle = TextStyle(fontSize: 14);
      final highlights = [
        Highlight(
          id: 1,
          docId: 1,
          startPos: 0,
          endPos: 5,
          selectedText: 'Hello',
          style: const HighlightStyle(
            type: HighlightType.underline,
            color: Color(0xFFE57373),
          ),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final span = HighlightApplier.buildSpans(
        text: text,
        highlights: highlights,
        baseStyle: baseStyle,
      );

      expect(span.children, isNotNull);
    });
  });
}
