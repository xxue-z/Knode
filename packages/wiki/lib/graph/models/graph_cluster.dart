import 'package:flutter/material.dart';

/// 知识星系聚类
class V2GraphCluster {
  const V2GraphCluster({
    required this.id,
    required this.label,
    required this.center,
    this.radius = 200.0,
    this.color,
    this.memberIds = const [],
  });

  final String id;
  final String label;
  final Offset center;
  final double radius;
  final Color? color;
  final List<String> memberIds;

  V2GraphCluster copyWith({
    Offset? center,
    double? radius,
    List<String>? memberIds,
  }) {
    return V2GraphCluster(
      id: id,
      label: label,
      center: center ?? this.center,
      radius: radius ?? this.radius,
      color: color,
      memberIds: memberIds ?? this.memberIds,
    );
  }
}
