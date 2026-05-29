import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/conversation.dart';
import '../data/repositories/conversation_repository.dart';

final conversationRepositoryProvider = Provider<ConversationRepository>((ref) => throw UnimplementedError('请在 main.dart 中覆盖'));

class ConversationListNotifier extends AsyncNotifier<List<Conversation>> {
  @override
  Future<List<Conversation>> build() async {
    final repo = ref.read(conversationRepositoryProvider);
    return repo.getAll();
  }

  Future<Conversation> create({String? title}) async {
    final repo = ref.read(conversationRepositoryProvider);
    final conv = await repo.createConversation(title: title);
    ref.invalidateSelf();
    return conv;
  }

  Future<void> rename(int id, String title) async {
    final repo = ref.read(conversationRepositoryProvider);
    await repo.rename(id, title);
    ref.invalidateSelf();
  }

  Future<void> delete(int id) async {
    final repo = ref.read(conversationRepositoryProvider);
    await repo.delete(id);
    ref.invalidateSelf();
  }
}

final conversationListProvider = AsyncNotifierProvider<ConversationListNotifier, List<Conversation>>(
  ConversationListNotifier.new,
);