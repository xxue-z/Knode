import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

// ---------------------------------------------------------------------------
// Data Models
// ---------------------------------------------------------------------------

/// Node type in the knowledge graph.
enum NodeType { category, article }

/// Edge type in the knowledge graph.
enum EdgeType { categoryArticle, articleArticle }

/// A minimal node in the knowledge graph.
class GraphNode {
  const GraphNode({
    required this.id,
    required this.label,
    required this.position,
    this.width = 160.0,
    this.height = 48.0,
    this.color = const Color(0xFF37474F),
    this.textColor = Colors.white,
    this.borderColor = const Color(0xFF263238),
    this.borderWidth = 1.5,
    this.fontSize = 14.0,
    this.type = NodeType.category,
    this.categoryId,
    this.gradientColors,
    this.tags = const [],
  });

  final String id;
  final String label;
  final Offset position;
  final double width;
  final double height;
  final Color color;
  final Color textColor;
  final Color borderColor;
  final double borderWidth;
  final double fontSize;
  final NodeType type;
  final int? categoryId;
  final List<Color>? gradientColors;
  final List<String> tags;

  /// Bounding rect in graph-space.
  Rect get rect => Rect.fromCenter(
        center: position,
        width: width,
        height: height,
      );
}

/// An edge connecting two nodes.
class GraphEdge {
  const GraphEdge({
    required this.id,
    required this.sourceId,
    required this.targetId,
    this.color = const Color(0xFF78909C),
    this.width = 1.5,
    this.arrowSize = 8.0,
    this.showArrow = true,
    this.label,
    this.type = EdgeType.categoryArticle,
    this.similarity,
  });

  final String id;
  final String sourceId;
  final String targetId;
  final Color color;
  final double width;
  final double arrowSize;
  final bool showArrow;
  final String? label;
  final EdgeType type;
  final double? similarity;
}

// ---------------------------------------------------------------------------
// GraphCanvasPainter
// ---------------------------------------------------------------------------

/// CustomPainter that renders nodes and edges onto a [Canvas] after applying
/// the supplied [transform] matrix.
class GraphCanvasPainter extends CustomPainter {
  GraphCanvasPainter({
    required this.nodes,
    required this.edges,
    required this.transform,
    this.highlightedNodeId,
    this.hitAreas,
  });

  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final vm.Matrix4 transform;
  final String? highlightedNodeId;
  final List<Rect>? hitAreas;

  // Cached look-up for fast node access.
  Map<String, GraphNode> _nodeMap = {};

  @override
  void paint(Canvas uiCanvas, Size size) {
    _nodeMap = {
      for (final n in nodes) n.id: n,
    };

    // Save layer and apply the combined transform.
    uiCanvas.save();
    final matrix4 = vm.Matrix4.compose(
      vm.Vector3(transform[3], transform[7], transform[11]),
      vm.Quaternion.identity(),
      vm.Vector3(transform[0], transform[5], transform[10]),
    );
    uiCanvas.transform(matrix4.storage);

    _drawEdges(uiCanvas);
    _drawNodes(uiCanvas);

    uiCanvas.restore();
  }

  void _drawEdges(ui.Canvas canvas) {
    for (final edge in edges) {
      final source = _nodeMap[edge.sourceId];
      final target = _nodeMap[edge.targetId];
      if (source == null || target == null) continue;

      final paint = Paint()
        ..color = edge.color
        ..strokeWidth = edge.width
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final start = source.position;
      final end = target.position;

      canvas.drawLine(start, end, paint);

      // Arrowhead
      if (edge.showArrow) {
        _drawArrowhead(canvas, start, end, edge.arrowSize, paint);
      }

      // Edge label (centred midpoint).
      if (edge.label != null && edge.label!.isNotEmpty) {
        final mid = Offset(
          (start.dx + end.dx) / 2,
          (start.dy + end.dy) / 2,
        );
        final textPainter = TextPainter(
          text: TextSpan(
            text: edge.label,
            style: TextStyle(
              color: edge.color,
              fontSize: 11,
            ),
          ),
          textDirection: ui.TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          mid - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }
    }
  }

  void _drawArrowhead(
    ui.Canvas canvas,
    Offset from,
    Offset to,
    double size,
    Paint paint,
  ) {
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final angle = math.atan2(dy, dx);
    final halfPi = math.pi / 2;

    final p1 = Offset(
      to.dx - size * math.cos(angle - halfPi / 2),
      to.dy - size * math.sin(angle - halfPi / 2),
    );
    final p2 = Offset(
      to.dx - size * math.cos(angle + halfPi / 2),
      to.dy - size * math.sin(angle + halfPi / 2),
    );

    final arrowPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;

    final path = ui.Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();

    canvas.drawPath(path, arrowPaint);
  }

  void _drawNodes(ui.Canvas canvas) {
    for (final node in nodes) {
      final isHighlighted = node.id == highlightedNodeId;
      final rect = node.rect;

      // Shadow for highlighted nodes.
      if (isHighlighted) {
        final shadowPaint = Paint()
          ..color = Colors.black26
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawRRect(
          _roundedRect(rect, 10),
          shadowPaint,
        );
      }

      // Body
      final bodyPaint = Paint()..color = node.color;
      final rrect = _roundedRect(rect, 10);
      canvas.drawRRect(rrect, bodyPaint);

      // Border
      final borderPaint = Paint()
        ..color = isHighlighted ? Colors.amber : node.borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = isHighlighted ? 2.5 : node.borderWidth;
      canvas.drawRRect(rrect, borderPaint);

      // Label
      final textPainter = TextPainter(
        text: TextSpan(
          text: node.label,
          style: TextStyle(
            color: node.textColor,
            fontSize: node.fontSize,
            fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: rect.width - 16);

      textPainter.paint(
        canvas,
        Offset(
          rect.left + (rect.width - textPainter.width) / 2,
          rect.top + (rect.height - textPainter.height) / 2,
        ),
      );
    }
  }

  RRect _roundedRect(Rect rect, double radius) {
    return RRect.fromRectAndRadius(rect, Radius.circular(radius));
  }

  @override
  bool shouldRepaint(covariant GraphCanvasPainter oldDelegate) {
    return oldDelegate.transform != transform ||
        oldDelegate.highlightedNodeId != highlightedNodeId ||
        !listEquals(oldDelegate.nodes, nodes) ||
        !listEquals(oldDelegate.edges, edges);
  }
}

// ---------------------------------------------------------------------------
// GraphController
// ---------------------------------------------------------------------------

/// Manages the pan / zoom [Matrix4] state for the graph canvas.
class GraphController extends ChangeNotifier {
  GraphController({vm.Matrix4? initialTransform})
      : _transform = initialTransform ?? vm.Matrix4.identity();

  vm.Matrix4 _transform;

  vm.Matrix4 get transform => _transform;

  set transform(vm.Matrix4 value) {
    _transform = value;
    notifyListeners();
  }

  void applyTranslation(double dx, double dy) {
    _transform = _transform.clone()
      ..translate(dx, dy);
    notifyListeners();
  }

  void applyScale(double scale, Offset focalPoint) {
    final double clampedScale = scale.clamp(0.1, 10.0);
    final vm.Vector3 translation = _transform.getTranslation();

    // Translate focal point to local space.
    final vm.Vector3 focal = vm.Vector3(focalPoint.dx, focalPoint.dy, 0);
    _transform = _transform.clone()
      ..translate(focalPoint.dx, focalPoint.dy)
      ..scale(clampedScale)
      ..translate(-focalPoint.dx, -focalPoint.dy);

    // Clamp pan bounds if desired.
    notifyListeners();
  }

  void reset() {
    _transform = vm.Matrix4.identity();
    notifyListeners();
  }

  /// Convert a screen-space [Offset] into graph-space coordinates.
  vm.Vector3 screenToGraph(Offset screen) {
    final inverse = vm.Matrix4.inverted(_transform);
    final v = vm.Vector4(screen.dx, screen.dy, 0, 1);
    final result = inverse.transform(v);
    return vm.Vector3(result.x, result.y, result.z);
  }
}

// ---------------------------------------------------------------------------
// GraphCanvas Widget
// ---------------------------------------------------------------------------

/// A self-contained canvas for rendering a knowledge graph with pan, zoom,
/// and tap-to-select capabilities.
class GraphCanvas extends StatefulWidget {
  const GraphCanvas({
    super.key,
    required this.nodes,
    required this.edges,
    this.controller,
    this.onNodeTap,
    this.onNodeDoubleTap,
    this.onCanvasTap,
    this.backgroundColor,
  });

  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final GraphController? controller;
  final ValueChanged<GraphNode>? onNodeTap;
  final ValueChanged<GraphNode>? onNodeDoubleTap;
  final VoidCallback? onCanvasTap;
  final Color? backgroundColor;

  @override
  State<GraphCanvas> createState() => _GraphCanvasState();
}

// ---------------------------------------------------------------------------
// _GraphCanvasState
// ---------------------------------------------------------------------------

class _GraphCanvasState extends State<GraphCanvas> {
  late GraphController _controller;

  // Gesture state
  String? _highlightedNodeId;
  double _baseScale = 1.0;
  vm.Vector3 _baseTranslation = vm.Vector3.zero();
  Offset? _lastFocalPoint;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? GraphController();
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void didUpdateWidget(covariant GraphCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller.removeListener(_onControllerUpdate);
      _controller = widget.controller ?? GraphController();
      _controller.addListener(_onControllerUpdate);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onControllerUpdate() {
    setState(() {});
  }

  // -----------------------------------------------------------------------
  // Hit testing
  // -----------------------------------------------------------------------

  /// Returns the [GraphNode] at the given graph-space [point], or `null`.
  GraphNode? _hitTest(Offset point) {
    // Iterate in reverse so that nodes painted on top are tested first.
    for (int i = widget.nodes.length - 1; i >= 0; i--) {
      if (widget.nodes[i].rect.contains(point)) {
        return widget.nodes[i];
      }
    }
    return null;
  }

  /// Convert a screen-space [Offset] to graph-space.
  Offset _screenToGraph(Offset screen) {
    final v = _controller.screenToGraph(screen);
    return Offset(v.x, v.y);
  }

  // -----------------------------------------------------------------------
  // Gesture handlers
  // -----------------------------------------------------------------------

  void _onScaleStart(ScaleStartDetails details) {
    _lastFocalPoint = details.focalPoint;
    _baseScale = _controller.transform.getMaxScaleOnAxis();
    _baseTranslation = _controller.transform.getTranslation();
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount == 1) {
      // Single-finger drag → pan
      if (_lastFocalPoint != null) {
        final dx = details.focalPoint.dx - _lastFocalPoint!.dx;
        final dy = details.focalPoint.dy - _lastFocalPoint!.dy;
        _controller.applyTranslation(dx, dy);
        _lastFocalPoint = details.focalPoint;
      }
    } else if (details.pointerCount >= 2) {
      // Pinch-to-zoom
      final double newScale = _baseScale * details.scale;
      final double scaleFactor = newScale / _controller.transform.getMaxScaleOnAxis();
      if (scaleFactor != 1.0) {
        _controller.applyScale(scaleFactor, details.focalPoint);
      }
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _lastFocalPoint = null;
  }

  void _onTapDown(TapDownDetails details) {
    final graphPoint = _screenToGraph(details.localPosition);
    final hitNode = _hitTest(graphPoint);

    setState(() {
      _highlightedNodeId = hitNode?.id;
    });

    if (hitNode != null) {
      widget.onNodeTap?.call(hitNode);
    } else {
      widget.onCanvasTap?.call();
    }
  }

  void _onDoubleTapDown(TapDownDetails details) {
    final graphPoint = _screenToGraph(details.localPosition);
    final hitNode = _hitTest(graphPoint);

    if (hitNode != null) {
      widget.onNodeDoubleTap?.call(hitNode);
    }

    // Double-tap-to-zoom: scale 2× centered on tap point.
    _controller.applyScale(2.0, details.localPosition);
  }

  // -----------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final painter = GraphCanvasPainter(
      nodes: widget.nodes,
      edges: widget.edges,
      transform: _controller.transform,
      highlightedNodeId: _highlightedNodeId,
    );

    return Container(
      color: widget.backgroundColor ?? Colors.grey[50],
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _onTapDown,
        onDoubleTapDown: _onDoubleTapDown,
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        onScaleEnd: _onScaleEnd,
        child: CustomPaint(
          painter: painter,
          size: Size.infinite,
        ),
      ),
    );
  }
}
