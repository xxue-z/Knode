import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/models/conversation.dart';
import 'package:core/database/repositories/conversation_repository.dart';
import 'package:chat/gen/strings.dart';

const _strings = L10nStringsMixin();

final conversationRepositoryProvider = Provider<ConversationRepository>((ref) => throw UnimplementedError(_strings.chat_please_override_in_main_dart));

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

  Future<void> toggleWebSearch(int id, bool enable) async {
    final repo = ref.read(conversationRepositoryProvider);
    await repo.toggleWebSearch(id, enable);
    ref.invalidateSelf();
  }
}

final conversationListProvider = AsyncNotifierProvider<ConversationListNotifier, List<Conversation>>(
  ConversationListNotifier.new,
);
