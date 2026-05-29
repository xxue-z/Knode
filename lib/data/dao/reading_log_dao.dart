import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../database/tables/reading_log_table.dart';
import '../models/reading_log.dart';

/// 阅读日志数据访问对象，记录每次阅读的开始/结束时间和时长。
class ReadingLogDao {
  Database get _db => AppDatabase.instance.db;

  /// 数据库行（snake_case）→ [ReadingLog] 模型。
  static ReadingLog _fromRow(Map<String, dynamic> row) {
    return ReadingLog(
      id: row['id'] as int,
      docId: row['doc_id'] as int,
      startTime: row['start_time'] as String?,
      endTime: row['end_time'] as String?,
      durationSeconds: row['duration_seconds'] as int?,
    );
  }

  /// [ReadingLog] 模型 → 数据库行（snake_case），不含 id。
  static Map<String, dynamic> _toRow(ReadingLog log) {
    return {
      'doc_id': log.docId,
      'start_time': log.startTime,
      'end_time': log.endTime,
      'duration_seconds': log.durationSeconds,
    };
  }

  /// 查询指定文档的所有阅读日志。
  Future<List<ReadingLog>> getByDoc(int docId) async {
    try {
      final rows = await _db.query(
        ReadingLogTable.tableName,
        where: 'doc_id = ?',
        whereArgs: [docId],
        orderBy: 'start_time DESC',
      );
      return rows.map(_fromRow).toList();
    } on DatabaseException catch (e) {
      throw StateError('Failed to query reading logs for docId=$docId: $e');
    }
  }

  /// 按日期范围查询阅读日志。
  Future<List<ReadingLog>> getByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final startStr = start.toIso8601String();
      final endStr = end.toIso8601String();
      final rows = await _db.query(
        ReadingLogTable.tableName,
        where: 'start_time >= ? AND start_time <= ?',
        whereArgs: [startStr, endStr],
        orderBy: 'start_time DESC',
      );
      return rows.map(_fromRow).toList();
    } on DatabaseException catch (e) {
      throw StateError('Failed to query reading logs by date range: $e');
    }
  }

  /// 插入一条阅读日志，返回新生成的行 id。
  Future<int> insert(ReadingLog log) async {
    try {
      return await _db.insert(
        ReadingLogTable.tableName,
        _toRow(log),
      );
    } on DatabaseException catch (e) {
      throw StateError('Failed to insert reading log: $e');
    }
  }

  /// 返回每个文档在最近 [days] 天内的累计阅读时长（秒）。
  ///
  /// 结果为 `{docId: totalSeconds}` 映射，用于 Top5/Bottom5 统计。
  Future<Map<int, int>> getDocDurationSum({int days = 30}) async {
    try {
      final since = DateTime.now()
          .subtract(Duration(days: days))
          .toIso8601String();
      final rows = await _db.rawQuery(
        'SELECT doc_id, SUM(duration_seconds) AS total_seconds '
        'FROM ${ReadingLogTable.tableName} '
        'WHERE start_time >= ? AND duration_seconds IS NOT NULL '
        'GROUP BY doc_id',
        [since],
      );
      final result = <int, int>{};
      for (final row in rows) {
        final docId = row['doc_id'] as int;
        final totalSeconds = row['total_seconds'] as int? ?? 0;
        result[docId] = totalSeconds;
      }
      return result;
    } on DatabaseException catch (e) {
      throw StateError('Failed to query doc duration sum: $e');
    }
  }
}
