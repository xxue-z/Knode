import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wiki/graph/models/graph_camera.dart';
import 'package:wiki/graph/models/graph_cluster.dart';
import 'package:wiki/graph/models/graph_edge.dart';
import 'package:wiki/graph/models/graph_node.dart';
import 'package:wiki/graph/models/graph_view_state.dart';

void main() {
  group('GraphViewState', () {
    test('can be created with defaults', () {
      final state = const GraphViewState();

      expect(state.nodes, isEmpty);
      expect(state.edges, isEmpty);
      expect(state.clusters, isEmpty);
      expect(state.camera, const CameraState());
      expect(state.selectedNodeId, isNull);
      expect(state.lodLevel, LodLevel.stars);
      expect(state.isLoading, false);
    });

    test('copyWith creates a new instance with modified state', () {
      final node = V2GraphNode(
        id: 'node_1',
        label: 'Test Node',
        type: V2NodeType.article,
      );
      final edge = V2GraphEdge(
        sourceId: 'node_1',
        targetId: 'node_2',
        type: V2EdgeType.reference,
      );
      final cluster = V2GraphCluster(
        id: 'cluster_1',
        label: 'Test Cluster',
        center: Offset.zero,
      );

      final state = GraphViewState(
        nodes: [node],
        edges: [edge],
        clusters: [cluster],
        camera: const CameraState(scale: 2.0),
        selectedNodeId: 'node_1',
        lodLevel: LodLevel.detail,
        isLoading: true,
      );

      final modified = state.copyWith(
        lodLevel: LodLevel.nodes,
        isLoading: false,
      );

      expect(modified.nodes, [node]);
      expect(modified.edges, [edge]);
      expect(modified.clusters, [cluster]);
      expect(modified.camera.scale, 2.0);
      expect(modified.selectedNodeId, 'node_1');
      expect(modified.lodLevel, LodLevel.nodes);
      expect(modified.isLoading, false);

      expect(state.lodLevel, LodLevel.detail);
      expect(state.isLoading, true);
    });
  });

}
