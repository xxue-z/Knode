import 'dart:math' as math;
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Edge Type
// ---------------------------------------------------------------------------

/// Relationship types between knowledge-graph nodes.
enum EdgeType {
  /// Solid blue line -- explicit reference link between articles.
  reference,

  /// Dashed green line -- Jaccard tag similarity above threshold.
  tagSimilarity,

  /// Dotted orange line -- same-category clustering.
  categoryCluster,
}

// ---------------------------------------------------------------------------
// Edge Data
// ---------------------------------------------------------------------------

/// Immutable data model for a single graph edge.
class GraphEdgeData {
  /// Creates a [GraphEdgeData] instance.
  const GraphEdgeData({
    required this.sourceNodeId,
    required this.targetNodeId,
    required this.edgeType,
    this.similarity,
  });

  /// Unique identifier of the source node.
  final String sourceNodeId;

  /// Unique identifier of the target node.
  final String targetNodeId;

  /// Relationship type that determines visual style.
  final EdgeType edgeType;

  /// Optional similarity score (e.g. Jaccard coefficient).
  final double? similarity;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraphEdgeData &&
          runtimeType == other.runtimeType &&
          sourceNodeId == other.sourceNodeId &&
          targetNodeId == other.targetNodeId;

  @override
  int get hashCode => Object.hash(sourceNodeId, targetNodeId);
}

// ---------------------------------------------------------------------------
// Edge Style
// ---------------------------------------------------------------------------

/// Visual style properties mapped to an [EdgeType].
class EdgeStyle {
  /// Creates an [EdgeStyle].
  const EdgeStyle({
    required this.color,
    required this.strokeWidth,
    required this.dashPattern,
  });

  /// Stroke colour for the edge.
  final Color color;

  /// Width of the stroke in logical pixels.
  final double strokeWidth;

  /// Dash pattern: dashLength, gapLength. An empty list means solid.
  final List<double> dashPattern;

  /// Solid blue (#2196F3) for reference edges.
  static const EdgeStyle reference = EdgeStyle(
    color: Color(0xFF2196F3),
    strokeWidth: 2.0,
    dashPattern: [],
  );

  /// Dashed green (#4CAF50) for tag-similarity edges.
  static const EdgeStyle tagSimilarity = EdgeStyle(
    color: Color(0xFF4CAF50),
    strokeWidth: 1.5,
    dashPattern: [6.0, 4.0],
  );

  /// Dotted orange (#FF9800) for category-cluster edges.
  static const EdgeStyle categoryCluster = EdgeStyle(
    color: Color(0xFFFF9800),
    strokeWidth: 1.2,
    dashPattern: [2.0, 4.0],
  );

  /// Returns the built-in [EdgeStyle] for [type].
  static EdgeStyle forType(EdgeType type) {
    switch (type) {
      case EdgeType.reference:
        return reference;
      case EdgeType.tagSimilarity:
        return tagSimilarity;
      case EdgeType.categoryCluster:
        return categoryCluster;
    }
  }
}// ---------------------------------------------------------------------------
// Painter
// ---------------------------------------------------------------------------

/// CustomPainter that draws a single graph edge on a [Canvas].
///
/// Supports straight lines and cubic Bezier curves depending on the relative
/// positions of the two endpoints. Dashed / dotted patterns are drawn via
/// manual dash-offset bookkeeping so that every platform renders identically.
class GraphEdgePainter extends CustomPainter {
  /// Creates a [GraphEdgePainter].
  ///
  /// [from] and [to] are the screen-space offsets of the source and target
  /// nodes respectively. [style] controls visual appearance.
  GraphEdgePainter({
    required this.from,
    required this.to,
    required this.style,
    this.similarity,
  });

  /// Start point of the edge.
  final Offset from;

  /// End point of the edge.
  final Offset to;

  /// Visual style applied to this edge.
  final EdgeStyle style;

  /// Optional similarity score displayed along the edge.
  final double? similarity;

  bool get _isStraight => (to - from).distance <= 1.0;

  List<Offset> _controlPoints() {
    final mid = Offset.lerp(from, to, 0.5)!;
    final delta = to - from;
    final perp = Offset(-delta.dy, delta.dx);
    final half = delta.distance * 0.15;
    final factor = half / delta.distance;
    final ctrl1 = mid + perp * factor;
    final ctrl2 = mid - perp * factor;
    return [ctrl1, ctrl2];
  }

  double _pathLength() {
    if (_isStraight) return (to - from).distance;
    final cp = _controlPoints();
    const int segments = 16;
    double length = 0;
    Offset prev = from;
    for (int i = 1; i <= segments; i++) {
      final t = i / segments;
      final point = _cubicBezierPoint(t, from, cp[0], cp[1], to);
      length += (point - prev).distance;
      prev = point;
    }
    return length;
  }

  static Offset _cubicBezierPoint(
    double t,
    Offset p0,
    Offset p1,
    Offset p2,
    Offset p3,
  ) {
    final u = 1 - t;
    final tt = t * t;
    final uu = u * u;
    final uuu = uu * u;
    final ttt = tt * t;
    return p0 * uuu +
        p1 * (3 * uu * t) +
        p2 * (3 * u * tt) +
        p3 * ttt;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = style.color
      ..strokeWidth = style.strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (style.dashPattern.isEmpty) {
      _drawSolidLine(canvas, paint);
    } else {
      _drawDashedPath(canvas, paint);
    }
  }

  void _drawSolidLine(Canvas canvas, Paint paint) {
    if (_isStraight) {
      canvas.drawLine(from, to, paint);
      return;
    }
    final path = Path()..moveTo(from.dx, from.dy);
    final cp = _controlPoints();
    path.cubicTo(cp[0].dx, cp[0].dy, cp[1].dx, cp[1].dy, to.dx, to.dy);
    canvas.drawPath(path, paint);
  }

  void _drawDashedPath(Canvas canvas, Paint paint) {
    final dashLen = style.dashPattern[0];
    final gapLen = style.dashPattern[1];

    final totalLen = _pathLength();
    final int totalSegments = (totalLen / dashLen).ceil();
    final isStraight = _isStraight;
    final cp = isStraight ? <Offset>[] : _controlPoints();

    double traveled = 0;
    bool drawing = true;

    for (int i = 0; i < totalSegments && traveled < totalLen; i++) {
      final startFrac = traveled / totalLen;
      final endFrac = (traveled + (drawing ? dashLen : gapLen)) / totalLen;
      final clampedEnd = endFrac.clamp(0.0, 1.0);

      if (drawing) {
        final p0 = _pointOnPath(startFrac, isStraight, cp);
        final p1 = _pointOnPath(clampedEnd, isStraight, cp);
        canvas.drawLine(p0, p1, paint);
      }

      traveled += drawing ? dashLen : gapLen;
      drawing = !drawing;
    }
  }

  Offset _pointOnPath(double frac, bool isStraight, List<Offset> cp) {
    if (isStraight) return Offset.lerp(from, to, frac)!;
    return _cubicBezierPoint(frac, from, cp[0], cp[1], to);
  }

  @override
  bool hitTest(Offset position) {
    const double tolerance = 8.0;
    if (_isStraight) {
      return _distanceToSegment(position) <= tolerance;
    }
    const int samples = 32;
    double minDist = double.infinity;
    final cp = _controlPoints();
    for (int i = 0; i <= samples; i++) {
      final t = i / samples;
      final point = _cubicBezierPoint(t, from, cp[0], cp[1], to);
      minDist = math.min(minDist, (position - point).distance);
    }
    return minDist <= tolerance;
  }

  double _distanceToSegment(Offset p) {
    final d = to - from;
    final lenSq = d.distanceSquared;
    if (lenSq == 0) return (p - from).distance;
    final t = ((p - from).dx * d.dx + (p - from).dy * d.dy) / lenSq;
    final tClamped = t.clamp(0.0, 1.0);
    final projection = from + d * tClamped;
    return (p - projection).distance;
  }

  @override
  bool shouldRepaint(covariant GraphEdgePainter oldDelegate) =>
      from != oldDelegate.from ||
      to != oldDelegate.to ||
      style != oldDelegate.style ||
      similarity != oldDelegate.similarity;
}