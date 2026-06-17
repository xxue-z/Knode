import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/graph_node.dart';
import '../models/graph_edge.dart';
import '../models/graph_cluster.dart';

/// 布局服务
///
/// 一级：Fruchterman 力导向布局计算星系中心位置
/// 二级：Spiral 螺旋布局计算星系内文章位置
class LayoutService {
  /// 计算完整布局
  static void computeLayout({
    required List<V2GraphNode> nodes,
    required List<V2GraphCluster> clusters,
    List<V2GraphEdge> edges = const [],
  }) {
    final rng = math.Random(42);

    for (final cluster in clusters) {
      final members = nodes.where((n) => n.clusterId == cluster.id).toList();
      for (int i = 0; i < members.length; i++) {
        final angle = i * 0.5;
        final dist = cluster.radius * (0.3 + rng.nextDouble() * 0.7);
        final node = members[i];
        nodes[nodes.indexOf(node)] = node.copyWith(
          position: Offset(
            cluster.center.dx + dist * math.cos(angle),
            cluster.center.dy + dist * math.sin(angle),
          ),
        );
      }
    }
  }
}
