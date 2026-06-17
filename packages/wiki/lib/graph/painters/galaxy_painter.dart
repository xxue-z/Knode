import 'package:flutter/material.dart';
import '../models/graph_view_state.dart';
import '../models/graph_node.dart';
import '../models/graph_edge.dart';
import '../controllers/camera_controller.dart';
import '../services/lod_service.dart';
import 'starfield_painter.dart';
import 'node_painter.dart';
import 'edge_painter.dart';

class GalaxyPainter extends CustomPainter {
  GalaxyPainter({
    required this.viewState,
    required this.camera,
    required this.viewport,
    this.starColor = Colors.white,
    this.brightness = Brightness.dark,
  });

  final GraphViewState viewState;
  final CameraController camera;
  final Size viewport;
  final Color starColor;
  final Brightness brightness;

  @override
  void paint(Canvas canvas, Size size) {
    final lod = viewState.lodLevel;

    StarfieldPainter(
      color: starColor,
      starCount: 200,
      brightness: brightness,
    ).paint(canvas, size);

    if (lod == LodLevel.stars) return;

    if (LODService.shouldShowEdges(lod)) {
      _paintEdges(canvas);
    }

    final showLabels = LODService.shouldShowLabels(lod);
    _paintNodes(canvas, showLabels);
  }

  void _paintEdges(Canvas canvas) {
    for (final edge in viewState.edges) {
      final sourceNode = _findNode(edge.sourceId);
      final targetNode = _findNode(edge.targetId);
      if (sourceNode == null || targetNode == null) continue;

      final from = camera.project(
        sourceNode.position, sourceNode.depth, viewport,
      );
      final to = camera.project(
        targetNode.position, targetNode.depth, viewport,
      );

      EdgePainter.paintEdge(canvas: canvas, from: from, to: to, edge: edge);
    }
  }

  void _paintNodes(Canvas canvas, bool showLabels) {
    final sorted = List<V2GraphNode>.from(viewState.nodes)
      ..sort((a, b) => a.type == V2NodeType.galaxy ? 1 : -1);

    for (final node in sorted) {
      final screenPos = camera.project(node.position, node.depth, viewport);
      final isHighlighted = node.id == viewState.selectedNodeId;

      NodePainter.paintNode(
        canvas: canvas,
        node: node,
        screenPos: screenPos,
        isHighlighted: isHighlighted,
      );

      NodePainter.paintLabel(
        canvas: canvas,
        node: node,
        screenPos: screenPos,
        showLabel: showLabels,
      );
    }
  }

  V2GraphNode? _findNode(String id) {
    try {
      return viewState.nodes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  bool shouldRepaint(covariant GalaxyPainter old) {
    return old.viewState != viewState;
  }
}
