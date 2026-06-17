import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wiki/graph/models/graph_node.dart';
import 'package:wiki/graph/models/graph_edge.dart';
import 'package:wiki/graph/services/cluster_service.dart';

void main() {
  group('ClusterService', () {
    test('computeClusters groups nodes by clusterId', () {
      final nodes = [
        V2GraphNode(id: 'a1', label: 'A1', type: V2NodeType.article, clusterId: 'cluster_a'),
        V2GraphNode(id: 'a2', label: 'A2', type: V2NodeType.article, clusterId: 'cluster_a'),
        V2GraphNode(id: 'b1', label: 'B1', type: V2NodeType.article, clusterId: 'cluster_b'),
      ];
      final edges = <V2GraphEdge>[];

      final clusters = ClusterService.computeClusters(nodes: nodes, edges: edges);

      expect(clusters.length, 2);

      final clusterA = clusters.firstWhere((c) => c.id == 'cluster_a');
      expect(clusterA.label, 'cluster_a');
      expect(clusterA.memberIds, containsAll(['a1', 'a2']));

      final clusterB = clusters.firstWhere((c) => c.id == 'cluster_b');
      expect(clusterB.label, 'cluster_b');
      expect(clusterB.memberIds, containsAll(['b1']));
    });

    test('computeClusters nodes without clusterId get their own id as clusterId', () {
      final nodes = [
        V2GraphNode(id: 'n1', label: 'N1', type: V2NodeType.article),
        V2GraphNode(id: 'n2', label: 'N2', type: V2NodeType.article),
      ];
      final edges = <V2GraphEdge>[];

      final clusters = ClusterService.computeClusters(nodes: nodes, edges: edges);

      expect(clusters.length, 2);
      expect(clusters[0].memberIds, contains('n1'));
      expect(clusters[1].memberIds, contains('n2'));
    });

    test('computeClusters assigns positions in a circle', () {
      final nodes = [
        V2GraphNode(id: 'x1', label: 'X1', type: V2NodeType.article, clusterId: 'c1'),
        V2GraphNode(id: 'y1', label: 'Y1', type: V2NodeType.article, clusterId: 'c2'),
        V2GraphNode(id: 'z1', label: 'Z1', type: V2NodeType.article, clusterId: 'c3'),
      ];
      final edges = <V2GraphEdge>[];

      final clusters = ClusterService.computeClusters(nodes: nodes, edges: edges);

      expect(clusters.length, 3);
      for (final c in clusters) {
        expect(c.center, isNot(Offset.zero));
      }
    });
  });
}
