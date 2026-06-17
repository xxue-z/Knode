import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import '../models/graph_camera.dart';

class CameraController extends ChangeNotifier {
  CameraState _state = const CameraState();

  CameraState get state => _state;
  double get scale => _state.scale;
  double get rotation => _state.rotation;
  Offset get offset => _state.offset;

  void zoomTo(double factor, {Offset? focalPoint}) {
    final newScale = (_state.scale * factor).clamp(0.1, 10.0);
    _state = _state.copyWith(scale: newScale);
    notifyListeners();
  }

  void moveTo(Offset delta) {
    _state = _state.copyWith(offset: _state.offset + delta);
    notifyListeners();
  }

  void rotateTo(double angle) {
    _state = _state.copyWith(
      rotation: (_state.rotation + angle) % (2 * math.pi),
    );
    notifyListeners();
  }

  void tiltTo(double tilt) {
    _state = _state.copyWith(tilt: tilt.clamp(-0.5, 0.5));
    notifyListeners();
  }

  void focusOn(Offset target, Size viewport) {
    _state = CameraState(
      scale: 1.5,
      offset: Offset(
        viewport.width / 2 - target.dx,
        viewport.height / 2 - target.dy,
      ),
    );
    notifyListeners();
  }

  void reset() {
    _state = const CameraState();
    notifyListeners();
  }

  Offset project(Offset position, double depth, Size viewport) {
    final center = Offset(viewport.width / 2, viewport.height / 2);

    final perspective = 1.0 / (1.0 + depth * 0.3);

    final matrix = vm.Matrix4.identity()
      ..translate(offset.dx + center.dx, offset.dy + center.dy)
      ..rotateZ(rotation)
      ..scale(scale * perspective, scale * perspective);

    final v = vm.Vector4(position.dx, position.dy, 0, 1);
    final result = matrix.transform(v);
    return Offset(result.x, result.y);
  }

  Offset unproject(Offset screen, Size viewport) {
    final center = Offset(viewport.width / 2, viewport.height / 2);
    final dx = (screen.dx - center.dx - offset.dx) / scale;
    final dy = (screen.dy - center.dy - offset.dy) / scale;
    final cosR = math.cos(-rotation);
    final sinR = math.sin(-rotation);
    return Offset(
      dx * cosR - dy * sinR,
      dx * sinR + dy * cosR,
    );
  }
}
