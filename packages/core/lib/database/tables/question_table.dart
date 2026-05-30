class QuestionTable {
  QuestionTable._();

  static const String tableName = 'questions';

  static const String createSql = 'CREATE TABLE questions ('
      'id INTEGER PRIMARY KEY, '
      'type TEXT NOT NULL, '
      'stem TEXT NOT NULL, '
      'options TEXT, '
      'answer TEXT NOT NULL, '
      'explanation TEXT, '
      'source_file_ids TEXT, '
      'difficulty INTEGER DEFAULT 2, '
      'tags TEXT, '
      "created_at TEXT DEFAULT (datetime('now'))"
      ')';
}
