import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat/gen/strings.dart';
import 'package:core/models/message.dart';
import 'package:core/database/repositories/conversation_repository.dart';
import 'package:chat/agents/qa_agent.dart';

const _strings = L10nStringsMixin();

class ChatMessageState {
  final List<Message> messages;
  final bool isLoading;
  const ChatMessageState({this.messages = const [], this.isLoading = false});
  ChatMessageState copyWith({List<Message>? messages, bool? isLoading}) =>
      ChatMessageState(messages: messages ?? this.messages, isLoading: isLoading ?? this.isLoading);
}

class ChatNotifier extends Notifier<ChatMessageState> {
  ConversationRepository? _repo;
  QaAgent? _qaAgent;
  int? _conversationId;

  @override
  ChatMessageState build() => const ChatMessageState();

  void init(ConversationRepository repo, QaAgent qaAgent) {
    _repo = repo;
    _qaAgent = qaAgent;
  }

  void loadConversation(int conversationId) async {
    final repo = _repo;
    if (repo == null) return;
    _conversationId = conversationId;
    state = const ChatMessageState(isLoading: true);
    try {
      final messages = await repo.getMessages(conversationId);
      state = ChatMessageState(messages: messages);
    } catch (e) {
      state = const ChatMessageState();
    }
  }

  Future<void> sendMessage(String content, {bool enableSearch = false}) async {
    final repo = _repo;
    final qaAgent = _qaAgent;
    if (repo == null || qaAgent == null) return;
    if (_conversationId == null || content.trim().isEmpty) return;
    final convId = _conversationId!;
    await repo.addMessage(convId, role: 'user', content: content);
    state = state.copyWith(isLoading: true);
    try {
      final response = await qaAgent.ask(query: content, conversationId: convId, enableSearch: enableSearch);
      await repo.addMessage(convId, role: 'assistant', content: response.answer);
    } catch (e) {
      await repo.addMessage(convId, role: 'assistant', content: '${_strings.chat_error}: $e');
    }
    final messages = await repo.getMessages(convId);
    state = ChatMessageState(messages: messages);
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatMessageState>(ChatNotifier.new);