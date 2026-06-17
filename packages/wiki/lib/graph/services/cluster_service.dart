import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/graph_node.dart';
import '../models/graph_edge.dart';
import '../models/graph_cluster.dart';

/// 知识聚类服务
///
/// 将节点按类目分组成星系（Galaxy），
/// 使用 ForceAtlas2 + Radial 布局生成星系位置。
class ClusterService {
  /// 执行聚类
  static List<V2GraphCluster> computeClusters({
    required List<V2GraphNode> nodes,
    required List<V2GraphEdge> edges,
  }) {
    final groups = <String, List<V2GraphNode>>{};
    for (final node in nodes) {
      final cid = node.clusterId ?? node.id;
      groups.putIfAbsent(cid, () => []).add(node);
    }

    final clusters = <V2GraphCluster>[];
    final rng = math.Random(42);
    final count = groups.length;
    final baseRadius = math.max(200.0, count * 60.0);

    int idx = 0;
    for (final entry in groups.entries) {
      final angle = idx * 2 * math.pi / count;
      clusters.add(V2GraphCluster(
        id: entry.key,
        label: entry.key,
        center: Offset(
          baseRadius * math.cos(angle),
          baseRadius * math.sin(angle),
        ),
        radius: 120.0 + entry.value.length * 10.0,
        memberIds: entry.value.map((n) => n.id).toList(),
      ));
      idx++;
    }
    return clusters;
  }
}
