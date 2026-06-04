import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wiki/widgets/graph_edge.dart';

void main() {
  group('EdgeStyle', () {
    group('forType', () {
      test('reference returns solid blue style', () {
        final style = EdgeStyle.forType(EdgeType.reference);
        expect(style.dashPattern, isEmpty);
        expect(style.strokeWidth, equals(2.0));
      });

      test('tagSimilarity returns dashed green style', () {
        final style = EdgeStyle.forType(EdgeType.tagSimilarity);
        expect(style.dashPattern, equals([6.0, 4.0]));
        expect(style.strokeWidth, equals(1.5));
      });

      test('categoryCluster returns dotted orange style', () {
        final style = EdgeStyle.forType(EdgeType.categoryCluster);
        expect(style.dashPattern, equals([2.0, 4.0]));
        expect(style.strokeWidth, equals(1.2));
      });
    });

    group('categoryArticle', () {
      test('returns solid style with category color at 30% opacity', () {
        final style = EdgeStyle.categoryArticle(Colors.blue);
        expect(style.dashPattern, isEmpty);
        expect(style.strokeWidth, equals(1.5));
        expect(style.color, equals(Colors.blue.withOpacity(0.3)));
      });
    });

    group('articleArticle', () {
      test('high similarity (>0.7) returns solid style at 60% opacity', () {
        final style = EdgeStyle.articleArticle(Colors.green, 0.8);
        expect(style.dashPattern, isEmpty);
        expect(style.strokeWidth, equals(1.5));
        expect(style.color, equals(Colors.green.withOpacity(0.6)));
      });

      test(
        'medium similarity (0.5-0.7) returns dashed style at 40% opacity',
        () {
          final style = EdgeStyle.articleArticle(Colors.red, 0.6);
          expect(style.dashPattern, isNotEmpty);
          expect(style.strokeWidth, equals(1.0));
          expect(style.color, equals(Colors.red.withOpacity(0.4)));
        },
      );

      test('low similarity (<0.5) returns dashed style at 20% opacity', () {
        final style = EdgeStyle.articleArticle(Colors.orange, 0.3);
        expect(style.dashPattern, isNotEmpty);
        expect(style.color, equals(Colors.orange.withOpacity(0.2)));
      });

      test('exact boundary 0.7 returns medium similarity style', () {
        final style = EdgeStyle.articleArticle(Colors.purple, 0.7);
        expect(style.dashPattern, isNotEmpty);
      });

      test('exact boundary 0.5 returns medium similarity style', () {
        final style = EdgeStyle.articleArticle(Colors.purple, 0.5);
        expect(style.dashPattern, isNotEmpty);
      });
    });
  });
}
