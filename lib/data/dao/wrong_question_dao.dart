import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import '../database/tables/wrong_question_log_table.dart';
import '../models/wrong_question_log.dart';

class WrongQuestionDao {
  Database get _db => AppDatabase.instance.db;

  static WrongQuestionLog _fromRow(Map<String, dynamic> r) => WrongQuestionLog(
    id: r['id'] as int, questionId: r['question_id'] as int,
    wrongCount: r['wrong_count'] as int, lastWrongAt: r['last_wrong_at'] as String?,
  );

  Future<List<WrongQuestionLog>> getAll({int limit = 100}) async {
    final rows = await _db.query(WrongQuestionLogTable.tableName, orderBy: 'wrong_count DESC', limit: limit);
    return rows.map(_fromRow).toList();
  }

  Future<WrongQuestionLog?> getByQuestion(int questionId) async {
    final rows = await _db.query(WrongQuestionLogTable.tableName, where: 'question_id = ?', whereArgs: [questionId], limit: 1);
    return rows.isEmpty ? null : _fromRow(rows.first);
  }

  Future<void> upsert(int questionId) async {
    final existing = await getByQuestion(questionId);
    if (existing != null) {
      await _db.update(WrongQuestionLogTable.tableName, {
        'wrong_count': existing.wrongCount + 1, 'last_wrong_at': DateTime.now().toIso8601String(),
      }, where: 'id = ?', whereArgs: [existing.id]);
    } else {
      await _db.insert(WrongQuestionLogTable.tableName, {
        'question_id': questionId, 'wrong_count': 1, 'last_wrong_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> clear(int questionId) async {
    await _db.delete(WrongQuestionLogTable.tableName, where: 'question_id = ?', whereArgs: [questionId]);
  }
}