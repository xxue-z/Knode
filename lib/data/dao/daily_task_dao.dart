import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import '../database/tables/daily_task_config_table.dart';
import '../models/daily_task_config.dart';

class DailyTaskDao {
  Database get _db => AppDatabase.instance.db;

  static DailyTaskConfig _fromRow(Map<String, dynamic> r) => DailyTaskConfig(
    id: r['id'] as int, isEnabled: r['is_enabled'] as int, scopeType: r['scope_type'] as String,
    scopeValue: r['scope_value'] as String?, questionCount: r['question_count'] as int,
    reminderTime: r['reminder_time'] as String?, reminderMethods: r['reminder_methods'] as String?,
    createdAt: r['created_at'] as String, updatedAt: r['updated_at'] as String,
  );

  static Map<String, dynamic> _toRow(DailyTaskConfig c) => {
    'is_enabled': c.isEnabled, 'scope_type': c.scopeType, 'scope_value': c.scopeValue,
    'question_count': c.questionCount, 'reminder_time': c.reminderTime,
    'reminder_methods': c.reminderMethods, 'created_at': c.createdAt, 'updated_at': c.updatedAt,
  };

  Future<DailyTaskConfig?> getConfig() async {
    final rows = await _db.query(DailyTaskConfigTable.tableName, limit: 1);
    return rows.isEmpty ? null : _fromRow(rows.first);
  }

  Future<void> saveConfig(DailyTaskConfig config) async {
    final existing = await getConfig();
    if (existing != null) {
      await _db.update(DailyTaskConfigTable.tableName, _toRow(config), where: 'id = ?', whereArgs: [existing.id]);
    } else {
      await _db.insert(DailyTaskConfigTable.tableName, _toRow(config));
    }
  }
}