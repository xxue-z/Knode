class ConversationTable {
  ConversationTable._();

  static const String tableName = 'conversations';

  static const String createSql = 'CREATE TABLE conversations ('
      'id INTEGER PRIMARY KEY, '
      'title TEXT, '
      "status TEXT DEFAULT 'active', "
      'wiki_file_id INTEGER, '
      "created_at TEXT DEFAULT (datetime('now')), "
      "updated_at TEXT DEFAULT (datetime('now'))"
      ')';
}
