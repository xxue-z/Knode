import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../app_database.dart';
import '../../services/app_logger.dart';
import '../tables/document_table.dart';
import '../../models/document.dart';

/// 文档数据访问对象，实现 CRUD、搜索及阅读统计更新。
class DocumentDao {
  Database get _db => AppDatabase.instance.db;

  /// 数据库行（snake_case）-> [Document] 模型。
  static Document _fromRow(Map<String, dynamic> row) {
    final tagsRaw = row['tags'] as String?;
    final linksRaw = row['links_to'] as String?;
    return Document(
      id: row['id'] as int,
      title: row['title'] as String,
      fileName: row['file_name'] as String,
      filePath: row['file_path'] as String?,
      categoryId: row['category_id'] as int?,
      originalFormat: row['original_format'] as String?,
      originalFilePath: row['original_file_path'] as String?,
      contentText: row['content_text'] as String?,
      summary: row['summary'] as String?,
      wordCount: row['word_count'] as int,
      readingTime: row['reading_time'] as int,
      readCount: row['read_count'] as int,
      lastReadAt: row['last_read_at'] as String?,
      isDeleted: row['is_deleted'] as int,
      tags: tagsRaw != null && tagsRaw.isNotEmpty
          ? List<String>.from(jsonDecode(tagsRaw) as List)
          : const [],
      linksTo: linksRaw != null && linksRaw.isNotEmpty
          ? List<int>.from(jsonDecode(linksRaw) as List)
          : const [],
      manualTags: row['manual_tags'] as int? ?? 0,
      sourceDocId: row['source_doc_id'] as int?,
      createdAt: row['created_at'] as String,
      updatedAt: row['updated_at'] as String,
    );
  }

  /// [Document] 模型 -> 数据库行（snake_case），不含 id。
  static Map<String, dynamic> _toRow(Document doc) {
    return {
      'title': doc.title,
      'file_name': doc.fileName,
      'file_path': doc.filePath,
      'category_id': doc.categoryId,
      'original_format': doc.originalFormat,
      'original_file_path': doc.originalFilePath,
      'content_text': doc.contentText,
      'summary': doc.summary,
      'word_count': doc.wordCount,
      'reading_time': doc.readingTime,
      'read_count': doc.readCount,
      'last_read_at': doc.lastReadAt,
      'is_deleted': doc.isDeleted,
      'tags': jsonEncode(doc.tags),
      'links_to': jsonEncode(doc.linksTo),
      'manual_tags': doc.manualTags,
      'source_doc_id': doc.sourceDocId,
      'created_at': doc.createdAt,
      'updated_at': doc.updatedAt,
    };
  }

  /// 按类目查询文档列表。
  ///
  /// [categoryId] 指定类目 id；[includeDeleted] 为 true 时包含已软删除的文档。
  Future<List<Document>> getByCategory(
    int categoryId, {
    bool includeDeleted = false,
  }) async {
    try {
      final where = StringBuffer('category_id = ?');
      final args = <dynamic>[categoryId];
      if (!includeDeleted) {
        where.write(' AND is_deleted = 0');
      }
      final rows = await _db.query(
        DocumentTable.tableName,
        where: where.toString(),
        whereArgs: args,
        orderBy: 'updated_at DESC',
      );
      return rows.map(_fromRow).toList();
    } on DatabaseException catch (e) {
      throw StateError('Failed to query documents by category: $e');
    }
  }

  /// 获取所有文档列表。
  Future<List<Document>> getAll({bool includeDeleted = false}) async {
    try {
      final where = includeDeleted ? null : 'is_deleted = 0';
      final rows = await _db.query(
        DocumentTable.tableName,
        where: where,
        orderBy: 'updated_at DESC',
      );
      return rows.map(_fromRow).toList();
    } on DatabaseException catch (e) {
      throw StateError('Failed to query all documents: $e');
    }
  }

  /// 根据 id 获取单个文档，不存在时返回 null。
  Future<Document?> getById(int id) async {
    try {
      final rows = await _db.query(
        DocumentTable.tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return _fromRow(rows.first);
    } on DatabaseException catch (e) {
      throw StateError('Failed to query document id=$id: $e');
    }
  }

  /// 模糊搜索文档标题和正文内容。
  Future<List<Document>> search(String query) async {
    try {
      final pattern = '%$query%';
      final rows = await _db.query(
        DocumentTable.tableName,
        where: 'is_deleted = 0 AND (title LIKE ? OR content_text LIKE ?)',
        whereArgs: [pattern, pattern],
        orderBy: 'updated_at DESC',
      );
      return rows.map(_fromRow).toList();
    } on DatabaseException catch (e) {
      throw StateError('Failed to search documents: $e');
    }
  }

  /// 获取最近阅读的文档列表。
  ///
  /// [days] 指定天数范围，[limit] 限制返回数量。
  Future<List<Document>> getRecentlyRead({int days = 7, int limit = 20}) async {
    try {
      final since = DateTime.now()
          .subtract(Duration(days: days))
          .toIso8601String();
      final rows = await _db.query(
        DocumentTable.tableName,
        where:
            'is_deleted = 0 AND last_read_at IS NOT NULL AND last_read_at >= ?',
        whereArgs: [since],
        orderBy: 'last_read_at DESC',
        limit: limit,
      );
      return rows.map(_fromRow).toList();
    } on DatabaseException catch (e) {
      throw StateError('Failed to query recently read documents: $e');
    }
  }

  /// 获取阅读次数 Top/Bottom 文档。
  ///
  /// [ascending] 为 true 时返回阅读次数最少的文档（Bottom），
  /// 为 false 时返回阅读次数最多的文档（Top）。
  Future<List<Document>> getTopRead({
    int limit = 5,
    bool ascending = false,
  }) async {
    try {
      final orderBy = ascending ? 'read_count ASC' : 'read_count DESC';
      final rows = await _db.query(
        DocumentTable.tableName,
        where: 'is_deleted = 0 AND read_count > 0',
        orderBy: '$orderBy, updated_at DESC',
        limit: limit,
      );
      return rows.map(_fromRow).toList();
    } on DatabaseException catch (e) {
      throw StateError('Failed to query top read documents: $e');
    }
  }

  /// 插入新文档，返回新生成的行 id。
  Future<int> insert(Document document) async {
    try {
      return await _db.insert(DocumentTable.tableName, _toRow(document));
    } on DatabaseException catch (e) {
      throw StateError('Failed to insert document "${document.title}": $e');
    }
  }

  /// 更新文档信息（按 id 匹配）。
  Future<void> update(Document document) async {
    try {
      final row = _toRow(document);
      row['updated_at'] = DateTime.now().toIso8601String();
      final count = await _db.update(
        DocumentTable.tableName,
        row,
        where: 'id = ?',
        whereArgs: [document.id],
      );
      if (count == 0) {
        throw StateError(
          'Document id=${document.id} not found, nothing updated.',
        );
      }
    } on DatabaseException catch (e) {
      throw StateError('Failed to update document id=${document.id}: $e');
    }
  }

  /// 仅更新文档标题。
  Future<void> updateTitle(int docId, String title) async {
    try {
      await _db.update(
        DocumentTable.tableName,
        {'title': title, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [docId],
      );
    } on DatabaseException catch (e) {
      throw StateError('Failed to update title for doc id=$docId: $e');
    }
  }

  /// 更新文档标签列表。
  Future<void> updateTags(int docId, List<String> tags) async {
    try {
      final count = await _db.update(
        DocumentTable.tableName,
        {
          'tags': jsonEncode(tags),
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [docId],
      );
      if (count == 0) {
        throw StateError('Document id=$docId not found, tags not updated.');
      }
    } on DatabaseException catch (e) {
      throw StateError('Failed to update tags for doc id=$docId: $e');
    }
  }

  /// 更新文档引用链接列表。
  Future<void> updateLinksTo(int docId, List<int> linksTo) async {
    try {
      final count = await _db.update(
        DocumentTable.tableName,
        {
          'links_to': jsonEncode(linksTo),
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [docId],
      );
      if (count == 0) {
        throw StateError('Document id=$docId not found, links_to not updated.');
      }
    } on DatabaseException catch (e) {
      throw StateError('Failed to update links_to for doc id=$docId: $e');
    }
  }

  /// 软删除文档（标记 is_deleted = 1）。
  Future<void> softDelete(int id) async {
    try {
      final count = await _db.update(
        DocumentTable.tableName,
        {'is_deleted': 1, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [id],
      );
      if (count == 0) {
        throw StateError('Document id=$id not found, nothing deleted.');
      }
    } on DatabaseException catch (e) {
      throw StateError('Failed to soft-delete document id=$id: $e');
    }
  }

  /// 恢复已软删除的文档（标记 is_deleted = 0）。
  Future<void> restore(int id) async {
    try {
      final count = await _db.update(
        DocumentTable.tableName,
        {'is_deleted': 0, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [id],
      );
      if (count == 0) {
        throw StateError('Document id=$id not found, nothing restored.');
      }
    } on DatabaseException catch (e) {
      throw StateError('Failed to restore document id=$id: $e');
    }
  }

  /// 更新文档阅读统计（累加阅读时长和次数）。
  Future<void> updateReadingStats(int docId, int durationSeconds) async {
    try {
      await _db.transaction((txn) async {
        final rows = await txn.query(
          DocumentTable.tableName,
          columns: ['reading_time', 'read_count'],
          where: 'id = ?',
          whereArgs: [docId],
          limit: 1,
        );
        if (rows.isEmpty) {
          throw StateError('Document id=$docId not found for reading stats.');
        }
        final currentReadingTime = rows.first['reading_time'] as int;
        final currentReadCount = rows.first['read_count'] as int;
        await txn.update(
          DocumentTable.tableName,
          {
            'reading_time': currentReadingTime + durationSeconds,
            'read_count': currentReadCount + 1,
            'last_read_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [docId],
        );
      });
    } on DatabaseException catch (e) {
      throw StateError('Failed to update reading stats for doc id=$docId: $e');
    }
  }

  /// 获取指定时间范围内活跃的文档 ID 列表。
  ///
  /// 活跃定义：updated_at 或 last_read_at 在 [startDate, endDate] 范围内。
  Future<List<int>> getActiveDocIds({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final startStr = startDate.toIso8601String();
    final endStr = endDate.toIso8601String();
    final rows = await _db.rawQuery(
      """SELECT id FROM ${DocumentTable.tableName}
         WHERE is_deleted = 0
           AND ((updated_at BETWEEN ? AND ?) OR (last_read_at BETWEEN ? AND ?))""",
      [startStr, endStr, startStr, endStr],
    );
    return rows.map((r) => r['id'] as int).toList();
  }

  /// 获取指定类目下的所有文档 ID。
  Future<List<int>> getIdsByCategory(int categoryId) async {
    final rows = await _db.query(
      DocumentTable.tableName,
      columns: ['id'],
      where: 'category_id = ? AND is_deleted = 0',
      whereArgs: [categoryId],
    );
    return rows.map((r) => r['id'] as int).toList();
  }

  /// 获取指定原文档关联的所有笔记文档。
  Future<List<Document>> getNoteDocuments(int sourceDocId) async {
    try {
      final rows = await _db.query(
        DocumentTable.tableName,
        where: 'source_doc_id = ? AND is_deleted = 0',
        whereArgs: [sourceDocId],
        orderBy: 'created_at ASC',
      );
      return rows.map(_fromRow).toList();
    } on DatabaseException catch (e, st) {
      AppLogger.instance.e(
        '查询笔记文档失败: sourceDocId=$sourceDocId',
        tag: 'DocumentDao',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// 判断文档是否为笔记文档。
  Future<bool> isNoteDocument(int docId) async {
    final doc = await getById(docId);
    return doc?.sourceDocId != null;
  }
}
