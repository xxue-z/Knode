import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import '../database/tables/conversation_table.dart';
import '../models/conversation.dart';

class ConversationDao {
  Database get _db => AppDatabase.instance.db;

  static Conversation _fromRow(Map<String, dynamic> r) => Conversation(
    id: r['id'] as int, title: r['title'] as String?,
    status: r['status'] as String, wikiFileId: r['wiki_file_id'] as int?,
    createdAt: r['created_at'] as String, updatedAt: r['updated_at'] as String,
  );

  static Map<String, dynamic> _toRow(Conversation c) => {
    'title': c.title, 'status': c.status, 'wiki_file_id': c.wikiFileId,
    'created_at': c.createdAt, 'updated_at': c.updatedAt,
  };

  Future<List<Conversation>> getAll({String status = 'active'}) async {
    try {
      final rows = await _db.query(ConversationTable.tableName,
        where: 'status = ?', whereArgs: [status], orderBy: 'updated_at DESC');
      return rows.map(_fromRow).toList();
    } on DatabaseException catch (e) { throw StateError('Failed to query conversations: $e'); }
  }

  Future<Conversation?> getById(int id) async {
    try {
      final rows = await _db.query(ConversationTable.tableName,
        where: 'id = ?', whereArgs: [id], limit: 1);
      return rows.isEmpty ? null : _fromRow(rows.first);
    } on DatabaseException catch (e) { throw StateError('Failed to query conversation id=$id: $e'); }
  }

  Future<int> insert(Conversation conversation) async {
    try { return await _db.insert(ConversationTable.tableName, _toRow(conversation));
    } on DatabaseException catch (e) { throw StateError('Failed to insert conversation: $e'); }
  }

  Future<void> update(Conversation conversation) async {
    try {
      final count = await _db.update(ConversationTable.tableName, _toRow(conversation),
        where: 'id = ?', whereArgs: [conversation.id]);
      if (count == 0) throw StateError('Conversation id=${conversation.id} not found.');
    } on DatabaseException catch (e) { throw StateError('Failed to update conversation: $e'); }
  }

  Future<void> delete(int id) async {
    try { await _db.delete(ConversationTable.tableName, where: 'id = ?', whereArgs: [id]);
    } on DatabaseException catch (e) { throw StateError('Failed to delete conversation id=$id: $e'); }
  }

  Future<void> archive(int id, int wikiFileId) async {
    try {
      await _db.update(ConversationTable.tableName,
        {'status': 'archived', 'wiki_file_id': wikiFileId, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?', whereArgs: [id]);
    } on DatabaseException catch (e) { throw StateError('Failed to archive conversation id=$id: $e'); }
  }
}