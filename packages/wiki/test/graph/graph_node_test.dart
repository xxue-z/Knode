import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wiki/widgets/graph_canvas.dart';
import 'package:wiki/widgets/graph_edge.dart' show EdgeType;

void main() {
  group('GraphNode', () {
    test('create category node', () {
      final node = GraphNode(
        id: '1',
        label: 'Notes',
        position: Offset.zero,
        type: NodeType.category,
        categoryId: 1,
        gradientColors: [Color(0xFF64B5F6), Color(0xFF1565C0)],
      );

      expect(node.id, equals('1'));
      expect(node.type, equals(NodeType.category));
      expect(node.categoryId, equals(1));
      expect(node.gradientColors?.length, equals(2));
    });

    test('create article node', () {
      final node = GraphNode(
        id: '2',
        label: 'Flutter Tutorial',
        position: Offset(100, 100),
        type: NodeType.article,
        categoryId: 1,
        tags: ['flutter', 'dart'],
      );

      expect(node.type, equals(NodeType.article));
      expect(node.tags, equals(['flutter', 'dart']));
    });

    test('default node type is category', () {
      final node = GraphNode(id: '3', label: 'Test', position: Offset.zero);

      expect(node.type, equals(NodeType.category));
      expect(node.tags, isEmpty);
    });

    test('node rect is calculated correctly', () {
      final node = GraphNode(
        id: '4',
        label: 'Test',
        position: Offset(100, 100),
        width: 160,
        height: 48,
      );

      expect(node.rect.center, equals(Offset(100, 100)));
      expect(node.rect.width, equals(160));
      expect(node.rect.height, equals(48));
    });
  });

  group('GraphEdge', () {
    test('create reference edge', () {
      final edge = GraphEdge(
        id: 'e1',
        sourceId: '1',
        targetId: '2',
        type: EdgeType.reference,
      );

      expect(edge.type, equals(EdgeType.reference));
      expect(edge.similarity, isNull);
    });

    test('create tag-similarity edge with similarity', () {
      final edge = GraphEdge(
        id: 'e2',
        sourceId: '2',
        targetId: '3',
        type: EdgeType.tagSimilarity,
        similarity: 0.65,
      );

      expect(edge.type, equals(EdgeType.tagSimilarity));
      expect(edge.similarity, equals(0.65));
    });

    test('default edge type is reference', () {
      final edge = GraphEdge(id: 'e3', sourceId: '1', targetId: '2');

      expect(edge.type, equals(EdgeType.reference));
      expect(edge.similarity, isNull);
    });
  });
}
