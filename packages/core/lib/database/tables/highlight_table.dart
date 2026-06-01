
/// highlights 表定义。
class HighlightTable {
  static const String tableName = 'highlights';

  static const String createSql = '''
    CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      doc_id INTEGER NOT NULL,
      start_pos INTEGER NOT NULL,
      end_pos INTEGER NOT NULL,
      selected_text TEXT NOT NULL,
      style TEXT NOT NULL,
      note_text TEXT,
      note_doc_id INTEGER,
      created_at TEXT NOT NULL DEFAULT (datetime('now')),
      updated_at TEXT NOT NULL DEFAULT (datetime('now')),
      FOREIGN KEY (doc_id) REFERENCES documents(id) ON DELETE CASCADE,
      FOREIGN KEY (note_doc_id) REFERENCES documents(id) ON DELETE SET NULL
    )
  ''';

  static const String indexSql = '''
    CREATE INDEX idx_highlights_doc_id ON $tableName(doc_id)
  ''';
}
