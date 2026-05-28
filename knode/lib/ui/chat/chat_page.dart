import 'package:flutter/material.dart';

/// Chat page skeleton for P2 implementation.
///
/// Currently a placeholder that reserves space for:
/// - Message list area (scrollable)
/// - Message input bar at the bottom
/// Future P2 work will populate these with conversation UI, message bubbles,
/// and a functional text/voice input field.
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        final horizontalPadding = isWide ? constraints.maxWidth * 0.1 : 0.0;

        return Scaffold(
          appBar: AppBar(
            title: const Text('AI 助手'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // TODO(P2): Show conversation settings / history menu.
                },
              ),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              children: [
                // --- Message list area ---
                const Expanded(
                  child: _MessageListPlaceholder(),
                ),
                // --- Input bar area ---
                const _InputBarPlaceholder(),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Placeholder widget for the scrollable message list.
///
/// Will be replaced by a [ListView] of message bubbles in P2.
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
            '暂无对话',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '发送消息开始与 AI 助手对话',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder widget for the message input bar.
///
/// Will be replaced by a text field with send/voice buttons in P2.
class _InputBarPlaceholder extends StatelessWidget {
  const _InputBarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                // TODO(P2): Attachment picker.
              },
              tooltip: '添加附件',
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  '输入消息...',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.mic_outlined),
              onPressed: () {
                // TODO(P2): Voice input via speech_to_text.
              },
              tooltip: '语音输入',
            ),
            IconButton(
              icon: const Icon(Icons.send_outlined),
              onPressed: () {
                // TODO(P2): Send message to AIProvider.
              },
              tooltip: '发送',
            ),
          ],
        ),
      ),
    );
  }
}
