import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat/gen/strings.dart';
import 'package:chat/providers/chat_provider.dart';
import 'package:chat/screens/chat_drawer.dart';
import 'package:chat/screens/message_input.dart';
import 'package:chat/screens/message_bubble.dart';
import 'package:core/models/conversation.dart';

const _strings = L10nStringsMixin();

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Conversation? _currentConversation;

  void _openDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _loadConversation(Conversation conv) {
    setState(() => _currentConversation = conv);
    ref.read(chatProvider.notifier).loadConversation(conv.id);
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: ChatDrawer(
        onConversationSelected: _loadConversation,
      ),
      appBar: AppBar(
        title: Text(_currentConversation?.title ?? _strings.chat_ai_assistant),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.menu), onPressed: _openDrawer),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: chatState.messages.isEmpty
              ? _MessageListPlaceholder()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: chatState.messages.length,
                  itemBuilder: (context, index) {
                    final msg = chatState.messages[index];
                    return MessageBubble(message: msg);
                  },
                ),
        ),
        if (chatState.isLoading) const LinearProgressIndicator(),
        MessageInput(
          onSend: (text) {
            ref.read(chatProvider.notifier).sendMessage(text);
          },
        ),
      ],
    );
  }
}

class _MessageListPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.chat_bubble_outline, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(height: 16),
        Text(_strings.chat_no_conversations_yet, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        Text(_strings.chat_start_conversation_hint, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ]),
    );
  }
}
