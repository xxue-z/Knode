import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wiki/graph/controllers/camera_controller.dart';

void main() {
  group('CameraController', () {
    late CameraController controller;

    setUp(() {
      controller = CameraController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('initial state has scale=1, rotation=0, offset=zero', () {
      expect(controller.scale, 1.0);
      expect(controller.rotation, 0.0);
      expect(controller.offset, Offset.zero);
    });

    test('zoomTo changes scale', () {
      controller.zoomTo(2.0);
      expect(controller.scale, 2.0);
    });

    test('zoomTo clamps scale to [0.1, 10.0]', () {
      controller.zoomTo(0.01);
      expect(controller.scale, 0.1);

      controller.zoomTo(200.0);
      expect(controller.scale, 10.0);
    });

    test('moveTo updates offset', () {
      controller.moveTo(const Offset(10, 20));
      expect(controller.offset, const Offset(10, 20));

      controller.moveTo(const Offset(-5, 5));
      expect(controller.offset, const Offset(5, 25));
    });

    test('rotateTo updates rotation (mod 2pi)', () {
      controller.rotateTo(math.pi);
      expect(controller.rotation, math.pi);

      controller.rotateTo(math.pi);
      expect(controller.rotation, closeTo(0.0, 1e-10));
    });

    test('reset restores defaults', () {
      controller.zoomTo(2.0);
      controller.moveTo(const Offset(100, 200));
      controller.rotateTo(0.5);
      controller.reset();

      expect(controller.scale, 1.0);
      expect(controller.rotation, 0.0);
      expect(controller.offset, Offset.zero);
    });

    test('project computes some offset (smoke test)', () {
      final viewport = const Size(800, 600);
      final projected = controller.project(const Offset(0, 0), 0, viewport);
      expect(projected, isNotNull);
      expect(projected.dx, greaterThan(0));
      expect(projected.dy, greaterThan(0));
    });

    test('unproject round-trips through project', () {
      final viewport = const Size(800, 600);
      final original = const Offset(100, 200);

      controller.zoomTo(1.5);
      controller.moveTo(const Offset(50, -30));
      controller.rotateTo(0.3);

      final projected = controller.project(original, 0, viewport);
      final unprojected = controller.unproject(projected, viewport);

      expect(unprojected.dx, closeTo(original.dx, 1e-6));
      expect(unprojected.dy, closeTo(original.dy, 1e-6));
    });

    test('focusOn sets scale and centers on target', () {
      const viewport = Size(800, 600);
      const target = Offset(200, 150);

      controller.focusOn(target, viewport);

      expect(controller.scale, 1.5);
      expect(controller.offset, const Offset(200, 150));
    });
  });
}
