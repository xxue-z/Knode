import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat/gen/strings.dart';
import 'package:chat/providers/chat_provider.dart';
import 'package:chat/screens/chat_history_drawer.dart';
import 'package:chat/screens/chat_archive_drawer.dart';
import 'package:chat/screens/message_input.dart';
import 'package:chat/screens/message_bubble.dart';
import 'package:core/models/conversation.dart';
import 'package:core/providers/settings_provider.dart';
import 'package:core/extensions/riverpod_compat.dart';

const _strings = L10nStringsMixin();

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Conversation? _currentConversation;

  void _openHistoryDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _openArchiveDrawer() {
    showDialog(
      context: context,
      builder: (_) => const ChatArchiveDrawer(),
    );
  }

  void _loadConversation(Conversation conv) {
    setState(() => _currentConversation = conv);
    ref.read(chatProvider.notifier).loadConversation(conv.id);
  }

  bool _isModelConfigured() {
    final settings = ref.read(settingsProvider).valueOrNull ?? {};
    final aiType = settings['ai_type'] ?? 'cloud';
    if (aiType == 'cloud') {
      final apiKey = settings['cloud_api_key'] ?? '';
      return apiKey.isNotEmpty;
    } else {
      final localModel = settings['local_model_id'] ?? '';
      return localModel.isNotEmpty;
    }
  }

  void _showModelConfigGuide() {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('濡€崇€烽張顏堝帳缂?),
        content: const Text('鐠囧嘲鍘涢崷銊啎缂冾喕鑵戦柊宥囩枂AI濡€崇€烽敍鍫滅隘缁旂枆PI閹存牗婀伴崷鐗埬侀崹瀣剁礆閿涘瞼鍔ч崥搴㈠閼宠棄绱戞慨瀣嚠鐠囨縿鈧?),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('閸欐牗绉?),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('鐠囧嘲婀拋鍓х枂娑擃參鍘ょ純鐡礗濡€崇€?)))));
            },
            child: const Text('閸樺鍘ょ純?),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: ChatHistoryDrawer(
        onConversationSelected: _loadConversation,
      ),
      appBar: AppBar(
        title: Text(_currentConversation?.title ?? _strings.chat_ai_assistant),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.archive_outlined), onPressed: _openArchiveDrawer),
          IconButton(icon: const Icon(Icons.menu), onPressed: _openHistoryDrawer),
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
            if (!_isModelConfigured()) {
              _showModelConfigGuide();
              return;
            }
            ref.read(chatProvider.notifier).sendMessage(text);
          },
        ),
      ]),
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