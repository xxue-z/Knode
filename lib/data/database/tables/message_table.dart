class MessageTable {
  MessageTable._();

  static const String tableName = 'messages';

  static const String createSql = 'CREATE TABLE messages ('
      'id INTEGER PRIMARY KEY, '
      'conversation_id INTEGER NOT NULL, '
      'role TEXT NOT NULL, '
      'content TEXT NOT NULL, '
      "content_type TEXT DEFAULT 'text', "
      'media_path TEXT, '
      'citations TEXT, '
      "created_at TEXT DEFAULT (datetime('now'))"
      ')';
}
