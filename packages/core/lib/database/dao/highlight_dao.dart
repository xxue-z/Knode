import 'package:sqflite/sqflite.dart';

import '../app_database.dart';
import '../tables/highlight_table.dart';
import '../../models/highlight.dart';
import '../../models/highlight_style.dart';
import '../../services/app_logger.dart';

/// 高亮标注数据访问对象，实现高亮的 CRUD 操作。
class HighlightDao {
  Database get _db => AppDatabase.instance.db;

  /// 数据库行（snake_case）-> [Highlight] 模型。
  static Highlight _fromRow(Map<String, dynamic> row) {
    return Highlight(
      id: row['id'] as int,
      docId: row['doc_id'] as int,
      startPos: row['start_pos'] as int,
      endPos: row['end_pos'] as int,
      selectedText: row['selected_text'] as String,
      style: HighlightStyle.fromJson(row['style'] as String),
      noteText: row['note_text'] as String?,
      noteDocId: row['note_doc_id'] as int?,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  /// [Highlight] 模型 -> 数据库行（snake_case），不含 id。
  static Map<String, dynamic> _toRow(Highlight highlight) {
    return {
      'doc_id': highlight.docId,
      'start_pos': highlight.startPos,
      'end_pos': highlight.endPos,
      'selected_text': highlight.selectedText,
      'style': highlight.style.toJson(),
      'note_text': highlight.noteText,
      'note_doc_id': highlight.noteDocId,
      'created_at': highlight.createdAt.toIso8601String(),
      'updated_at': highlight.updatedAt.toIso8601String(),
    };
  }

  /// 获取文档的所有高亮。
  Future<List<Highlight>> getByDocId(int docId) async {
    try {
      final rows = await _db.query(
        HighlightTable.tableName,
        where: 'doc_id = ?',
        whereArgs: [docId],
        orderBy: 'start_pos ASC',
      );
      return rows.map(_fromRow).toList();
    } on DatabaseException catch (e, st) {
      AppLogger.instance.e('查询高亮失败: docId=$docId', tag: 'HighlightDao', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// 获取文档中有笔记的高亮。
  Future<List<Highlight>> getWithNotes(int docId) async {
    try {
      final rows = await _db.query(
        HighlightTable.tableName,
        where: 'doc_id = ? AND note_text IS NOT NULL AND note_text != ""',
        whereArgs: [docId],
        orderBy: 'start_pos ASC',
      );
      return rows.map(_fromRow).toList();
    } on DatabaseException catch (e, st) {
      AppLogger.instance.e('查询笔记高亮失败: docId=$docId', tag: 'HighlightDao', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// 获取关联到指定原文的所有笔记文档 ID。
  Future<List<int>> getNoteDocIds(int sourceDocId) async {
    try {
      final rows = await _db.query(
        HighlightTable.tableName,
        columns: ['note_doc_id'],
        where: 'note_doc_id IS NOT NULL AND doc_id = ?',
        whereArgs: [sourceDocId],
      );
      return rows.map((r) => r['note_doc_id'] as int).toList();
    } on DatabaseException catch (e, st) {
      AppLogger.instance.e('查询笔记文档ID失败: sourceDocId=$sourceDocId', tag: 'HighlightDao', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// 添加高亮，返回插入的 id。
  Future<int> insert(Highlight highlight) async {
    try {
      final id = await _db.insert(
        HighlightTable.tableName,
        _toRow(highlight),
      );
      AppLogger.instance.i('高亮已保存: docId=${highlight.docId}, range=[${highlight.startPos},${highlight.endPos})', tag: 'HighlightDao');
      return id;
    } on DatabaseException catch (e, st) {
      AppLogger.instance.e('插入高亮失败', tag: 'HighlightDao', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// 更新高亮（样式或笔记）。
  Future<void> update(Highlight highlight) async {
    try {
      final row = _toRow(highlight);
      row['updated_at'] = DateTime.now().toIso8601String();
      final count = await _db.update(
        HighlightTable.tableName,
        row,
        where: 'id = ?',
        whereArgs: [highlight.id],
      );
      if (count == 0) {
        throw StateError('Highlight id=${highlight.id} not found, nothing updated.');
      }
      AppLogger.instance.i('高亮已更新: id=${highlight.id}', tag: 'HighlightDao');
    } on DatabaseException catch (e, st) {
      AppLogger.instance.e('更新高亮失败: id=${highlight.id}', tag: 'HighlightDao', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// 删除指定 id 的高亮。
  Future<void> delete(int id) async {
    try {
      final count = await _db.delete(
        HighlightTable.tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (count == 0) {
        throw StateError('Highlight id=$id not found, nothing deleted.');
      }
      AppLogger.instance.i('高亮已删除: id=$id', tag: 'HighlightDao');
    } on DatabaseException catch (e, st) {
      AppLogger.instance.e('删除高亮失败: id=$id', tag: 'HighlightDao', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// 删除指定文档的所有高亮。
  Future<void> deleteByDocId(int docId) async {
    try {
      await _db.delete(
        HighlightTable.tableName,
        where: 'doc_id = ?',
        whereArgs: [docId],
      );
      AppLogger.instance.i('已删除文档所有高亮: docId=$docId', tag: 'HighlightDao');
    } on DatabaseException catch (e, st) {
      AppLogger.instance.e('删除文档高亮失败: docId=$docId', tag: 'HighlightDao', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// 获取文档的高亮数量。
  Future<int> countByDocId(int docId) async {
    try {
      final result = await _db.rawQuery(
        'SELECT COUNT(*) as count FROM ${HighlightTable.tableName} WHERE doc_id = ?',
        [docId],
      );
      return result.first['count'] as int;
    } on DatabaseException catch (e, st) {
      AppLogger.instance.e('统计高亮数量失败: docId=$docId', tag: 'HighlightDao', error: e, stackTrace: st);
      rethrow;
    }
  }
}
