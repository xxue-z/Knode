import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wiki/graph/models/graph_node.dart';

void main() {
  group('V2GraphNode', () {
    test('can be created with required params', () {
      final node = V2GraphNode(
        id: 'node_1',
        label: 'Test Node',
        type: V2NodeType.article,
      );

      expect(node.id, 'node_1');
      expect(node.label, 'Test Node');
      expect(node.type, V2NodeType.article);
      expect(node.position, Offset.zero);
      expect(node.depth, 0.0);
      expect(node.size, 48.0);
      expect(node.glow, 0.0);
      expect(node.opacity, 1.0);
      expect(node.scale, 1.0);
      expect(node.color, isNull);
      expect(node.gradientColors, isNull);
      expect(node.clusterId, isNull);
      expect(node.tags, isEmpty);
      expect(node.children, isEmpty);
    });

    test('copyWith creates a new instance with modified position', () {
      final node = V2GraphNode(
        id: 'node_1',
        label: 'Test Node',
        type: V2NodeType.galaxy,
        position: const Offset(100, 200),
      );

      final modified = node.copyWith(position: const Offset(300, 400));

      expect(modified.id, 'node_1');
      expect(modified.position, const Offset(300, 400));

      expect(node.position, const Offset(100, 200));
    });
  });

}
