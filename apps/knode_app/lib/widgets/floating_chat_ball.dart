import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:knode_app/providers/chat_ball_provider.dart';
import 'package:knode_app/widgets/chat_ball_style.dart';
import 'package:knode_app/widgets/chat_panel.dart';
import 'package:knode_app/widgets/voice_panel.dart';
import 'package:chat/screens/chat_page.dart';

/// 全局悬浮球组件
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

  // Panel overlay state
  final GlobalKey _ballKey = GlobalKey();
  OverlayEntry? _panelOverlay;
  AnimationController? _panelAnimController;
  Animation<double>? _panelScaleAnimation;
  Animation<double>? _panelOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 恢复状态
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

  // -----------------------------------------------------------------------
  // Ball position helper
  // -----------------------------------------------------------------------

  Offset _getBallScreenPosition() {
    final box = _ballKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return Offset.zero;
    return box.localToGlobal(Offset.zero);
  }

  // -----------------------------------------------------------------------
  // Tap handling
  // -----------------------------------------------------------------------

  void _onTapDown(TapDownDetails details) {}

  void _onTapUp(TapUpDetails details) {
    if (_isLongPressing || _isDragging) return;

    final now = DateTime.now();
    final lastTap = _lastTapTime;

    if (lastTap != null && now.difference(lastTap).inMilliseconds < 300) {
      // 双击
      _doubleTapTimer?.cancel();
      _doubleTapTimer = null;
      _lastTapTime = null;
      _onDoubleTap();
    } else {
      // 可能是单击，等待300ms确认不是双击
      _lastTapTime = now;
      _doubleTapTimer?.cancel();
      _doubleTapTimer = Timer(const Duration(milliseconds: 300), () {
        if (_lastTapTime == now) {
          _onSingleTap();
        }
      });
    }
  }

  void _onSingleTap() {
    if (_isLongPressing || _isDragging) return;

    // 清除未读状态
    ref.read(chatBallNotifierProvider.notifier).setHasUnread(false);

    // 从悬浮球位置展开气泡式窗口
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

    // 关闭半屏窗口
    _closePanelOverlay();

    // 导航到完整Chat页面
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatPage()),
    );
  }

  // -----------------------------------------------------------------------
  // Voice panel
  // -----------------------------------------------------------------------

  void _showVoicePanel() {
    showDialog(
      context: context,
      builder: (context) => VoicePanel(
        onSend: () {
          Navigator.pop(context);
        },
        onCancel: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Panel overlay – anchored to ball position, expands upward
  // -----------------------------------------------------------------------

  void _showPanelOverlay() {
    // 如果已打开则关闭
    if (_panelOverlay != null) {
      _closePanelOverlay();
      return;
    }

    final ballPos = _getBallScreenPosition();
    final screenSize = MediaQuery.of(context).size;
    final ballSize = 56.0;

    // 悬浮球中心 X
    final ballCenterX = ballPos.dx + ballSize / 2;

    // 面板宽度：屏幕宽度减去两侧边距
    final panelWidth = screenSize.width - 32.0;
    // 面板左边界：以球为中心居中，但不超出屏幕
    var panelLeft = ballCenterX - panelWidth / 2;
    panelLeft = panelLeft.clamp(16.0, screenSize.width - panelWidth - 16.0);

    // 面板顶部：悬浮球上方留 12px 间距
    final panelTop = ballPos.dy - 12.0;

    // 初始化动画控制器
    _panelAnimController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _panelScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _panelAnimController!, curve: Curves.easeOutBack),
    );

    _panelOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _panelAnimController!, curve: Curves.easeOut),
    );

    _panelOverlay = OverlayEntry(
      builder: (context) => _PanelOverlayWidget(
        ballPosition: ballPos,
        ballSize: ballSize,
        panelLeft: panelLeft,
        panelTop: panelTop,
        panelWidth: panelWidth,
        scaleAnimation: _panelScaleAnimation!,
        opacityAnimation: _panelOpacityAnimation!,
        onClose: _closePanelOverlay,
        onFullScreen: () {
          _closePanelOverlay();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatPage()),
          );
        },
      ),
    );

    Overlay.of(context).insert(_panelOverlay!);
    _panelAnimController!.forward();
  }

  void _closePanelOverlay() {
    if (_panelAnimController != null && _panelAnimController!.isAnimating) {
      return;
    }

    if (_panelAnimController != null) {
      _panelAnimController!.reverse().then((_) {
        _panelOverlay?.remove();
        _panelOverlay = null;
        _panelAnimController?.dispose();
        _panelAnimController = null;
      });
    } else {
      _panelOverlay?.remove();
      _panelOverlay = null;
    }
  }

  // -----------------------------------------------------------------------
  // Drag handling
  // -----------------------------------------------------------------------

  void _onPanStart(DragStartDetails details) {
    setState(() => _isDragging = true);
    _doubleTapTimer?.cancel();
    _lastTapTime = null;
    // 拖拽时关闭面板
    if (_panelOverlay != null) {
      _closePanelOverlay();
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final newPosition =
        ref.read(chatBallNotifierProvider).position + details.delta;

    // 边界约束
    final screenSize = MediaQuery.of(context).size;
    final ballSize = 56.0;
    final bottomOffset = 80.0;

    final clampedX = newPosition.dx.clamp(0.0, screenSize.width - ballSize);
    final clampedY = newPosition.dy.clamp(
      0.0,
      screenSize.height - ballSize - bottomOffset,
    );

    ref
        .read(chatBallNotifierProvider.notifier)
        .updatePosition(Offset(clampedX, clampedY));
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() => _isDragging = false);
    _snapToEdge();
  }

  void _snapToEdge() {
    final screenSize = MediaQuery.of(context).size;
    final ballSize = 56.0;
    final currentPosition = ref.read(chatBallNotifierProvider).position;

    final centerX = currentPosition.dx + ballSize / 2;
    final targetX = centerX < screenSize.width / 2
        ? 0.0
        : screenSize.width - ballSize;

    final startOffset = currentPosition;
    final endOffset = Offset(targetX, currentPosition.dy);

    late AnimationController controller;
    late Animation<Offset> animation;

    controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    animation = Tween<Offset>(
      begin: startOffset,
      end: endOffset,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    animation.addListener(() {
      ref
          .read(chatBallNotifierProvider.notifier)
          .updatePosition(animation.value);
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
        ref.read(chatBallNotifierProvider.notifier).savePosition();
      }
    });

    controller.forward();
  }

  // -----------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final chatBallState = ref.watch(chatBallNotifierProvider);
    final style = ChatBallStyle.fromName(chatBallState.style);

    // 控制脉冲动画
    if (chatBallState.hasUnread) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }

    return Positioned(
      left: chatBallState.position.dx,
      top: chatBallState.position.dy,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onLongPressStart: _onLongPressStart,
        onLongPressEnd: _onLongPressEnd,
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: Stack(
          children: [
            // 脉冲动画
            if (chatBallState.hasUnread)
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: child,
                  );
                },
                child: Container(
                  width: style.size,
                  height: style.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        (style.gradient != null
                                ? Colors.blue
                                : style.backgroundColor)
                            .withValues(alpha: 0.3),
                  ),
                ),
              ),
            // 悬浮球主体
            Container(
              key: _ballKey,
              width: style.size,
              height: style.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: style.gradient != null ? null : style.backgroundColor,
                gradient: style.gradient,
                boxShadow: style.boxShadow != null ? [style.boxShadow!] : null,
              ),
              child: Icon(
                style.icon,
                color: style.iconColor,
                size: style.size * 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Panel Overlay Widget
// ---------------------------------------------------------------------------

/// A widget that renders the chat panel as an overlay, anchored near the
/// floating ball and expanding upward with a scale + fade animation.
class _PanelOverlayWidget extends StatelessWidget {
  const _PanelOverlayWidget({
    required this.ballPosition,
    required this.ballSize,
    required this.panelLeft,
    required this.panelTop,
    required this.panelWidth,
    required this.scaleAnimation,
    required this.opacityAnimation,
    required this.onClose,
    required this.onFullScreen,
  });

  final Offset ballPosition;
  final double ballSize;
  final double panelLeft;
  final double panelTop;
  final double panelWidth;
  final Animation<double> scaleAnimation;
  final Animation<double> opacityAnimation;
  final VoidCallback onClose;
  final VoidCallback onFullScreen;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // 面板最大高度：从 panelTop 向上到屏幕顶部，留 16px 边距
    final maxPanelHeight = panelTop - 16.0;
    // 面板高度：屏幕高度的 50%，但不超过 maxPanelHeight
    final panelHeight = (screenHeight * 0.5).clamp(200.0, maxPanelHeight).toDouble();

    // 面板实际顶部：从 panelTop 向上展开
    final actualTop = panelTop - panelHeight;

    return Stack(
      children: [
        // 背景遮罩 — 点击关闭
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            behavior: HitTestBehavior.translucent,
            child: Container(color: Colors.black26),
          ),
        ),
        // 气泡面板
        Positioned(
          left: panelLeft,
          top: actualTop,
          width: panelWidth,
          child: AnimatedBuilder(
            animation: Listenable.merge([scaleAnimation, opacityAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: scaleAnimation.value,
                alignment: Alignment.bottomCenter,
                child: Opacity(opacity: opacityAnimation.value, child: child),
              );
            },
            child: ChatPanel(onFullScreen: onFullScreen, onClose: onClose),
          ),
        ),
        // 小三角指向悬浮球
        Positioned(
          left: ballPosition.dx + ballSize / 2 - 8,
          top: actualTop + panelHeight - 2,
          child: CustomPaint(
            size: const Size(16, 10),
            painter: _BubbleTrianglePainter(
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Triangle painter for the bubble pointer
// ---------------------------------------------------------------------------

class _BubbleTrianglePainter extends CustomPainter {
  const _BubbleTrianglePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BubbleTrianglePainter old) =>
      old.color != color;
}
