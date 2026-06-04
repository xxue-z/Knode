class ExamTable {
  ExamTable._();

  static const String tableName = 'exams';

  static const String createSql = 'CREATE TABLE exams ('
      'id INTEGER PRIMARY KEY, '
      'exam_type TEXT NOT NULL, '
      'title TEXT, '
      'question_count INTEGER, '
      'total_score REAL, '
      'obtained_score REAL, '
      'time_limit INTEGER, '
      'started_at TEXT, '
      'finished_at TEXT, '
      "status TEXT DEFAULT 'ongoing', created_at TEXT, updated_at TEXT, "
      'config_json TEXT'
      ')';
}
