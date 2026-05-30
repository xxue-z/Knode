class ExamAnswerTable {
  ExamAnswerTable._();

  static const String tableName = 'exam_answers';

  static const String createSql = 'CREATE TABLE exam_answers ('
      'id INTEGER PRIMARY KEY, '
      'exam_id INTEGER NOT NULL, '
      'question_id INTEGER NOT NULL, '
      'user_answer TEXT, '
      'is_correct INTEGER, '
      'score REAL, '
      'ai_feedback TEXT'
      ')';
}
