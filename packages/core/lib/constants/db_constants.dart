/// 数据库常量定义。
class DbConstants {
  DbConstants._();

  // ── 表名 ────────────────────────────────────────────────────────

  static const String categoryTable = 'categories';
  static const String documentTable = 'documents';
  static const String conversationTable = 'conversations';
  static const String messageTable = 'messages';
  static const String questionTable = 'questions';
  static const String examTable = 'exams';
  static const String examAnswerTable = 'exam_answers';
  static const String wrongQuestionLogTable = 'wrong_question_log';
  static const String dailyTaskConfigTable = 'daily_task_config';
  static const String readingLogTable = 'reading_logs';
  static const String settingsTable = 'settings';

  // ── 列名 ────────────────────────────────────────────────────────

  /// 通用列
  static const String colId = 'id';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  /// categories 表
  static const String colName = 'name';
  static const String colParentId = 'parent_id';
  static const String colSortOrder = 'sort_order';

  /// documents 表
  static const String colTitle = 'title';
  static const String colFileName = 'file_name';
  static const String colFilePath = 'file_path';
  static const String colCategoryId = 'category_id';
  static const String colContentText = 'content_text';
  static const String colSummary = 'summary';
  static const String colWordCount = 'word_count';
  static const String colReadingTime = 'reading_time';
  static const String colReadCount = 'read_count';
  static const String colLastReadAt = 'last_read_at';
  static const String colIsDeleted = 'is_deleted';

  /// conversations 表
  static const String colStatus = 'status';
  static const String colWikiFileId = 'wiki_file_id';

  /// messages 表
  static const String colConversationId = 'conversation_id';
  static const String colRole = 'role';
  static const String colContent = 'content';
  static const String colContentType = 'content_type';
  static const String colMediaPath = 'media_path';
  static const String colCitations = 'citations';

  /// questions 表
  static const String colType = 'type';
  static const String colStem = 'stem';
  static const String colOptions = 'options';
  static const String colAnswer = 'answer';
  static const String colExplanation = 'explanation';
  static const String colSourceFileIds = 'source_file_ids';
  static const String colDifficulty = 'difficulty';
  static const String colTags = 'tags';

  /// exams 表
  static const String colExamType = 'exam_type';
  static const String colQuestionCount = 'question_count';
  static const String colTotalScore = 'total_score';
  static const String colObtainedScore = 'obtained_score';
  static const String colTimeLimit = 'time_limit';
  static const String colStartedAt = 'started_at';
  static const String colFinishedAt = 'finished_at';
  static const String colConfigJson = 'config_json';

  /// exam_answers 表
  static const String colExamId = 'exam_id';
  static const String colQuestionId = 'question_id';
  static const String colUserAnswer = 'user_answer';
  static const String colIsCorrect = 'is_correct';
  static const String colScore = 'score';
  static const String colAiFeedback = 'ai_feedback';

  /// wrong_question_log 表
  static const String colWrongCount = 'wrong_count';
  static const String colLastWrongAt = 'last_wrong_at';

  /// daily_task_config 表
  static const String colIsEnabled = 'is_enabled';
  static const String colScopeType = 'scope_type';
  static const String colScopeValue = 'scope_value';
  static const String colReminderTime = 'reminder_time';
  static const String colReminderMethods = 'reminder_methods';

  /// reading_logs 表
  static const String colDocId = 'doc_id';
  static const String colStartTime = 'start_time';
  static const String colEndTime = 'end_time';
  static const String colDurationSec = 'duration_sec';

  /// settings 表
  static const String colKey = 'key';
  static const String colValue = 'value';
}
