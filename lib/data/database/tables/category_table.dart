class CategoryTable {
  CategoryTable._();

  static const String tableName = 'categories';

  static const String createSql = 'CREATE TABLE categories ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'name TEXT NOT NULL, '
      'parent_id INTEGER NOT NULL DEFAULT 0, '
      'sort_order INTEGER DEFAULT 0, '
      "created_at TEXT DEFAULT (datetime('now')), "
      "updated_at TEXT DEFAULT (datetime('now'))"
      ')';
}
