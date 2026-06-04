import 'package:flutter/material.dart';
import 'package:chat/gen/strings.dart';
import 'package:chat/screens/message_input.dart';

const _strings = L10nStringsMixin();

/// Chat纯内容Widget（无Scaffold）
class ChatContent extends StatelessWidget {
  const ChatContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 消息列表区域
        const Expanded(
          child: _MessageListPlaceholder(),
        ),
        // 输入栏区域
        MessageInput(
          onSend: (text) {
            // TODO: 发送消息到 ChatNotifier
          },
        ),
      ],
    );
  }
}

/// 占位的消息列表组件
class _MessageListPlaceholder extends StatelessWidget {
  const _MessageListPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            _strings.chat_no_conversations_yet,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _strings.chat_start_conversation_hint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
