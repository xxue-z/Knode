import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:knode_app/providers/chat_ball_provider.dart';
import 'package:knode_app/widgets/chat_ball_style.dart';
import 'package:knode_app/widgets/chat_panel.dart';
import 'package:knode_app/widgets/voice_panel.dart';
import 'package:chat/screens/chat_page.dart';

class FloatingChatBall extends ConsumerStatefulWidget {
  const FloatingChatBall({super.key});
  @override
  ConsumerState<FloatingChatBall> createState() => _FloatingChatBallState();
}

class _FloatingChatBallState extends ConsumerState<FloatingChatBall>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isLongPressing = false;
  bool _isDragging = false;
  Timer? _doubleTapTimer;
  DateTime? _lastTapTime;
  final GlobalKey _ballKey = GlobalKey();
  OverlayEntry? _panelOverlay;
  AnimationController? _panelAnimController;
  Animation<double>? _panelScaleAnimation;
  Animation<double>? _panelOpacityAnimation;
  double _edgeOffset = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500), vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    Future.microtask(() {
      ref.read(chatBallNotifierProvider.notifier).restoreState();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _panelAnimController?.dispose();
    _panelOverlay?.remove();
    _doubleTapTimer?.cancel();
    super.dispose();
  }

  // ---- Edge detection ----
  void _updateEdgeOffset(Offset position) {
    final size = MediaQuery.of(context).size;
    const ballRadius = 28.0;
    const edgeThreshold = 8.0;
    final leftEdge = position.dx;
    final rightEdge = size.width - position.dx - ballRadius * 2;
    final minEdge = math.min(leftEdge, rightEdge);
    setState(() {
      _edgeOffset = minEdge < edgeThreshold
          ? (ballRadius - minEdge).clamp(0.0, ballRadius)
          : 0;
    });
  }

  // ---- Tap ----
  void _onTapDown(TapDownDetails details) {}

  void _onTapUp(TapUpDetails details) {
    if (_isLongPressing || _isDragging) return;
    final now = DateTime.now();
    final lastTap = _lastTapTime;
    if (lastTap != null && now.difference(lastTap).inMilliseconds < 300) {
      _doubleTapTimer?.cancel();
      _doubleTapTimer = null;
      _lastTapTime = null;
      _onDoubleTap();
    } else {
      _lastTapTime = now;
      _doubleTapTimer?.cancel();
      _doubleTapTimer = Timer(const Duration(milliseconds: 300), () {
        if (_lastTapTime == now) _onSingleTap();
      });
    }
  }

  void _onSingleTap() {
    if (_isLongPressing || _isDragging) return;
    ref.read(chatBallNotifierProvider.notifier).setHasUnread(false);
    _showPanelOverlay();
  }

  void _onLongPressStart(LongPressStartDetails details) {
    if (_isDragging) return;
    setState(() => _isLongPressing = true);
    _doubleTapTimer?.cancel();
    _showVoicePanel();
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    setState(() => _isLongPressing = false);
  }

  void _onDoubleTap() {
    if (_isLongPressing || _isDragging) return;
    _closePanelOverlay();
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatPage()));
  }

  // ---- Voice ----
  void _showVoicePanel() {
    showDialog(
      context: context,
      builder: (context) => VoicePanel(
        onSend: () => Navigator.pop(context),
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  // ---- Panel overlay ----
  void _showPanelOverlay() {
    if (_panelOverlay != null) { _closePanelOverlay(); return; }
    final screenSize = MediaQuery.of(context).size;
    final panelWidth = screenSize.width - 32.0;
    final panelLeft = (screenSize.width - panelWidth) / 2;
    _panelAnimController = AnimationController(
      duration: const Duration(milliseconds: 250), vsync: this,
    );
    _panelScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _panelAnimController!, curve: Curves.easeOutBack),
    );
    _panelOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _panelAnimController!, curve: Curves.easeOut),
    );
    _panelOverlay = OverlayEntry(
      builder: (_) => _PanelOverlayWidget(
        panelLeft: panelLeft,
        panelWidth: panelWidth,
        scaleAnimation: _panelScaleAnimation!,
        opacityAnimation: _panelOpacityAnimation!,
        onClose: _closePanelOverlay,
        onFullScreen: () {
          _closePanelOverlay();
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatPage()));
        },
      ),
    );
    Overlay.of(context).insert(_panelOverlay!);
    _panelAnimController!.forward();
  }

  void _closePanelOverlay() {
    _panelOverlay?.remove();
    _panelOverlay = null;
    _panelAnimController?.dispose();
    _panelAnimController = null;
  }

  // ---- Drag ----
  void _onPanStart(DragStartDetails details) { _isDragging = true; }

  void _onPanUpdate(DragUpdateDetails details) {
    final current = ref.read(chatBallNotifierProvider).position;
    final screenSize = MediaQuery.of(context).size;
    const ballSize = 56.0;
    double newX = (current.dx + details.delta.dx).clamp(0, screenSize.width - ballSize);
    double newY = (current.dy + details.delta.dy).clamp(0, screenSize.height - ballSize - 80);
    final newPos = Offset(newX, newY);
    ref.read(chatBallNotifierProvider.notifier).updatePosition(newPos);
    _updateEdgeOffset(newPos);
  }

  void _onPanEnd(DragEndDetails details) {
    _isDragging = false;
    final state = ref.read(chatBallNotifierProvider);
    final screenSize = MediaQuery.of(context).size;
    const ballSize = 56.0;
    double targetX = state.position.dx < screenSize.width / 2
        ? 0
        : screenSize.width - ballSize;
    _snapToEdge(state.position, Offset(targetX, state.position.dy));
  }

  void _snapToEdge(Offset from, Offset to) {
    final controller = AnimationController(
      duration: const Duration(milliseconds: 200), vsync: this,
    );
    final animation = Tween<Offset>(begin: from, end: to).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );
    animation.addListener(() {
      ref.read(chatBallNotifierProvider.notifier).updatePosition(animation.value);
    });
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
        ref.read(chatBallNotifierProvider.notifier).savePosition();
        _updateEdgeOffset(to);
      }
    });
    controller.forward();
  }

  // ---- Build ----
  Widget _buildBall(ChatBallStyle style) {
    return Container(
      key: _ballKey,
      width: style.size,
      height: style.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: style.gradient,
        color: style.gradient == null ? style.backgroundColor : null,
        boxShadow: style.boxShadow != null ? [style.boxShadow!] : null,
      ),
      child: Icon(style.icon, color: style.iconColor, size: style.size * 0.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatBallState = ref.watch(chatBallNotifierProvider);
    final style = ChatBallStyle.fromName(chatBallState.style);

    if (chatBallState.hasUnread) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }

    final ball = Stack(
      alignment: Alignment.center,
      children: [
        if (chatBallState.hasUnread)
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) => Transform.scale(
              scale: _pulseAnimation.value,
              child: child,
            ),
            child: Container(
              width: style.size,
              height: style.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: style.backgroundColor.withValues(alpha: 0.3),
              ),
            ),
          ),
        _buildBall(style),
      ],
    );

    final needsClip = _edgeOffset > 0;
    Widget child = ball;
    if (needsClip) {
      child = ClipRect(
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: style.size + _edgeOffset,
          height: style.size,
          child: Align(alignment: Alignment.centerRight, child: ball),
        ),
      );
    }

    return Positioned(
      left: chatBallState.position.dx - _edgeOffset,
      top: chatBallState.position.dy,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onLongPressStart: _onLongPressStart,
        onLongPressEnd: _onLongPressEnd,
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: child,
      ),
    );
  }
}

class _PanelOverlayWidget extends StatelessWidget {
  const _PanelOverlayWidget({
    required this.panelLeft,
    required this.panelWidth,
    required this.scaleAnimation,
    required this.opacityAnimation,
    required this.onClose,
    required this.onFullScreen,
  });

  final double panelLeft;
  final double panelWidth;
  final Animation<double> scaleAnimation;
  final Animation<double> opacityAnimation;
  final VoidCallback onClose;
  final VoidCallback onFullScreen;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final panelHeight = (screenHeight * 0.5).clamp(200.0, 500.0).toDouble();
    final actualTop = (screenHeight - panelHeight) / 2;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            behavior: HitTestBehavior.translucent,
            child: Container(color: Colors.black26),
          ),
        ),
        Positioned(
          left: panelLeft,
          top: actualTop,
          width: panelWidth,
          child: AnimatedBuilder(
            animation: Listenable.merge([scaleAnimation, opacityAnimation]),
            builder: (context, child) => Transform.scale(
              scale: scaleAnimation.value,
              alignment: Alignment.center,
              child: Opacity(opacity: opacityAnimation.value, child: child),
            ),
            child: ChatPanel(onFullScreen: onFullScreen, onClose: onClose),
          ),
        ),
      ],
    );
  }
}
