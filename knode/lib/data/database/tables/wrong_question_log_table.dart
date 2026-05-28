class WrongQuestionLogTable {
  WrongQuestionLogTable._();

  static const String tableName = 'wrong_question_log';

  static const String createSql = 'CREATE TABLE wrong_question_log ('
      'id INTEGER PRIMARY KEY, '
      'question_id INTEGER NOT NULL, '
      'wrong_count INTEGER DEFAULT 1, '
      'last_wrong_at TEXT'
      ')';
}
