
import 'package:sqflite/sqflite.dart';

import '../app_database.dart';
import '../tables/highlight_table.dart';
import '../../models/highlight.dart';
import '../../models/highlight_style.dart';
import '../../services/app_logger.dart';

/// 高亮标注数据访问对象，实现高亮的 CRUD 操作。
class HighlightDao {
  Database get _db =&gt; AppDatabase.instance.db;

  /// 数据库行（snake_case）-&gt; [Highlight] 模型。
  static Highlight _fromRow(Map&lt;String, dynamic&gt; row) {
    return Highlight(
      id: row['id'] as int,
      docId: row['doc_id'] as int,
      startPosition: row['start_position'] as int,
      endPosition: row['end_position'] as int,
      selectedText: row['selected_text'] as String,
      style: HighlightStyle.deserialize(row['style_data'] as String),
      note: row['note'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  /// [Highlight] 模型 -&gt; 数据库行（snake_case），不含 id。
  static Map&lt;String, dynamic&gt; _toRow(Highlight highlight) {
    return {
      'doc_id': highlight.docId,
      'start_position': highlight.startPosition,
      'end_position': highlight.endPosition,
      'selected_text': highlight.selectedText,
      'style_data': highlight.style.serialize(),
      'note': highlight.note,
      'created_at': highlight.createdAt.toIso8601String(),
      'updated_at': highlight.updatedAt.toIso8601String(),
    };
  }

  /// 获取文档的所有高亮。
  Future&lt;List&lt;Highlight&gt;&gt; getByDocId(int docId) async {
    try {
      final rows = await _db.query(
        HighlightTable.tableName,
        where: 'doc_id = ?',
        whereArgs: [docId],
        orderBy: 'start_position ASC',
      );
      return rows.map(_fromRow).toList();
    } on DatabaseException catch (e, st) {
      AppLogger.instance.e('查询高亮失败: docId=$docId', tag: 'HighlightDao', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// 添加高亮，返回插入的 id。
  Future&lt;int&gt; insert(Highlight highlight) async {
    try {
      return await _db.insert(
        HighlightTable.tableName,
        _toRow(highlight),
      );
    } on DatabaseException catch (e, st) {
      AppLogger.instance.e('插入高亮失败', tag: 'HighlightDao', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// 更新高亮（样式或备注）。
  Future&lt;void&gt; update(Highlight highlight) async {
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
    } on DatabaseException catch (e, st) {
      AppLogger.instance.e('更新高亮失败: id=${highlight.id}', tag: 'HighlightDao', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// 删除指定 id 的高亮。
  Future&lt;void&gt; delete(int id) async {
    try {
      final count = await _db.delete(
        HighlightTable.tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (count == 0) {
        throw StateError('Highlight id=$id not found, nothing deleted.');
      }
    } on DatabaseException catch (e, st) {
      AppLogger.instance.e('删除高亮失败: id=$id', tag: 'HighlightDao', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// 获取文档的高亮数量。
  Future&lt;int&gt; countByDocId(int docId) async {
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

