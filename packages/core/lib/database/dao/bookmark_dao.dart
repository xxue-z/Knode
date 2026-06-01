import 'package:sqflite/sqflite.dart';

import '../app_database.dart';
import '../tables/bookmark_table.dart';
import '../../models/bookmark.dart';
import '../../services/app_logger.dart';

/// 书签数据访问对象，实现书签的 CRUD 操作。
class BookmarkDao {
  Database get _db => AppDatabase.instance.db;

  /// 数据库行（snake_case）-> [Bookmark] 模型。
  static Bookmark _fromRow(Map<String, dynamic> row) {
    return Bookmark(
      id: row['id'] as int,
      docId: row['doc_id'] as int,
      position: row['position'] as int,
      endPosition: row['end_position'] as int,
      selectedText: row['selected_text'] as String,
      label: row['label'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }

  /// [Bookmark] 模型 -> 数据库行（snake_case），不含 id。
  static Map<String, dynamic> _toRow(Bookmark bookmark) {
    return {
      'doc_id': bookmark.docId,
      'position': bookmark.position,
      'end_position': bookmark.endPosition,
      'selected_text': bookmark.selectedText,
      'label': bookmark.label,
      'created_at': bookmark.createdAt.toIso8601String(),
    };
  }

  /// 获取文档的所有书签。
  Future<List<Bookmark>> getByDocId(int docId) async {
    try {
      final rows = await _db.query(
        BookmarkTable.tableName,
        where: 'doc_id = ?',
        whereArgs: [docId],
        orderBy: 'position ASC',
      );
      return rows.map(_fromRow).toList();
    } on DatabaseException catch (e, st) {
      AppLogger.instance.e('查询书签失败: docId=$docId', tag: 'BookmarkDao', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// 获取所有书签（跨文档）。
  Future<List<Bookmark>> getAll({int limit = 200}) async {
    try {
      final rows = await _db.query(
        BookmarkTable.tableName,
        orderBy: 'created_at DESC',
        limit: limit,
      );
      return rows.map(_fromRow).toList();
    } on DatabaseException catch (e, st) {
      AppLogger.instance.e('查询所有书签失败', tag: 'BookmarkDao', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// 添加书签，返回插入的 id。
  Future<int> insert(Bookmark bookmark) async {
    try {
      final id = await _db.insert(
        BookmarkTable.tableName,
        _toRow(bookmark),
      );
      AppLogger.instance.i('书签已保存: docId=${bookmark.docId}, text="${bookmark.selectedText}"', tag: 'BookmarkDao');
      return id;
    } on DatabaseException catch (e, st) {
      AppLogger.instance.e('插入书签失败', tag: 'BookmarkDao', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// 删除指定 id 的书签。
  Future<void> delete(int id) async {
    try {
      final count = await _db.delete(
        BookmarkTable.tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (count == 0) {
        throw StateError('Bookmark id=$id not found, nothing deleted.');
      }
      AppLogger.instance.i('书签已删除: id=$id', tag: 'BookmarkDao');
    } on DatabaseException catch (e, st) {
      AppLogger.instance.e('删除书签失败: id=$id', tag: 'BookmarkDao', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// 删除指定文档的所有书签。
  Future<void> deleteByDocId(int docId) async {
    try {
      await _db.delete(
        BookmarkTable.tableName,
        where: 'doc_id = ?',
        whereArgs: [docId],
      );
      AppLogger.instance.i('已删除文档所有书签: docId=$docId', tag: 'BookmarkDao');
    } on DatabaseException catch (e, st) {
      AppLogger.instance.e('删除文档书签失败: docId=$docId', tag: 'BookmarkDao', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// 获取文档的书签数量。
  Future<int> countByDocId(int docId) async {
    try {
      final result = await _db.rawQuery(
        'SELECT COUNT(*) as count FROM ${BookmarkTable.tableName} WHERE doc_id = ?',
        [docId],
      );
      return result.first['count'] as int;
    } on DatabaseException catch (e, st) {
      AppLogger.instance.e('统计书签数量失败: docId=$docId', tag: 'BookmarkDao', error: e, stackTrace: st);
      rethrow;
    }
  }
}
