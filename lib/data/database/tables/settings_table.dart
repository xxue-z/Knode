class SettingsTable {
  SettingsTable._();

  static const String tableName = 'settings';

  static const String createSql = 'CREATE TABLE settings ('
      'key TEXT PRIMARY KEY, '
      'value TEXT'
      ')';
}
