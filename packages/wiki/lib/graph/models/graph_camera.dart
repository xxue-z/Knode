import 'package:flutter/material.dart';

/// 相机状态
class CameraState {
  const CameraState({
    this.scale = 1.0,
    this.rotation = 0.0,
    this.offset = Offset.zero,
    this.tilt = 0.0,
  });

  final double scale;
  final double rotation;
  final Offset offset;
  final double tilt;

  CameraState copyWith({
    double? scale,
    double? rotation,
    Offset? offset,
    double? tilt,
  }) {
    return CameraState(
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      offset: offset ?? this.offset,
      tilt: tilt ?? this.tilt,
    );
  }
}
