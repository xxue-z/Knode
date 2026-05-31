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

class ChatNotifier extends StateNotifier<ChatMessageState> {
  final ConversationRepository _repo;
  final QaAgent _qaAgent;
  int? _conversationId;

  ChatNotifier(this._repo, this._qaAgent) : super(const ChatMessageState());

  void loadConversation(int conversationId) async {
    _conversationId = conversationId;
    state = const ChatMessageState(isLoading: true);
    try {
      final messages = await _repo.getMessages(conversationId);
      state = ChatMessageState(messages: messages);
    } catch (e) {
      state = const ChatMessageState();
    }
  }

  Future<void> sendMessage(String content, {bool enableSearch = false}) async {
    if (_conversationId == null || content.trim().isEmpty) return;
    final convId = _conversationId!;
    await _repo.addMessage(convId, role: 'user', content: content);
    state = state.copyWith(isLoading: true);
    try {
      final response = await _qaAgent.ask(query: content, conversationId: convId, enableSearch: enableSearch);
      await _repo.addMessage(convId, role: 'assistant', content: response.answer);
    } catch (e) {
      await _repo.addMessage(convId, role: 'assistant', content: '${_strings.chat_error}: $e');
    }
    final messages = await _repo.getMessages(convId);
    state = ChatMessageState(messages: messages);
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatMessageState>((ref) {
  throw UnimplementedError(_strings.chat_please_override_in_main_dart);
});