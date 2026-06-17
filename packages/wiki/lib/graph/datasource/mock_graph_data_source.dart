import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/graph_node.dart';
import '../models/graph_edge.dart';
import '../models/graph_cluster.dart';
import 'graph_data_source.dart';

/// Mock 测试数据源，用于 UI 开发测试
class MockGraphDataSource implements GraphDataSource {
  final _random = math.Random(42);

  List<V2GraphNode>? _cachedNodes;

  @override
  Future<List<V2GraphNode>> getNodes() async {
    if (_cachedNodes != null) return _cachedNodes!;

    final nodes = <V2GraphNode>[];
    final galaxyNames = ['笔记', '学习', '工作', '创意', '归档', '项目'];

    for (int i = 0; i < 6; i++) {
      final angle = i * 2 * math.pi / 6;
      final radius = 80.0;
      nodes.add(V2GraphNode(
        id: 'galaxy_$i',
        label: galaxyNames[i],
        type: V2NodeType.galaxy,
        position: Offset(
          radius * math.cos(angle),
          radius * math.sin(angle),
        ),
        size: 64.0,
        glow: 0.6,
        clusterId: 'cluster_$i',
      ));

      for (int j = 0; j < 5; j++) {
        final articleAngle = j * 2 * math.pi / 5 + _random.nextDouble() * 0.3;
        final articleRadius = 100.0 + _random.nextDouble() * 60.0;
        nodes.add(V2GraphNode(
          id: 'article_${i}_$j',
          label: '${galaxyNames[i]}文档${j + 1}',
          type: V2NodeType.article,
          position: Offset(
            radius * math.cos(angle) + articleRadius * math.cos(articleAngle),
            radius * math.sin(angle) + articleRadius * math.sin(articleAngle),
          ),
          size: 24.0,
          depth: _random.nextDouble() * 0.5,
          glow: 0.2,
          clusterId: 'cluster_$i',
          tags: ['标签${_random.nextInt(5)}', '标签${_random.nextInt(5)}'],
        ));
      }
    }

    _cachedNodes = nodes;
    return nodes;
  }

  @override
  Future<List<V2GraphEdge>> getEdges() async {
    final edges = <V2GraphEdge>[];
    for (int i = 0; i < 6; i++) {
      for (int j = i + 1; j < 6; j++) {
        if (_random.nextDouble() > 0.5) {
          edges.add(V2GraphEdge(
            sourceId: 'galaxy_$i',
            targetId: 'galaxy_$j',
            type: V2EdgeType.similarity,
            weight: _random.nextDouble() * 0.5 + 0.3,
          ));
        }
      }
    }
    for (int i = 0; i < 6; i++) {
      for (int j = 0; j < 5; j++) {
        for (int k = j + 1; k < 5; k++) {
          if (j % 2 == 0) {
            edges.add(V2GraphEdge(
              sourceId: 'article_${i}_$j',
              targetId: 'article_${i}_$k',
              type: V2EdgeType.reference,
              weight: 0.8,
            ));
          }
        }
      }
    }
    return edges;
  }

  @override
  Future<List<V2GraphCluster>> getClusters() async {
    final clusters = <V2GraphCluster>[];
    for (int i = 0; i < 6; i++) {
      final angle = i * 2 * math.pi / 6;
      clusters.add(V2GraphCluster(
        id: 'cluster_$i',
        label: ['笔记', '学习', '工作', '创意', '归档', '项目'][i],
        center: Offset(80 * math.cos(angle), 80 * math.sin(angle)),
        radius: 150.0,
        memberIds: List.generate(5, (j) => 'article_${i}_$j'),
      ));
    }
    return clusters;
  }

  @override
  Future<V2GraphNode?> getNodeById(String id) async {
    final nodes = await getNodes();
    return nodes.cast<V2GraphNode?>().firstWhere(
      (n) => n!.id == id,
      orElse: () => null,
    );
  }

  @override
  Future<List<V2GraphNode>> searchNodes(String query) async {
    final nodes = await getNodes();
    return nodes.where((n) => n.label.contains(query)).toList();
  }
}
