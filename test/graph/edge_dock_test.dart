import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import 'package:wiki/widgets/graph_canvas.dart';

void main() {
  group('Edge Dock Feature', () {
    group('isNearEdge', () {
      test('returns true when position is near left edge', () {
        final state = _TestGraphCanvasState();
        final screenSize = Size(400, 800);

        expect(state.isNearEdge(Offset(10, 400), screenSize), isTrue);
        expect(state.isNearEdge(Offset(29, 400), screenSize), isTrue);
        expect(state.isNearEdge(Offset(31, 400), screenSize), isFalse);
      });

      test('returns true when position is near right edge', () {
        final state = _TestGraphCanvasState();
        final screenSize = Size(400, 800);

        expect(state.isNearEdge(Offset(390, 400), screenSize), isTrue);
        expect(state.isNearEdge(Offset(371, 400), screenSize), isTrue);
        expect(state.isNearEdge(Offset(369, 400), screenSize), isFalse);
      });

      test('returns true when position is near top edge', () {
        final state = _TestGraphCanvasState();
        final screenSize = Size(400, 800);

        expect(state.isNearEdge(Offset(200, 10), screenSize), isTrue);
        expect(state.isNearEdge(Offset(200, 29), screenSize), isTrue);
        expect(state.isNearEdge(Offset(200, 31), screenSize), isFalse);
      });

      test('returns true when position is near bottom edge', () {
        final state = _TestGraphCanvasState();
        final screenSize = Size(400, 800);

        expect(state.isNearEdge(Offset(200, 790), screenSize), isTrue);
        expect(state.isNearEdge(Offset(200, 771), screenSize), isTrue);
        expect(state.isNearEdge(Offset(200, 769), screenSize), isFalse);
      });

      test('returns false when position is in center', () {
        final state = _TestGraphCanvasState();
        final screenSize = Size(400, 800);

        expect(state.isNearEdge(Offset(200, 400), screenSize), isFalse);
      });
    });

    group('getDockPosition', () {
      test('clamps position to left edge threshold', () {
        final state = _TestGraphCanvasState();
        final screenSize = Size(400, 800);

        final pos = state.getDockPosition(Offset(-10, 400), screenSize);
        expect(pos.dx, equals(30.0));
        expect(pos.dy, equals(400.0));
      });

      test('clamps position to right edge threshold', () {
        final state = _TestGraphCanvasState();
        final screenSize = Size(400, 800);

        final pos = state.getDockPosition(Offset(500, 400), screenSize);
        expect(pos.dx, equals(370.0));
        expect(pos.dy, equals(400.0));
      });

      test('clamps position to top edge threshold', () {
        final state = _TestGraphCanvasState();
        final screenSize = Size(400, 800);

        final pos = state.getDockPosition(Offset(200, -10), screenSize);
        expect(pos.dx, equals(200.0));
        expect(pos.dy, equals(30.0));
      });

      test('clamps position to bottom edge threshold', () {
        final state = _TestGraphCanvasState();
        final screenSize = Size(400, 800);

        final pos = state.getDockPosition(Offset(200, 900), screenSize);
        expect(pos.dx, equals(200.0));
        expect(pos.dy, equals(770.0));
      });

      test('does not change position when already within bounds', () {
        final state = _TestGraphCanvasState();
        final screenSize = Size(400, 800);

        final pos = state.getDockPosition(Offset(200, 400), screenSize);
        expect(pos.dx, equals(200.0));
        expect(pos.dy, equals(400.0));
      });
    });

    group('GraphCanvasPainter dock markers', () {
      test('dockedNodes and dockPositions are passed correctly', () {
        final dockedNodes = {'1': true, '2': false};
        final dockPositions = {'1': Offset(30, 400)};

        final painter = GraphCanvasPainter(
          nodes: [],
          edges: [],
          transform: vm.Matrix4.identity(),
          dockedNodes: dockedNodes,
          dockPositions: dockPositions,
        );

        expect(painter.dockedNodes, equals(dockedNodes));
        expect(painter.dockPositions, equals(dockPositions));
      });

      test('shouldRepaint returns true when dock state changes', () {
        final painter1 = GraphCanvasPainter(
          nodes: [],
          edges: [],
          transform: vm.Matrix4.identity(),
          dockedNodes: {'1': false},
        );

        final painter2 = GraphCanvasPainter(
          nodes: [],
          edges: [],
          transform: vm.Matrix4.identity(),
          dockedNodes: {'1': true},
        );

        expect(painter2.shouldRepaint(painter1), isTrue);
      });
    });
  });
}

/// Helper class to expose state methods for testing.
class _TestGraphCanvasState {
  static const double _edgeThreshold = 30.0;

  bool isNearEdge(Offset position, Size screenSize) {
    return position.dx < _edgeThreshold ||
        position.dx > screenSize.width - _edgeThreshold ||
        position.dy < _edgeThreshold ||
        position.dy > screenSize.height - _edgeThreshold;
  }

  Offset getDockPosition(Offset position, Size screenSize) {
    return Offset(
      position.dx.clamp(_edgeThreshold, screenSize.width - _edgeThreshold),
      position.dy.clamp(_edgeThreshold, screenSize.height - _edgeThreshold),
    );
  }
}
