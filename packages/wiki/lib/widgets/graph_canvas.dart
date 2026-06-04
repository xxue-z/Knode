import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import 'package:wiki/utils/graph_theme.dart';
import 'package:wiki/widgets/graph_edge.dart' show EdgeType;

// ---------------------------------------------------------------------------
// Data Models
// ---------------------------------------------------------------------------

/// Node type in the knowledge graph.
enum NodeType { category, article }

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
  Rect get rect =>
      Rect.fromCenter(center: position, width: width, height: height);
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
    this.type = EdgeType.reference,
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
    this.brightness = Brightness.light,
    this.rotation = 0.0,
    this.dockedNodes = const {},
    this.dockPositions = const {},
  });

  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final vm.Matrix4 transform;
  final String? highlightedNodeId;
  final List<Rect>? hitAreas;
  final Brightness brightness;
  final double rotation;

  /// Map of nodeId → whether the node is currently docked to an edge.
  final Map<String, bool> dockedNodes;

  /// Map of nodeId → screen-space position where the dock marker is drawn.
  final Map<String, Offset> dockPositions;

  // Cached look-up for fast node access.
  Map<String, GraphNode> _nodeMap = {};

  @override
  void paint(Canvas uiCanvas, Size size) {
    _nodeMap = {for (final n in nodes) n.id: n};

    // Save layer and apply the combined transform.
    uiCanvas.save();

    // Apply translation and scale
    final matrix4 = vm.Matrix4.compose(
      vm.Vector3(transform[3], transform[7], transform[11]),
      vm.Quaternion.identity(),
      vm.Vector3(transform[0], transform[5], transform[10]),
    );
    uiCanvas.transform(matrix4.storage);

    // Apply subtle 3D perspective simulation
    if (rotation.abs() > 0.001) {
      final centerX = size.width / 2;
      final centerY = size.height / 2;
      uiCanvas.translate(centerX, centerY);
      uiCanvas.rotate(rotation * 0.5);
      final skew = rotation * 0.15;
      final matrix = vm.Matrix4.identity()
        ..setEntry(3, 2, skew)
        ..setEntry(3, 3, 1.0 - skew.abs() * 0.5);
      uiCanvas.transform(matrix.storage);
      uiCanvas.translate(-centerX, -centerY);
    }

    _drawEdges(uiCanvas);
    _drawNodes(uiCanvas);

    uiCanvas.restore();
  }

  void _drawEdges(ui.Canvas canvas) {
    for (final edge in edges) {
      final source = _nodeMap[edge.sourceId];
      final target = _nodeMap[edge.targetId];
      if (source == null || target == null) continue;

      final start = source.position;
      final end = target.position;

      if (edge.type == EdgeType.reference) {
        _drawSolidEdge(canvas, start, end, edge);
      } else if (edge.type == EdgeType.tagSimilarity) {
        _drawDashedEdge(canvas, start, end, edge);
      } else {
        _drawDottedEdge(canvas, start, end, edge);
      }
    }
  }

  void _drawSolidEdge(
    ui.Canvas canvas,
    Offset start,
    Offset end,
    GraphEdge edge,
  ) {
    final paint = Paint()
      ..color = edge.color.withOpacity(0.8)
      ..strokeWidth = edge.width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(start, end, paint);

    if (edge.showArrow) {
      _drawArrowhead(canvas, start, end, edge.arrowSize, paint);
    }

    _drawEdgeLabel(canvas, start, end, edge);
  }

  void _drawDashedEdge(
    ui.Canvas canvas,
    Offset start,
    Offset end,
    GraphEdge edge,
  ) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    final dashLength = 8.0;
    final gapLength = 4.0;
    final totalLength = dashLength + gapLength;
    final numDashes = (distance / totalLength).floor();

    final paint = Paint()
      ..color = edge.color.withOpacity(edge.similarity ?? 0.5)
      ..strokeWidth = edge.width * 0.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < numDashes; i++) {
      final t1 = (i * totalLength) / distance;
      final t2 = (i * totalLength + dashLength) / distance;

      final p1 = Offset(start.dx + dx * t1, start.dy + dy * t1);
      final p2 = Offset(start.dx + dx * t2, start.dy + dy * t2);

      canvas.drawLine(p1, p2, paint);
    }

    _drawEdgeLabel(canvas, start, end, edge);
  }

  void _drawDottedEdge(
    ui.Canvas canvas,
    Offset start,
    Offset end,
    GraphEdge edge,
  ) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    final dotSpacing = 6.0;
    final numDots = (distance / dotSpacing).floor();

    final paint = Paint()
      ..color = edge.color.withOpacity(0.6)
      ..strokeWidth = edge.width * 0.6
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i <= numDots; i++) {
      final t = i / numDots;
      final p = Offset(start.dx + dx * t, start.dy + dy * t);
      canvas.drawCircle(p, 1.5, paint);
    }

    _drawEdgeLabel(canvas, start, end, edge);
  }

  void _drawEdgeLabel(
    ui.Canvas canvas,
    Offset start,
    Offset end,
    GraphEdge edge,
  ) {
    if (edge.label != null && edge.label!.isNotEmpty) {
      final mid = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
      final textPainter = TextPainter(
        text: TextSpan(
          text: edge.label,
          style: TextStyle(color: edge.color, fontSize: 11),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        mid - Offset(textPainter.width / 2, textPainter.height / 2),
      );
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
      final isDocked = dockedNodes[node.id] == true;

      if (isDocked) {
        _drawDockMarker(canvas, node);
      } else {
        final isHighlighted = node.id == highlightedNodeId;
        if (node.type == NodeType.category) {
          _drawCategoryNode(canvas, node, isHighlighted);
        } else {
          _drawArticleNode(canvas, node, isHighlighted);
        }
      }
    }
  }

  /// Draws a ） shaped arc marker for docked nodes at the screen edge.
  void _drawDockMarker(ui.Canvas canvas, GraphNode node) {
    final center = dockPositions[node.id] ?? node.position;
    final color = node.gradientColors?.last ?? node.color;

    // Arc shape
    final arcPaint = ui.Paint()
      ..color = color.withOpacity(0.7)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = ui.StrokeCap.round;

    final path = ui.Path()
      ..addArc(
        Rect.fromCenter(center: center, width: 16.0, height: 24.0),
        -math.pi / 3,
        math.pi * 2 / 3,
      );
    canvas.drawPath(path, arcPaint);

    // Dot next to arc
    final dotPaint = ui.Paint()
      ..color = color
      ..style = ui.PaintingStyle.fill;
    canvas.drawCircle(center + const Offset(4, 0), 2.0, dotPaint);
  }

  void _drawCategoryNode(ui.Canvas canvas, GraphNode node, bool isHighlighted) {
    final center = node.position;
    final radius = node.width / 2;

    // Outer glow for highlighted nodes
    if (isHighlighted) {
      final glowPaint = Paint()
        ..color = (node.gradientColors?.last ?? node.color).withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(center, radius + 8, glowPaint);
    }

    // Gradient fill
    final colors =
        node.gradientColors ?? [node.color, node.color.withOpacity(0.7)];
    final stops = colors.length == 1
        ? [0.0]
        : [for (int i = 0; i < colors.length; i++) i / (colors.length - 1)];
    final gradient = RadialGradient(colors: colors, stops: stops);
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );
    canvas.drawCircle(center, radius, paint);

    // Border
    final borderPaint = Paint()
      ..color = isHighlighted ? Colors.amber : Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isHighlighted ? 3.0 : 1.5;
    canvas.drawCircle(center, radius, borderPaint);

    // Label
    _drawNodeLabel(canvas, node, center, isHighlighted);
  }

  void _drawArticleNode(ui.Canvas canvas, GraphNode node, bool isHighlighted) {
    final center = node.position;
    final radius = node.width / 2;

    // Outer glow ring
    if (isHighlighted) {
      final glowPaint = Paint()
        ..color = node.color.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(center, radius + 6, glowPaint);
    }

    // Outer ring (halo)
    final outerPaint = Paint()
      ..color = node.color.withOpacity(isHighlighted ? 0.6 : 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, outerPaint);

    // Inner solid circle
    final innerPaint = Paint()..color = node.color;
    canvas.drawCircle(center, radius * 0.6, innerPaint);

    // Border
    final borderPaint = Paint()
      ..color = isHighlighted ? Colors.amber : Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isHighlighted ? 2.5 : 1.0;
    canvas.drawCircle(center, radius * 0.6, borderPaint);

    // Label
    _drawNodeLabel(canvas, node, center, isHighlighted);
  }

  void _drawNodeLabel(
    ui.Canvas canvas,
    GraphNode node,
    Offset center,
    bool isHighlighted,
  ) {
    // Main label
    final labelPainter = TextPainter(
      text: TextSpan(
        text: node.label,
        style: TextStyle(
          color: Colors.white,
          fontSize: node.fontSize,
          fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
          shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
        ),
      ),
      textDirection: ui.TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: node.width * 2);

    labelPainter.paint(
      canvas,
      Offset(
        center.dx - labelPainter.width / 2,
        center.dy + node.height / 2 + 8,
      ),
    );

    // Tags (truncated to 6-8 chars + ellipsis)
    if (node.tags.isNotEmpty) {
      final tagText = node.tags
          .take(2)
          .map((t) => t.length > 8 ? '\...' : t)
          .join(', ');
      final tagPainter = TextPainter(
        text: TextSpan(
          text: tagText,
          style: TextStyle(
            color: Colors.white70,
            fontSize: node.fontSize * 0.75,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: node.width * 2);

      tagPainter.paint(
        canvas,
        Offset(
          center.dx - tagPainter.width / 2,
          center.dy + node.height / 2 + 8 + labelPainter.height + 2,
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
        oldDelegate.rotation != rotation ||
        !listEquals(oldDelegate.nodes, nodes) ||
        !listEquals(oldDelegate.edges, edges) ||
        !mapEquals(oldDelegate.dockedNodes, dockedNodes) ||
        !mapEquals(oldDelegate.dockPositions, dockPositions);
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
  double _rotation = 0.0;

  vm.Matrix4 get transform => _transform;
  double get rotation => _rotation;

  set transform(vm.Matrix4 value) {
    _transform = value;
    notifyListeners();
  }

  void applyTranslation(double dx, double dy) {
    _transform = _transform.clone()..translate(dx, dy);
    notifyListeners();
  }

  void applyScale(double scale, Offset focalPoint) {
    final double clampedScale = scale.clamp(0.1, 10.0);
    _transform = _transform.clone()
      ..translate(focalPoint.dx, focalPoint.dy)
      ..scale(clampedScale)
      ..translate(-focalPoint.dx, -focalPoint.dy);
    notifyListeners();
  }

  void applyRotation(double angle) {
    _rotation = (_rotation + angle).clamp(-0.5, 0.5);
    notifyListeners();
  }

  void reset() {
    _transform = vm.Matrix4.identity();
    _rotation = 0.0;
    notifyListeners();
  }

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
    this.brightness = Brightness.light,
    this.rotation = 0.0,
  });

  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final GraphController? controller;
  final ValueChanged<GraphNode>? onNodeTap;
  final ValueChanged<GraphNode>? onNodeDoubleTap;
  final VoidCallback? onCanvasTap;
  final Color? backgroundColor;
  final Brightness brightness;
  final double rotation;

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
  double _lastRotation = 0.0;

  // Edge docking state
  static const double _edgeThreshold = 30.0;
  final Map<String, bool> _dockedNodes = {};
  final Map<String, Offset> _dockPositions = {};

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
  // Edge docking
  // -----------------------------------------------------------------------

  /// Whether [position] is within [_edgeThreshold] pixels of any screen edge.
  bool isNearEdge(Offset position, Size screenSize) {
    return position.dx < _edgeThreshold ||
        position.dx > screenSize.width - _edgeThreshold ||
        position.dy < _edgeThreshold ||
        position.dy > screenSize.height - _edgeThreshold;
  }

  /// Clamp [position] to within [_edgeThreshold] of the screen bounds.
  Offset getDockPosition(Offset position, Size screenSize) {
    return Offset(
      position.dx.clamp(_edgeThreshold, screenSize.width - _edgeThreshold),
      position.dy.clamp(_edgeThreshold, screenSize.height - _edgeThreshold),
    );
  }

  void _updateDockState(Offset focalPoint, Size screenSize) {
    for (final node in widget.nodes) {
      final nodeScreen = _controller.screenToGraph(focalPoint);
      final nodePos = Offset(nodeScreen.x, nodeScreen.y);
      if (isNearEdge(nodePos, screenSize)) {
        if (!_dockedNodes.containsKey(node.id)) {
          _dockedNodes[node.id] = true;
          _dockPositions[node.id] = getDockPosition(nodePos, screenSize);
        }
      } else {
        _dockedNodes.remove(node.id);
        _dockPositions.remove(node.id);
      }
    }
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
      final double scaleFactor =
          newScale / _controller.transform.getMaxScaleOnAxis();
      if (scaleFactor != 1.0) {
        _controller.applyScale(scaleFactor, details.focalPoint);
      }

      // Two-finger rotation
      final double rotationDelta = details.rotation - _lastRotation;
      if (rotationDelta.abs() > 0.001) {
        _controller.applyRotation(rotationDelta);
        _lastRotation = details.rotation;
      }

      // Update edge docking
      final screenSize = MediaQuery.of(context).size;
      _updateDockState(details.focalPoint, screenSize);
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _lastFocalPoint = null;
    _lastRotation = 0.0;
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
      brightness: widget.brightness,
      rotation: _controller.rotation,
      dockedNodes: _dockedNodes,
      dockPositions: _dockPositions,
    );

    final bgColors = GraphTheme.getBackground(widget.brightness);
    final starColor = GraphTheme.getStarColor(widget.brightness);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.backgroundColor != null
              ? [widget.backgroundColor!, widget.backgroundColor!]
              : bgColors,
        ),
      ),
      child: CustomPaint(
        painter: _StarPainter(color: starColor, starCount: 200),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _onTapDown,
          onDoubleTapDown: _onDoubleTapDown,
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onScaleEnd: _onScaleEnd,
          child: CustomPaint(painter: painter, size: Size.infinite),
        ),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  _StarPainter({required this.color, required this.starCount});
  final Color color;
  final int starCount;
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    for (int i = 0; i < starCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5 + 0.5;
      final opacity = random.nextDouble() * 0.5 + 0.3;
      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter old) =>
      old.color != color || old.starCount != starCount;
}
