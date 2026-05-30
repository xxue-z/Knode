import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../app_database.dart';
import '../tables/question_table.dart';
import '../../models/question.dart';

class QuestionDao {
  Database get _db => AppDatabase.instance.db;

  static Question _fromRow(Map<String, dynamic> r) => Question(
    id: r['id'] as int, type: r['type'] as String, stem: r['stem'] as String,
    options: r['options'] as String?, answer: r['answer'] as String,
    explanation: r['explanation'] as String?, sourceFileIds: r['source_file_ids'] as String?,
    difficulty: r['difficulty'] as int, tags: r['tags'] as String?, createdAt: r['created_at'] as String,
  );

  static Map<String, dynamic> _toRow(Question q) => {
    'type': q.type, 'stem': q.stem, 'options': q.options, 'answer': q.answer,
    'explanation': q.explanation, 'source_file_ids': q.sourceFileIds,
    'difficulty': q.difficulty, 'tags': q.tags, 'created_at': q.createdAt,
  };

  Future<List<Question>> getByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final placeholders = ids.map((_) => '?').join(',');
    final rows = await _db.query(QuestionTable.tableName, where: 'id IN ($placeholders)', whereArgs: ids);
    return rows.map(_fromRow).toList();
  }

  Future<List<Question>> getBySourceFile(int docId) async {
    final rows = await _db.query(QuestionTable.tableName, where: 'source_file_ids LIKE ?', whereArgs: ['%$docId%']);
    return rows.map(_fromRow).toList();
  }

  Future<List<Question>> getRandom({int limit = 10}) async {
    final rows = await _db.rawQuery('SELECT * FROM ${QuestionTable.tableName} ORDER BY RANDOM() LIMIT ?', [limit]);
    return rows.map(_fromRow).toList();
  }

  Future<List<Question>> getWrongQuestions({int limit = 20}) async {
    final rows = await _db.rawQuery(
      'SELECT q.* FROM ${QuestionTable.tableName} q INNER JOIN wrong_question_logs w ON q.id = w.question_id ORDER BY w.wrong_count DESC LIMIT ?', [limit]);
    return rows.map(_fromRow).toList();
  }

  Future<int> insert(Question q) async {
    return await _db.insert(QuestionTable.tableName, _toRow(q));
  }

  Future<void> batchInsert(List<Question> questions) async {
    await _db.transaction((txn) async {
      for (final q in questions) {
        await txn.insert(QuestionTable.tableName, _toRow(q));
      }
    });
  }

  /// 基于 content_hash 去重插入。如果已存在相同哈希的题目则跳过。
  Future<int> upsertWithDedup(Question q) async {
    final hash = q.contentHash;
    if (hash != null) {
      final existing = await _db.query(
        QuestionTable.tableName,
        where: 'content_hash = ?',
        whereArgs: [hash],
        limit: 1,
      );
      if (existing.isNotEmpty) return existing.first['id'] as int;
    }
    return await _db.insert(QuestionTable.tableName, _toRow(q));
  }
}