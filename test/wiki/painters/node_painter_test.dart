import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wiki/graph/models/graph_node.dart';
import 'package:wiki/graph/painters/node_painter.dart';

void main() {
  group('NodePainter', () {
    test('paintNode galaxy type paints without error (smoke test)', () {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final node = V2GraphNode(
        id: 'galaxy-1',
        label: 'Test Galaxy',
        type: V2NodeType.galaxy,
        position: const Offset(400, 300),
        size: 48.0,
        glow: 0.5,
        color: Colors.blue,
        gradientColors: [Colors.blue.shade400, Colors.blue.shade800],
      );

      NodePainter.paintNode(
        canvas: canvas,
        node: node,
        screenPos: const Offset(400, 300),
      );

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('paintNode article type paints without error (smoke test)', () {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final node = V2GraphNode(
        id: 'article-1',
        label: 'Test Article',
        type: V2NodeType.article,
        position: const Offset(400, 300),
        size: 32.0,
        color: Colors.green,
        tags: ['flutter', 'dart'],
      );

      NodePainter.paintNode(
        canvas: canvas,
        node: node,
        screenPos: const Offset(400, 300),
      );

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('paintNode handles highlighted state', () {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final node = V2GraphNode(
        id: 'galaxy-2',
        label: 'Highlighted',
        type: V2NodeType.galaxy,
        position: const Offset(400, 300),
        glow: 0.0,
      );

      NodePainter.paintNode(
        canvas: canvas,
        node: node,
        screenPos: const Offset(400, 300),
        isHighlighted: true,
      );

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('paintLabel paints text for galaxy node', () {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final node = V2GraphNode(
        id: 'galaxy-3',
        label: 'Galaxy Label',
        type: V2NodeType.galaxy,
        position: const Offset(400, 300),
        tags: ['test'],
      );

      NodePainter.paintLabel(
        canvas: canvas,
        node: node,
        screenPos: const Offset(400, 300),
        showLabel: true,
      );

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('paintLabel does nothing when showLabel is false', () {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final node = V2GraphNode(
        id: 'galaxy-4',
        label: 'Hidden',
        type: V2NodeType.galaxy,
      );

      NodePainter.paintLabel(
        canvas: canvas,
        node: node,
        screenPos: const Offset(400, 300),
        showLabel: false,
      );

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });
  });
}
