
/// bookmarks 表定义。
class BookmarkTable {
  static const String tableName = 'bookmarks';

  static const String createSql = '''
    CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      doc_id INTEGER NOT NULL,
      position INTEGER NOT NULL,
      end_position INTEGER NOT NULL,
      selected_text TEXT NOT NULL,
      label TEXT,
      created_at TEXT NOT NULL DEFAULT (datetime('now')),
      FOREIGN KEY (doc_id) REFERENCES documents(id) ON DELETE CASCADE
    )
  ''';

  static const String indexSql = '''
    CREATE INDEX idx_bookmarks_doc_id ON $tableName(doc_id)
  ''';
}
