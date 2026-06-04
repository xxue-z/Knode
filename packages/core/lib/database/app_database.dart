import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:core/services/app_logger.dart';

import 'tables/category_table.dart';
import 'tables/document_table.dart';
import 'tables/conversation_table.dart';
import 'tables/message_table.dart';
import 'tables/question_table.dart';
import 'tables/exam_table.dart';
import 'tables/exam_answer_table.dart';
import 'tables/wrong_question_log_table.dart';
import 'tables/daily_task_config_table.dart';
import 'tables/reading_log_table.dart';
import 'tables/settings_table.dart';
import 'tables/bookmark_table.dart';
import 'tables/highlight_table.dart';

/// SQLite database singleton for the Knode application.
///
/// Manages database creation, migration, and provides access to the
/// underlying [Database] instance. All 11 core tables are initialized
/// during the first launch.
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  static const int _dbVersion = 5;
  static const String _dbName = 'knode.db';

  Database? _database;

  /// Returns the active [Database] instance.
  ///
  /// Throws [StateError] if [init] has not been called.
  Database get db {
    if (_database == null) {
      throw StateError(
        'AppDatabase has not been initialized. Call AppDatabase.instance.init() first.',
      );
    }
    return _database!;
  }

  /// Opens (or creates) the database and runs all pending migrations.
  Future<void> init() async {
    if (_database != null) return;

    final dbPath = p.join(await getDatabasesPath(), _dbName);
    _database = await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
    AppLogger.instance.i('数据库初始化成功: ', tag: 'Database');
  }

  /// Enables foreign keys and other pragmas before any other operation.
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Creates all tables on first launch.
  Future<void> _onCreate(Database db, int version) async {
    final statements = <String>[
      CategoryTable.createSql,
      DocumentTable.createSql,
      ConversationTable.createSql,
      MessageTable.createSql,
      QuestionTable.createSql,
      ExamTable.createSql,
      ExamAnswerTable.createSql,
      WrongQuestionLogTable.createSql,
      DailyTaskConfigTable.createSql,
      ReadingLogTable.createSql,
      SettingsTable.createSql,
      BookmarkTable.createSql,
      BookmarkTable.indexSql,
      HighlightTable.createSql,
      HighlightTable.indexSql,
    ];
    for (final sql in statements) {
      await db.execute(sql);
    }
  }

  /// Handles incremental schema migrations.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE documents ADD COLUMN tags TEXT');
      await db.execute('ALTER TABLE documents ADD COLUMN links_to TEXT');
      await db.execute('ALTER TABLE documents ADD COLUMN manual_tags INTEGER DEFAULT 0');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE conversations ADD COLUMN enable_web_search INTEGER DEFAULT 0');
    }
    if (oldVersion < 4) {
      AppLogger.instance.i('数据库升级到 v4: 新增 bookmarks/highlights 表', tag: 'Database');
      await db.execute(BookmarkTable.createSql);
      await db.execute(BookmarkTable.indexSql);
      await db.execute(HighlightTable.createSql);
      await db.execute(HighlightTable.indexSql);
      await db.execute('ALTER TABLE documents ADD COLUMN source_doc_id INTEGER');
    }
    if (oldVersion < 5) {
      AppLogger.instance.i('数据库升级到 v5: exams 表新增 created_at/updated_at 列', tag: 'Database');
      await db.execute('ALTER TABLE exams ADD COLUMN created_at TEXT');
      await db.execute('ALTER TABLE exams ADD COLUMN updated_at TEXT');
    }
  }

  /// Closes the database connection. Useful for testing.
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
