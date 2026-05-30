class DailyTaskConfigTable {
  DailyTaskConfigTable._();

  static const String tableName = 'daily_task_config';

  static const String createSql = 'CREATE TABLE daily_task_config ('
      'id INTEGER PRIMARY KEY, '
      'is_enabled INTEGER DEFAULT 1, '
      "scope_type TEXT DEFAULT 'all', "
      'scope_value TEXT, '
      'question_count INTEGER DEFAULT 10, '
      'reminder_time TEXT, '
      'reminder_methods TEXT, '
      "created_at TEXT DEFAULT (datetime('now')), "
      "updated_at TEXT DEFAULT (datetime('now'))"
      ')';
}
