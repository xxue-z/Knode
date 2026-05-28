class ReadingLogTable {
  ReadingLogTable._();

  static const String tableName = 'reading_logs';

  static const String createSql = 'CREATE TABLE reading_logs ('
      'id INTEGER PRIMARY KEY, '
      'doc_id INTEGER NOT NULL, '
      'start_time TEXT, '
      'end_time TEXT, '
      'duration_seconds INTEGER'
      ')';
}
