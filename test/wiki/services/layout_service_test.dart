import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wiki/graph/models/graph_node.dart';
import 'package:wiki/graph/models/graph_edge.dart';
import 'package:wiki/graph/models/graph_cluster.dart';
import 'package:wiki/graph/services/layout_service.dart';

void main() {
  group('LayoutService', () {
    test('computeLayout updates node positions within cluster', () {
      final cluster = V2GraphCluster(
        id: 'c1',
        label: 'C1',
        center: const Offset(200, 200),
        radius: 150,
        memberIds: ['a1', 'a2'],
      );
      final nodes = [
        V2GraphNode(id: 'a1', label: 'A1', type: V2NodeType.article, clusterId: 'c1'),
        V2GraphNode(id: 'a2', label: 'A2', type: V2NodeType.article, clusterId: 'c1'),
      ];
      final edges = <V2GraphEdge>[];

      LayoutService.computeLayout(nodes: nodes, clusters: [cluster], edges: edges);

      for (final node in nodes) {
        expect(node.position, isNot(Offset.zero));
      }
    });

    test('computeLayout does not move nodes without matching cluster', () {
      final cluster = V2GraphCluster(
        id: 'c1',
        label: 'C1',
        center: const Offset(0, 0),
        memberIds: ['a1'],
      );
      final nodes = [
        V2GraphNode(id: 'orphan', label: 'Orphan', type: V2NodeType.article, clusterId: 'nonexistent'),
      ];
      final edges = <V2GraphEdge>[];

      LayoutService.computeLayout(nodes: nodes, clusters: [cluster], edges: edges);

      expect(nodes.first.position, Offset.zero);
    });
  });
}
