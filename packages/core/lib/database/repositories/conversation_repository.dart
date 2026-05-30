import '../dao/conversation_dao.dart';
import '../dao/message_dao.dart';
import '../../models/conversation.dart';
import '../../models/message.dart';

/// 会话业务异常。
class ConversationBusinessException implements Exception {
  final String message;
  const ConversationBusinessException(this.message);
  @override
  String toString() => 'ConversationBusinessException: $message';
}

/// 摘要生成函数类型，由外部注入。
typedef SummarizeFunction = Future<String> Function(String content);

class ConversationRepository {
  final ConversationDao _convDao;
  final MessageDao _msgDao;
  final SummarizeFunction? _summarizeFn;

  ConversationRepository({required ConversationDao convDao, required MessageDao msgDao, SummarizeFunction? summarizeFn})
      : _convDao = convDao, _msgDao = msgDao, _summarizeFn = summarizeFn;

  Future<List<Conversation>> getAll({String status = 'active'}) => _convDao.getAll(status: status);
  Future<Conversation?> getById(int id) => _convDao.getById(id);
  Future<List<Message>> getMessages(int conversationId, {int? limit, int offset = 0}) => _msgDao.getByConversation(conversationId, limit: limit, offset: offset);

  Future<Conversation> createConversation({String? title}) async {
    final conv = Conversation(id: 0, title: title, status: 'active',
      createdAt: DateTime.now().toIso8601String(), updatedAt: DateTime.now().toIso8601String());
    final id = await _convDao.insert(conv);
    return conv.copyWith(id: id);
  }

  Future<void> addMessage(int conversationId, {required String role, required String content, String? citations}) async {
    final msg = Message(id: 0, conversationId: conversationId, role: role, content: content,
      contentType: 'text', citations: citations, createdAt: DateTime.now().toIso8601String());
    await _msgDao.insert(msg);
    await _convDao.update((await _convDao.getById(conversationId))!.copyWith(updatedAt: DateTime.now().toIso8601String()));
  }

  Future<void> rename(int id, String title) async {
    final conv = await _convDao.getById(id);
    if (conv == null) throw ConversationBusinessException('会话不存在: id=$id');
    await _convDao.update(conv.copyWith(title: title));
  }

  Future<void> delete(int id) async {
    await _msgDao.deleteByConversation(id);
    await _convDao.delete(id);
  }

  /// 将会话归档为笔记。
  ///
  /// 1. 调用摘要函数生成摘要
  /// 2. 返回归档信息，由调用方创建 Document 记录
  Future<int?> archive(int conversationId, int categoryId) async {
    final conv = await _convDao.getById(conversationId);
    if (conv == null) throw ConversationBusinessException('会话不存在: id=$conversationId');

    // 获取所有消息拼接为文本
    final messages = await _msgDao.getByConversation(conversationId);
    if (messages.isEmpty) throw ConversationBusinessException('会话为空，无法归档');

    final conversationText = messages
        .map((m) => '${m.role == "user" ? "用户" : "AI"}：${m.content}')
        .join('\n\n');

    // 调用摘要函数生成摘要
    if (_summarizeFn != null) {
      try {
        await _summarizeFn(conversationText);
      } catch (_) {
        // 摘要失败时忽略
      }
    }

    // 返回归档信息，由调用方（ArchiveDialog）创建 Document 记录
    return conversationId;
  }
}