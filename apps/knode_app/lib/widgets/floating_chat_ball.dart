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
    _doubleTapTimer?.cancel();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    // 记录点击时间，用于区分单击和双击
  }

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

    // 显示半屏聊天窗口
    _showChatPanel();
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
    final isExpanded = ref.read(chatBallNotifierProvider).isExpanded;
    if (isExpanded) {
      ref.read(chatBallNotifierProvider.notifier).toggleExpanded();
    }

    // 导航到完整Chat页面
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatPage()),
    );
  }

  void _showVoicePanel() {
    showDialog(
      context: context,
      builder: (context) => VoicePanel(
        onSend: () {
          Navigator.pop(context);
          // TODO: 发送语音消息
        },
        onCancel: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    setState(() => _isDragging = true);
    _doubleTapTimer?.cancel();
    _lastTapTime = null;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final newPosition = ref.read(chatBallNotifierProvider).position + details.delta;

    // 边界约束
    final screenSize = MediaQuery.of(context).size;
    final ballSize = 56.0;
    final bottomOffset = 80.0; // 避开导航栏

    final clampedX = newPosition.dx.clamp(0.0, screenSize.width - ballSize);
    final clampedY = newPosition.dy.clamp(
      0.0,
      screenSize.height - ballSize - bottomOffset,
    );

    // 只更新内存中的位置，不保存到持久化存储
    ref.read(chatBallNotifierProvider.notifier).updatePosition(
          Offset(clampedX, clampedY),
        );
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() => _isDragging = false);
    // 自动靠边吸附
    _snapToEdge();
  }

  void _snapToEdge() {
    final screenSize = MediaQuery.of(context).size;
    final ballSize = 56.0;
    final currentPosition = ref.read(chatBallNotifierProvider).position;

    // 计算悬浮球中心点
    final centerX = currentPosition.dx + ballSize / 2;

    // 判断应该吸附到左边还是右边
    final targetX = centerX < screenSize.width / 2
        ? 0.0 // 吸附到左边缘
        : screenSize.width - ballSize; // 吸附到右边缘

    // 创建动画控制器实现平滑吸附
    final startOffset = currentPosition;
    final endOffset = Offset(targetX, currentPosition.dy);

    late AnimationController controller;
    late Animation<Offset> animation;

    controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    animation = Tween<Offset>(begin: startOffset, end: endOffset).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );

    animation.addListener(() {
      ref.read(chatBallNotifierProvider.notifier).updatePosition(animation.value);
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
        // 动画结束后保存位置
        ref.read(chatBallNotifierProvider.notifier).savePosition();
      }
    });

    controller.forward();
  }

  void _showChatPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChatPanel(
        onFullScreen: () {
          Navigator.pop(context);
          _onDoubleTap();
        },
        onClose: () {
          Navigator.pop(context);
        },
      ),
    );
  }

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
                    color: (style.gradient != null
                            ? Colors.blue
                            : style.backgroundColor)
                        .withValues(alpha: 0.3),
                  ),
                ),
              ),
            // 悬浮球主体
            Container(
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