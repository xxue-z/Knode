import 'package:flutter/material.dart';

/// 节点类型
enum V2NodeType { galaxy, article }

/// V2 知识图谱节点
class V2GraphNode {
  const V2GraphNode({
    required this.id,
    required this.label,
    required this.type,
    this.summary,
    this.position = Offset.zero,
    this.depth = 0.0,
    this.size = 48.0,
    this.glow = 0.0,
    this.opacity = 1.0,
    this.scale = 1.0,
    this.color,
    this.gradientColors,
    this.clusterId,
    this.tags = const [],
    this.children = const [],
  });

  final String id;
  final String label;
  final String? summary;
  final V2NodeType type;
  final Offset position;
  final double depth;
  final double size;
  final double glow;
  final double opacity;
  final double scale;
  final Color? color;
  final List<Color>? gradientColors;
  final String? clusterId;
  final List<String> tags;
  final List<V2GraphNode> children;

  V2GraphNode copyWith({
    Offset? position,
    double? depth,
    double? size,
    double? glow,
    double? opacity,
    double? scale,
  }) {
    return V2GraphNode(
      id: id,
      label: label,
      summary: summary,
      type: type,
      position: position ?? this.position,
      depth: depth ?? this.depth,
      size: size ?? this.size,
      glow: glow ?? this.glow,
      opacity: opacity ?? this.opacity,
      scale: scale ?? this.scale,
      color: color,
      gradientColors: gradientColors,
      clusterId: clusterId,
      tags: tags,
      children: children,
    );
  }

  /// Z 轴投影后的屏幕位置（由 CameraController 计算）
  Offset get projectedPosition => position;
}
