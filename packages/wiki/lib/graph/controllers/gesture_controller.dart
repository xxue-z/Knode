import 'package:flutter/material.dart';
import 'camera_controller.dart';

class GestureController {
  GestureController(this._camera);

  final CameraController _camera;

  Offset? _lastFocalPoint;
  double _baseScale = 1.0;
  double _lastRotation = 0.0;

  void onScaleStart(ScaleStartDetails details) {
    _lastFocalPoint = details.focalPoint;
    _baseScale = _camera.scale;
    _lastRotation = _camera.rotation;
  }

  void onScaleUpdate(ScaleUpdateDetails details, Size viewport) {
    if (details.pointerCount == 1) {
      if (_lastFocalPoint != null) {
        final delta = details.focalPoint - _lastFocalPoint!;
        _camera.moveTo(delta);
        _lastFocalPoint = details.focalPoint;
      }
    } else if (details.pointerCount >= 2) {
      final newScale = _baseScale * details.scale;
      final scaleFactor = newScale / _camera.scale;
      _camera.zoomTo(scaleFactor);

      final rotationDelta = details.rotation - _lastRotation;
      if (rotationDelta.abs() > 0.001) {
        _camera.rotateTo(rotationDelta);
        _lastRotation = details.rotation;
      }
    }
  }

  void onScaleEnd(ScaleEndDetails details) {
    _lastFocalPoint = null;
    _lastRotation = 0.0;
  }
}
