import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:knode_app/providers/chat_ball_provider.dart';

/// 半屏聊天窗口
class ChatPanel extends ConsumerStatefulWidget {
  final VoidCallback onFullScreen;
  final VoidCallback onClose;

  const ChatPanel({
    super.key,
    required this.onFullScreen,
    required this.onClose,
  });

  @override
  ConsumerState<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends ConsumerState<ChatPanel> {
  double _heightRatio = 0.5;
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onDragVertical(DragUpdateDetails details) {
    setState(() {
      final delta = details.delta.dy / MediaQuery.of(context).size.height;
      _heightRatio = (_heightRatio - delta).clamp(0.3, 0.7);
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      // TODO: 发送到ChatProvider
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final panelHeight = screenHeight * _heightRatio;

    return GestureDetector(
      onVerticalDragUpdate: _onDragVertical,
      child: Container(
        height: panelHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            // 拖拽条
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 标题栏
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '聊天',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.fullscreen),
                        tooltip: '展开完整聊天',
                        onPressed: widget.onFullScreen,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: widget.onClose,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 消息列表区域
            const Expanded(
              child: Center(
                child: Text('消息列表区域'),
              ),
            ),
            // 输入区域
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    final chatBallState = ref.watch(chatBallNotifierProvider);
    final isVoiceMode = chatBallState.inputMode == 'voice';

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 语音/文字切换按钮
            IconButton(
              icon: Icon(isVoiceMode ? Icons.keyboard : Icons.mic),
              onPressed: () {
                ref.read(chatBallNotifierProvider.notifier).setInputMode(
                      isVoiceMode ? 'text' : 'voice',
                    );
              },
            ),
            // 输入框
            Expanded(
              child: isVoiceMode
                  ? _buildVoiceMode()
                  : TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: '输入消息...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
            ),
            const SizedBox(width: 8),
            // 发送按钮
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceMode() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Text('按住说话'),
      ),
    );
  }
}
