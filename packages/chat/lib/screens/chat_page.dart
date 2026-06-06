import 'package:flutter/material.dart';
import 'package:chat/gen/strings.dart';
import 'package:chat/screens/archive_dialog.dart';
import 'package:chat/screens/chat_drawer.dart';
import 'package:chat/screens/message_input.dart';

const _strings = L10nStringsMixin();

/// Chat page skeleton for P2 implementation.
///
/// Currently a placeholder that reserves space for:
/// - Message list area (scrollable)
/// - Message input bar at the bottom
/// Future P2 work will populate these with conversation UI, message bubbles,
/// and a functional text/voice input field.
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        final horizontalPadding = isWide ? constraints.maxWidth * 0.1 : 0.0;

        return Scaffold(
          key: _scaffoldKey,
          endDrawer: ChatDrawer(
            onConversationSelected: (conv) {
              // TODO: Load conversation into chat
            },
          ),
          appBar: AppBar(
            title: Text(_strings.chat_ai_assistant),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: _openDrawer,
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

