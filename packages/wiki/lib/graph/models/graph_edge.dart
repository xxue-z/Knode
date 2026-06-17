import 'package:flutter/material.dart';

/// 边类型
enum V2EdgeType { reference, similarity, cluster }

/// V2 图谱边
class V2GraphEdge {
  const V2GraphEdge({
    required this.sourceId,
    required this.targetId,
    required this.type,
    this.weight = 1.0,
    this.opacity = 0.5,
  });

  final String sourceId;
  final String targetId;
  final V2EdgeType type;
  final double weight;
  final double opacity;
}
