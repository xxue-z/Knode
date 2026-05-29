import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/message.dart';
import '../data/repositories/conversation_repository.dart';
import '../ai/agents/qa_agent.dart';

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

  Future<void> sendMessage(String content) async {
    if (_conversationId == null || content.trim().isEmpty) return;
    final convId = _conversationId!;
    await _repo.addMessage(convId, role: 'user', content: content);
    state = state.copyWith(isLoading: true);
    try {
      final response = await _qaAgent.ask(query: content, conversationId: convId);
      await _repo.addMessage(convId, role: 'assistant', content: response.answer);
    } catch (e) {
      await _repo.addMessage(convId, role: 'assistant', content: '抱歉，AI 响应失败: $e');
    }
    final messages = await _repo.getMessages(convId);
    state = ChatMessageState(messages: messages);
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatMessageState>((ref) {
  throw UnimplementedError('请在 main.dart 中覆盖');
});