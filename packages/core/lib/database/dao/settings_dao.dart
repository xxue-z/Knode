import 'package:sqflite/sqflite.dart';
import '../app_database.dart';
import '../tables/settings_table.dart';

/// 设置数据访问对象（DAO）。
///
/// 管理 settings 表中的键值对配置。
class SettingsDao {
  Database get _db => AppDatabase.instance.db;

  /// 获取指定键的值。
  Future<String?> get(String key) async {
    final rows = await _db.query(
      SettingsTable.tableName,
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  /// 设置键值对。
  ///
  /// 如果键已存在则更新，否则插入。
  Future<void> set(String key, String value) async {
    await _db.insert(
      SettingsTable.tableName,
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 删除指定键。
  Future<void> delete(String key) async {
    await _db.delete(SettingsTable.tableName, where: 'key = ?', whereArgs: [key]);
  }

  /// 获取所有键值对。
  Future<Map<String, String>> getAll() async {
    final rows = await _db.query(SettingsTable.tableName);
    final result = <String, String>{};
    for (final row in rows) {
      final key = row['key'] as String;
      final value = row['value'] as String;
      result[key] = value;
    }
    return result;
  }

  /// 批量设置键值对。
  Future<void> setAll(Map<String, String> entries) async {
    final batch = _db.batch();
    for (final entry in entries.entries) {
      batch.insert(
        SettingsTable.tableName,
        {'key': entry.key, 'value': entry.value},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}
