import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import '../database/tables/message_table.dart';
import '../models/message.dart';

class MessageDao {
  Database get _db => AppDatabase.instance.db;

  static Message _fromRow(Map<String, dynamic> r) => Message(
    id: r['id'] as int, conversationId: r['conversation_id'] as int,
    role: r['role'] as String, content: r['content'] as String,
    contentType: r['content_type'] as String, mediaPath: r['media_path'] as String?,
    citations: r['citations'] as String?, createdAt: r['created_at'] as String,
  );

  static Map<String, dynamic> _toRow(Message m) => {
    'conversation_id': m.conversationId, 'role': m.role, 'content': m.content,
    'content_type': m.contentType, 'media_path': m.mediaPath,
    'citations': m.citations, 'created_at': m.createdAt,
  };

  Future<List<Message>> getByConversation(int conversationId, {int? limit, int offset = 0}) async {
    try {
      final rows = await _db.query(MessageTable.tableName,
        where: 'conversation_id = ?', whereArgs: [conversationId],
        orderBy: 'created_at ASC', limit: limit, offset: offset);
      return rows.map(_fromRow).toList();
    } on DatabaseException catch (e) { throw StateError('Failed to query messages: $e'); }
  }

  Future<int> insert(Message message) async {
    try { return await _db.insert(MessageTable.tableName, _toRow(message));
    } on DatabaseException catch (e) { throw StateError('Failed to insert message: $e'); }
  }

  Future<void> delete(int id) async {
    try { await _db.delete(MessageTable.tableName, where: 'id = ?', whereArgs: [id]);
    } on DatabaseException catch (e) { throw StateError('Failed to delete message id=$id: $e'); }
  }

  Future<void> deleteByConversation(int conversationId) async {
    try { await _db.delete(MessageTable.tableName, where: 'conversation_id = ?', whereArgs: [conversationId]);
    } on DatabaseException catch (e) { throw StateError('Failed to delete messages for conv $conversationId: $e'); }
  }
}