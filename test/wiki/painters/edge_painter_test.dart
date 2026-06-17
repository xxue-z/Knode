import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wiki/graph/models/graph_edge.dart';
import 'package:wiki/graph/painters/edge_painter.dart';

void main() {
  group('EdgePainter', () {
    test('paintEdge reference type paints without error (smoke test)', () {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final edge = V2GraphEdge(
        sourceId: 'a',
        targetId: 'b',
        type: V2EdgeType.reference,
        weight: 1.0,
        opacity: 0.8,
      );

      EdgePainter.paintEdge(
        canvas: canvas,
        from: const Offset(100, 100),
        to: const Offset(300, 300),
        edge: edge,
      );

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('paintEdge similarity type paints without error (smoke test)', () {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final edge = V2GraphEdge(
        sourceId: 'a',
        targetId: 'b',
        type: V2EdgeType.similarity,
        weight: 0.5,
        opacity: 0.5,
      );

      EdgePainter.paintEdge(
        canvas: canvas,
        from: const Offset(100, 100),
        to: const Offset(300, 300),
        edge: edge,
      );

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('paintEdge cluster type paints without error (smoke test)', () {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final edge = V2GraphEdge(
        sourceId: 'a',
        targetId: 'b',
        type: V2EdgeType.cluster,
        weight: 0.3,
        opacity: 0.3,
      );

      EdgePainter.paintEdge(
        canvas: canvas,
        from: const Offset(100, 100),
        to: const Offset(300, 300),
        edge: edge,
      );

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('paintEdge handles zero-length edge gracefully', () {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final edge = V2GraphEdge(
        sourceId: 'a',
        targetId: 'b',
        type: V2EdgeType.similarity,
      );

      // Same from/to = zero length
      EdgePainter.paintEdge(
        canvas: canvas,
        from: const Offset(100, 100),
        to: const Offset(100, 100),
        edge: edge,
      );

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });
  });
}
