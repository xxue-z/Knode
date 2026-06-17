import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wiki/graph/controllers/camera_controller.dart';
import 'package:wiki/graph/controllers/gesture_controller.dart';

void main() {
  group('GestureController', () {
    late CameraController camera;
    late GestureController gesture;

    setUp(() {
      camera = CameraController();
      gesture = GestureController(camera);
    });

    tearDown(() {
      camera.dispose();
    });

    test('onScaleStart captures current camera state', () {
      camera.zoomTo(2.0);
      camera.rotateTo(0.5);

      gesture.onScaleStart(ScaleStartDetails(
        focalPoint: const Offset(100, 200),
      ));

      // Internal state captured; subsequent pan should work
      gesture.onScaleUpdate(
        ScaleUpdateDetails(
          focalPoint: const Offset(150, 250),
          pointerCount: 1,
          scale: 1.0,
          rotation: 0.0,
        ),
        const Size(800, 600),
      );

      expect(camera.offset, const Offset(50, 50));
    });

    test('onScaleEnd resets internal state', () {
      gesture.onScaleStart(ScaleStartDetails(
        focalPoint: const Offset(100, 200),
      ));

      gesture.onScaleEnd(ScaleEndDetails());

      // After end, pan should not accumulate stale delta
      gesture.onScaleUpdate(
        ScaleUpdateDetails(
          focalPoint: const Offset(110, 220),
          pointerCount: 1,
          scale: 1.0,
          rotation: 0.0,
        ),
        const Size(800, 600),
      );

      // first frame after onScaleEnd: _lastFocalPoint is null,
      // so delta is not computed, offset should remain zero
      expect(camera.offset, Offset.zero);
    });
  });
}
