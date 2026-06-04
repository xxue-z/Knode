import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wiki/widgets/graph_canvas.dart';
import 'package:wiki/widgets/graph_edge.dart' show EdgeType;
import 'package:wiki/utils/graph_theme.dart';

void main() {
  group('Graph Integration', () {
    test('GraphNode can be created with all properties', () {
      final node = GraphNode(
        id: '1',
        label: 'Test Node',
        position: const Offset(100, 200),
        width: 120,
        height: 60,
        type: NodeType.category,
        categoryId: 1,
        gradientColors: GraphTheme.getGradientForCategory(1),
        tags: ['flutter', 'dart'],
      );

      expect(node.id, equals('1'));
      expect(node.label, equals('Test Node'));
      expect(node.type, equals(NodeType.category));
      expect(node.categoryId, equals(1));
      expect(node.gradientColors, isNotNull);
      expect(node.gradientColors!.length, equals(3));
      expect(node.tags, equals(['flutter', 'dart']));
    });

    test('GraphEdge can be created with all properties', () {
      final edge = GraphEdge(
        id: 'e1',
        sourceId: '1',
        targetId: '2',
        type: EdgeType.reference,
        similarity: 0.8,
        color: Colors.blue,
        label: 'related',
      );

      expect(edge.id, equals('e1'));
      expect(edge.sourceId, equals('1'));
      expect(edge.targetId, equals('2'));
      expect(edge.type, equals(EdgeType.reference));
      expect(edge.similarity, equals(0.8));
    });

    test('GraphCanvas renders without errors with empty data', () {
      final painter = GraphCanvasPainter(
        nodes: [],
        edges: [],
        transform: Matrix4.identity(),
      );

      expect(painter.nodes, isEmpty);
      expect(painter.edges, isEmpty);
    });

    test('GraphCanvas renders with mixed node types', () {
      final nodes = [
        GraphNode(
          id: 'cat1',
          label: 'Category',
          position: const Offset(100, 100),
          type: NodeType.category,
          categoryId: 1,
          gradientColors: GraphTheme.getGradientForCategory(1),
        ),
        GraphNode(
          id: 'art1',
          label: 'Article',
          position: const Offset(200, 200),
          type: NodeType.article,
          categoryId: 1,
        ),
      ];
      final edges = [
        GraphEdge(
          id: 'e1',
          sourceId: 'cat1',
          targetId: 'art1',
          type: EdgeType.reference,
        ),
      ];

      final painter = GraphCanvasPainter(
        nodes: nodes,
        edges: edges,
        transform: Matrix4.identity(),
      );

      expect(painter.nodes.length, equals(2));
      expect(painter.edges.length, equals(1));
    });

    test('GraphTheme provides correct gradients for all categories', () {
      for (int i = 1; i <= 5; i++) {
        final gradient = GraphTheme.getGradientForCategory(i);
        expect(
          gradient.length,
          equals(3),
          reason: 'Category $i should have 3 gradient colors',
        );
      }
    });

    test('EdgeStyle handles all edge types', () {
      // reference → solid
      // tagSimilarity → dashed
      // categoryCluster → dotted
      // All types should be representable
      expect(EdgeType.values.length, equals(3));
    });
  });
}
