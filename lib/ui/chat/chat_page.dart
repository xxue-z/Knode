import 'package:flutter/material.dart';
import 'archive_dialog.dart';

/// Chat page skeleton for P2 implementation.
///
/// Currently a placeholder that reserves space for:
/// - Message list area (scrollable)
/// - Message input bar at the bottom
/// Future P2 work will populate these with conversation UI, message bubbles,
/// and a functional text/voice input field.
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  void _showConversationMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('历史会话'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('历史会话功能开发中')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: const Text('归档为笔记'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => const ArchiveDialog(
                    conversationId: 0,
                    conversationTitle: '当前会话',
                    messages: [],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('清空对话'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('清空对话功能开发中')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('图片'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('图片选择功能开发中')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file_outlined),
              title: const Text('文档'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('文档选择功能开发中')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('链接'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('链接粘贴功能开发中')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _startVoiceInput(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('语音输入功能需在真机上使用')),
    );
  }

  void _showMessageInput(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('发送消息'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: '输入消息...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (controller.text.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('消息发送功能需连接 AIProvider')),
                );
              }
            },
            child: const Text('发送'),
          ),
        ],
      ),
    );
  }

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
                onPressed: () => _showConversationMenu(context),
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
              onPressed: () => _showAttachmentPicker(context),
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
              onPressed: () => _startVoiceInput(context),
              tooltip: '语音输入',
            ),
            IconButton(
              icon: const Icon(Icons.send_outlined),
              onPressed: () => _showMessageInput(context),
              tooltip: '发送',
            ),
          ],
        ),
      ),
    );
  }
}
