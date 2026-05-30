import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// A gesture controller for a knowledge-graph canvas.
///
/// Manages pan, pinch-to-zoom, and inertial momentum scrolling backed by
/// [Matrix4] transforms.  Supply a [TickerProvider] (typically a
/// [State] that mixes in [TickerProviderStateMixin]) as [vsync].
///
/// ```dart
/// class _GraphPageState extends State<GraphPage>
///     with TickerProviderStateMixin {
///   late final _controller = GraphController(vsync: this);
///
///   @override
///   Widget build(BuildContext context) {
///     return AnimatedBuilder(
///       animation: _controller,
///       builder: (context, _) => Transform(
///         transform: _controller.transformationMatrix,
///         child: /* your graph nodes */,
///       ),
///     );
///   }
/// }
/// ```
class GraphController extends ChangeNotifier {
  late final Ticker _ticker;

  GraphController({required TickerProvider vsync}) {
    _ticker = vsync.createTicker(_onTick);
  }

  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  /// Hard clamp applied to both axes of the pan offset.
  static const double _maxOffset = 5000.0;

  /// Minimum zoom factor.
  static const double minScale = 0.1;

  /// Maximum zoom factor.
  static const double maxScale = 5.0;

  /// Friction coefficient applied to inertia velocity each frame.
  static const double _friction = 0.95;

  /// Threshold below which inertia is stopped entirely.
  static const double _velocityThreshold = 0.5;

  // ---------------------------------------------------------------------------
  // Internal state
  // ---------------------------------------------------------------------------

  double _scale = 1.0;
  Offset _offset = Offset.zero;

  /// Velocity accumulator for inertia.
  Offset _velocity = Offset.zero;

  bool _isScaling = false;

  // ---------------------------------------------------------------------------
  // Public read-only accessors
  // ---------------------------------------------------------------------------

  /// Current uniform scale factor.
  double get currentScale => _scale;

  /// Current translation offset in logical pixels.
  Offset get currentOffset => _offset;

  /// Full [Matrix4] combining scale and translation.
  ///
  /// This is suitable for passing directly to [Transform.transform].
  Matrix4 get transformationMatrix {
    final Matrix4 matrix = Matrix4.identity()
      ..scale(_scale, _scale)
      ..translate(_offset.dx, _offset.dy);
    return matrix;
  }

  // ---------------------------------------------------------------------------
  // Gesture recognisers – created lazily on attach
  // ---------------------------------------------------------------------------

  late final ScaleGestureRecognizer _scaleRecognizer;
  late final PanGestureRecognizer _panRecognizer;

  /// Attach gesture recognisers to the given [RenderBox].
  ///
  /// Call this once the canvas render object is available (e.g. inside
  /// a [Listener] or a [RawGestureDetector] setup).
  void attachTo(RenderBox box) {
    _scaleRecognizer = ScaleGestureRecognizer()
      ..onStart = _onScaleStart
      ..onUpdate = _onScaleUpdate
      ..onEnd = _onScaleEnd;

    _panRecognizer = PanGestureRecognizer()
      ..onStart = _onPanStart
      ..onUpdate = _onPanUpdate
      ..onEnd = _onPanEnd;
  }

  // ---------------------------------------------------------------------------
  // Gesture callbacks
  // ---------------------------------------------------------------------------

  // -- Pinch-to-zoom ----------------------------------------------------------

  Offset _scaleFocalPoint = Offset.zero;
  double _preScale = 1.0;
  Offset _preOffset = Offset.zero;

  void _onScaleStart(ScaleStartDetails details) {
    _stopInertia();
    _isScaling = true;
    _preScale = _scale;
    _preOffset = _offset;
    _scaleFocalPoint = details.focalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount < 2) return;

    final double newScale = (_preScale * details.scale).clamp(minScale, maxScale);

    // Guard against degenerate focal point on first frame.
    final Offset focal = details.focalPoint;
    if (_scaleFocalPoint == Offset.zero) {
      _scaleFocalPoint = focal;
    }

    // Anchor the zoom around the focal point:
    //   newOffset = focalPoint - (focalPoint - preOffset) * (newScale / preScale)
    final double scaleRatio = _safeDivide(newScale, _preScale);
    final Offset newOffset =
        focal - (_scaleFocalPoint - _preOffset) * scaleRatio;

    _scale = newScale;
    _offset = _clampOffset(newOffset);
    notifyListeners();
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _isScaling = false;

    if (details.pointerCount > 1) {
      // Multi-finger lift – start inertia from the scale velocity.
      _velocity = details.velocity.pixelsPerSecond / _safeScale();
      _startInertia();
    }
  }

  // -- Single-finger drag -----------------------------------------------------

  Offset _panStartPosition = Offset.zero;

  void _onPanStart(DragStartDetails details) {
    // Ignore pan if a scale gesture is active.
    if (_isScaling) return;
    _stopInertia();
    _panStartPosition = _offset;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isScaling) return;
    _offset = _clampOffset(_panStartPosition + details.delta);
    notifyListeners();
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isScaling) return;
    _velocity = details.velocity.pixelsPerSecond;
    _startInertia();
  }

  // ---------------------------------------------------------------------------
  // Inertia animation
  // ---------------------------------------------------------------------------

  Duration _lastTickTime = Duration.zero;

  void _startInertia() {
    if (_velocity == Offset.zero) return;
    _lastTickTime = Duration.zero;
    if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  void _stopInertia() {
    _velocity = Offset.zero;
    if (_ticker.isActive) {
      _ticker.stop();
    }
  }

  void _onTick(Duration elapsed) {
    // Compute dt from the last frame.
    final double dt =
        _lastTickTime == Duration.zero ? 0.0 : (elapsed - _lastTickTime).inMicroseconds / 1e6;
    _lastTickTime = elapsed;

    // Early exit when velocity is negligible.
    if (_velocity.distance <= _velocityThreshold) {
      _stopInertia();
      notifyListeners();
      return;
    }

    // Apply friction decay.
    final Offset decayedVelocity = _velocity * math.pow(_friction, dt * 60).toDouble();
    _velocity = decayedVelocity;

    // Integrate.
    _offset = _clampOffset(_offset + decayedVelocity * dt);

    // Stop ticker explicitly if friction killed the velocity.
    if (_velocity.distance <= _velocityThreshold) {
      _stopInertia();
    }

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Public commands
  // ---------------------------------------------------------------------------

  /// Reset the canvas to the default scale and origin.
  void resetView() {
    _stopInertia();
    _scale = 1.0;
    _offset = Offset.zero;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _stopInertia();
    _ticker.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Clamp the offset to within [-_maxOffset, +_maxOffset] on both axes.
  /// Also sanitises NaN / Infinite values.
  Offset _clampOffset(Offset raw) {
    if (raw.dx.isNaN || raw.dx.isInfinite || raw.dy.isNaN || raw.dy.isInfinite) {
      return Offset.zero;
    }
    return Offset(
      raw.dx.clamp(-_maxOffset, _maxOffset),
      raw.dy.clamp(-_maxOffset, _maxOffset),
    );
  }

  /// Safe division that returns 1.0 when [b] is zero.
  static double _safeDivide(double a, double b) => b == 0.0 ? 1.0 : a / b;

  /// Current scale guard – returns 1.0 if somehow zero.
  double _safeScale() => _scale == 0.0 ? 1.0 : _scale;
}
