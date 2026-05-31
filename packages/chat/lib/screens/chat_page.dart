import 'package:flutter/material.dart';
import 'package:chat/gen/strings.dart';
import 'package:chat/screens/archive_dialog.dart';
import 'package:chat/screens/message_input.dart';

const _strings = L10nStringsMixin();

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
              title: Text(_strings.chat_history_sessions),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_strings.chat_history_sessions_dev)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: Text(_strings.chat_archive),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => ArchiveDialog(
                    conversationId: 0,
                    conversationTitle: _strings.chat_current_session,
                    messages: [],
                    categories: [],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(_strings.chat_clear_history),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_strings.chat_clear_history_dev)),
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
              title: Text(_strings.chat_image),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_strings.chat_image_dev)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file_outlined),
              title: Text(_strings.chat_document),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_strings.chat_document_dev)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: Text(_strings.chat_link),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_strings.chat_link_dev)),
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
      SnackBar(content: Text(_strings.chat_voice_real_device)),
    );
  }

  void _showMessageInput(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_strings.chat_send_message),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: _strings.chat_input_message,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_strings.chat_cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (controller.text.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_strings.chat_send_message_need_ai)),
                );
              }
            },
            child: Text(_strings.chat_send),
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
            title: Text(_strings.chat_ai_assistant),
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
                MessageInput(
                  onSend: (text) {
                    // TODO: 发送消息到 ChatNotifier
                  },
                ),
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

