import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:knode_app/providers/chat_ball_provider.dart';
import 'package:knode_app/widgets/chat_ball_style.dart';
import 'package:knode_app/widgets/chat_panel.dart';
import 'package:knode_app/widgets/voice_panel.dart';

/// 全局悬浮球组件
class FloatingChatBall extends ConsumerStatefulWidget {
  const FloatingChatBall({super.key});

  @override
  ConsumerState<FloatingChatBall> createState() => _FloatingChatBallState();
}

class _FloatingChatBallState extends ConsumerState<FloatingChatBall>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isLongPressing = false;

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
    super.dispose();
  }

  void _onTap() {
    if (_isLongPressing) return;
    ref.read(chatBallNotifierProvider.notifier).toggleExpanded();
    // 清除未读状态
    ref.read(chatBallNotifierProvider.notifier).setHasUnread(false);
  }

  void _onLongPressStart(LongPressStartDetails details) {
    setState(() => _isLongPressing = true);
    _showVoicePanel();
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    setState(() => _isLongPressing = false);
  }

  void _onDoubleTap() {
    _navigateToFullChat();
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

  void _navigateToFullChat() {
    // 关闭半屏窗口
    final isExpanded = ref.read(chatBallNotifierProvider).isExpanded;
    if (isExpanded) {
      ref.read(chatBallNotifierProvider.notifier).toggleExpanded();
    }
    // TODO: 导航到完整Chat页面
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

    ref.read(chatBallNotifierProvider.notifier).updatePosition(
          Offset(clampedX, clampedY),
        );
  }

  void _showChatPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChatPanel(
        onFullScreen: () {
          Navigator.pop(context);
          _navigateToFullChat();
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
        onTap: _onTap,
        onDoubleTap: _onDoubleTap,
        onLongPressStart: _onLongPressStart,
        onLongPressEnd: _onLongPressEnd,
        onPanUpdate: _onPanUpdate,
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