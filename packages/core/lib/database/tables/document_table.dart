class DocumentTable {
  DocumentTable._();

  static const String tableName = 'documents';

  static const String createSql = 'CREATE TABLE documents ('
      'id INTEGER PRIMARY KEY, '
      'title TEXT NOT NULL, '
      'file_name TEXT NOT NULL, '
      'file_path TEXT, '
      'category_id INTEGER, '
      'original_format TEXT, '
      'original_file_path TEXT, '
      'content_text TEXT, '
      'summary TEXT, '
      'word_count INTEGER DEFAULT 0, '
      'reading_time INTEGER DEFAULT 0, '
      'read_count INTEGER DEFAULT 0, '
      'last_read_at TEXT, '
      'is_deleted INTEGER DEFAULT 0, '
      'tags TEXT, '
      'links_to TEXT, '
      'manual_tags INTEGER DEFAULT 0, '
      "created_at TEXT DEFAULT (datetime('now')), "
      "updated_at TEXT DEFAULT (datetime('now'))"
      ')';
}
