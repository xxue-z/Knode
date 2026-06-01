# G9-1 - 阅读器增强：数据层实施计划

## 一、现状分析

### 1.1 已有代码

| 文件 | 现状 |
|------|------|
| `packages/core/lib/database/app_database.dart` | 数据库版本 3，11 张表，无 bookmarks/highlights 表 |
| `packages/core/lib/database/tables/document_table.dart` | documents 表无 `source_doc_id` 列 |
| `packages/core/lib/database/dao/document_dao.dart` | 无书签/高亮相关查询方法 |
| `packages/core/lib/database/tables/settings_table.dart` | settings 表已有，可直接新增键值 |
| `packages/core/lib/models/document.dart` | Document 模型无 sourceDocId 字段 |

### 1.2 需要新增

1. `bookmarks` 表 — 存储书签数据
2. `highlights` 表 — 存储高亮/笔记数据
3. `documents` 表新增 `source_doc_id` 列 — 笔记文档关联原文
4. `BookmarkDao` — 书签 CRUD
5. `HighlightDao` — 高亮 CRUD
6. `Bookmark` / `Highlight` / `HighlightStyle` 数据模型
7. 阅读设置持久化（settings 表新增键）

---

## 二、涉及的文件清单

| 序号 | 文件路径 | 操作 | 说明 |
|------|----------|------|------|
| 1 | `packages/core/lib/database/tables/bookmark_table.dart` | 新增 | bookmarks 表定义 |
| 2 | `packages/core/lib/database/tables/highlight_table.dart` | 新增 | highlights 表定义 |
| 3 | `packages/core/lib/database/app_database.dart` | 修改 | 新增两张表 + documents 加列 + 版本升至 4 |
| 4 | `packages/core/lib/models/bookmark.dart` | 新增 | Bookmark 数据模型 |
| 5 | `packages/core/lib/models/highlight.dart` | 新增 | Highlight 数据模型 |
| 6 | `packages/core/lib/models/highlight_style.dart` | 新增 | HighlightStyle 数据模型 |
| 7 | `packages/core/lib/database/dao/bookmark_dao.dart` | 新增 | 书签 DAO |
| 8 | `packages/core/lib/database/dao/highlight_dao.dart` | 新增 | 高亮 DAO |
| 9 | `packages/core/lib/database/dao/document_dao.dart` | 修改 | 新增 source_doc_id 相关查询 |
| 10 | `packages/core/lib/models/document.dart` | 修改 | 新增 sourceDocId 字段 |
| 11 | `packages/core/lib/database/dao/settings_dao.dart` | 修改 | 新增阅读设置读写方法（若已有则复用） |

---

## 三、实施步骤

### 步骤 1：创建 Bookmark 数据模型

**新增文件**: `packages/core/lib/models/bookmark.dart`

```dart
/// 书签数据模型。
class Bookmark {
  final int? id;
  final int docId;
  final int position;
  final int endPosition;
  final String selectedText;
  final String? label;
  final DateTime createdAt;

  const Bookmark({
    this.id,
    required this.docId,
    required this.position,
    required this.endPosition,
    required this.selectedText,
    this.label,
    required this.createdAt,
  });

  Bookmark copyWith({
    int? id,
    int? docId,
    int? position,
    int? endPosition,
    String? selectedText,
    String? label,
    DateTime? createdAt,
  }) {
    return Bookmark(
      id: id ?? this.id,
      docId: docId ?? this.docId,
      position: position ?? this.position,
      endPosition: endPosition ?? this.endPosition,
      selectedText: selectedText ?? this.selectedText,
      label: label ?? this.label,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

### 步骤 2：创建 Highlight 数据模型

**新增文件**: `packages/core/lib/models/highlight.dart`

```dart
import 'highlight_style.dart';

/// 高亮/笔记数据模型。
class Highlight {
  final int? id;
  final int docId;
  final int startPos;
  final int endPos;
  final String selectedText;
  final HighlightStyle style;
  final String? noteText;
  final int? noteDocId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Highlight({
    this.id,
    required this.docId,
    required this.startPos,
    required this.endPos,
    required this.selectedText,
    required this.style,
    this.noteText,
    this.noteDocId,
    required this.createdAt,
    required this.updatedAt,
  });

  Highlight copyWith({
    int? id,
    int? docId,
    int? startPos,
    int? endPos,
    String? selectedText,
    HighlightStyle? style,
    String? noteText,
    int? noteDocId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Highlight(
      id: id ?? this.id,
      docId: docId ?? this.docId,
      startPos: startPos ?? this.startPos,
      endPos: endPos ?? this.endPos,
      selectedText: selectedText ?? this.selectedText,
      style: style ?? this.style,
      noteText: noteText ?? this.noteText,
      noteDocId: noteDocId ?? this.noteDocId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```

**新增文件**: `packages/core/lib/models/highlight_style.dart`

```dart
import 'dart:convert';
import 'package:flutter/material.dart';

/// 高亮类型。
enum HighlightType { background, underline }

/// 高亮样式。
class HighlightStyle {
  final HighlightType type;
  final Color color;
  final double opacity;

  const HighlightStyle({
    this.type = HighlightType.background,
    required this.color,
    this.opacity = 0.3,
  });

  /// 序列化为 JSON 字符串（存入数据库）。
  String toJson() => jsonEncode({
    'type': type == HighlightType.background ? 'bg' : 'underline',
    '#color': color.value,
    'opacity': opacity,
  });

  /// 从 JSON 字符串反序列化。
  static HighlightStyle fromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return HighlightStyle(
      type: map['type'] == 'bg' ? HighlightType.background : HighlightType.underline,
      color: Color(map['color'] as int),
      opacity: (map['opacity'] as num).toDouble(),
    );
  }

  /// 预设样式列表。
  static const List<HighlightStyle> presets = [
    HighlightStyle(type: HighlightType.background, color: Color(0xFFFFF59D)), // 黄色
    HighlightStyle(type: HighlightType.background, color: Color(0xFF81C784)), // 绿色
    HighlightStyle(type: HighlightType.background, color: Color(0xFF64B5F6)), // 蓝色
    HighlightStyle(type: HighlightType.underline, color: Color(0xFFE57373)),  // 红色下划线
    HighlightStyle(type: HighlightType.underline, color: Color(0xFFFFB74D)),  // 橙色下划线
  ];
}
```

**日志接入**:
```dart
import 'package:core/services/app_logger.dart';

// 在模型的 fromJson 中解析失败时记录警告
AppLogger.instance.w('高亮样式解析失败，使用默认样式', tag: 'HighlightStyle', error: e);
```

### 步骤 3：创建 bookmarks 表定义

**新增文件**: `packages/core/lib/database/tables/bookmark_table.dart`

```dart
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
```

### 步骤 4：创建 highlights 表定义

**新增文件**: `packages/core/lib/database/tables/highlight_table.dart`

```dart
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
```

### 步骤 5：修改 AppDatabase — 新增表 + 升级版本

**修改文件**: `packages/core/lib/database/app_database.dart`

改动内容：

1. 导入新表定义
2. `_onCreate` 中新增两张表的创建
3. `_onUpgrade` 新增 v3→v4 迁移：创建表 + documents 加 `source_doc_id` 列
4. 版本号从 3 改为 4

```dart
// 新增 import
import 'package:core/database/tables/bookmark_table.dart';
import 'package:core/database/tables/highlight_table.dart';

// _onCreate 中新增（在现有表创建之后）
await db.execute(BookmarkTable.createSql);
await db.execute(BookmarkTable.indexSql);
await db.execute(HighlightTable.createSql);
await db.execute(HighlightTable.indexSql);

// _onUpgrade 新增 case
case 3:
  await db.execute(BookmarkTable.createSql);
  await db.execute(BookmarkTable.indexSql);
  await db.execute(HighlightTable.createSql);
  await db.execute(HighlightTable.indexSql);
  await db.execute('ALTER TABLE documents ADD COLUMN source_doc_id INTEGER');

// 版本号
static const int _version = 4;
```

**日志接入**:
```dart
AppLogger.instance.i('数据库升级到 v4: 新增 bookmarks/highlights 表', tag: 'Database');
```

### 步骤 6：修改 Document 模型 — 新增 sourceDocId

**修改文件**: `packages/core/lib/models/document.dart`

```dart
// 新增字段
final int? sourceDocId;

// 构造函数新增参数
this.sourceDocId,

// copyWith 新增
int? sourceDocId,

// 在 DocumentDao._toRow 中新增
if (doc.sourceDocId != null) row['source_doc_id'] = doc.sourceDocId;

// 在 DocumentDao._fromRow 中新增
sourceDocId: row['source_doc_id'] as int?,
```

### 步骤 7：创建 BookmarkDao

**新增文件**: `packages/core/lib/database/dao/bookmark_dao.dart`

```dart
import 'package:core/database/app_database.dart';
import 'package:core/database/tables/bookmark_table.dart';
import 'package:core/models/bookmark.dart';
import 'package:core/services/app_logger.dart';

/// 书签数据访问对象。
class BookmarkDao {
  Database get _db => AppDatabase.instance.db;

  static Bookmark _fromRow(Map<String, dynamic> row) {
    return Bookmark(
      id: row['id'] as int,
      docId: row['doc_id'] as int,
      position: row['position'] as int,
      endPosition: row['end_position'] as int,
      selectedText: row['selected_text'] as String,
      label: row['label'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }

  static Map<String, dynamic> _toRow(Bookmark bookmark) {
    return {
      'doc_id': bookmark.docId,
      'position': bookmark.position,
      'end_position': bookmark.endPosition,
      'selected_text': bookmark.selectedText,
      'label': bookmark.label,
      'created_at': bookmark.createdAt.toIso8601String(),
    };
  }

  /// 获取指定文档的所有书签。
  Future<List<Bookmark>> getByDocId(int docId) async {
    try {
      final rows = await _db.query(
        BookmarkTable.tableName,
        where: 'doc_id = ?',
        whereArgs: [docId],
        orderBy: 'position ASC',
      );
      return rows.map(_fromRow).toList();
    } catch (e, st) {
      AppLogger.instance.e('查询书签失败: docId=$docId', tag: 'BookmarkDao', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// 获取所有书签（跨文档）。
  Future<List<Bookmark>> getAll({int limit = 200}) async {
    try {
      final rows = await _db.query(
        BookmarkTable.tableName,
        orderBy: 'created_at DESC',
        limit: limit,
      );
      return rows.map(_fromRow).toList();
    } catch (e, st) {
      AppLogger.instance.e('查询所有书签失败', tag: 'BookmarkDao', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// 插入书签，返回新 ID。
  Future<int> insert(Bookmark bookmark) async {
    try {
      final id = await _db.insert(BookmarkTable.tableName, _toRow(bookmark));
      AppLogger.instance.i('书签已保存: docId=${bookmark.docId}, text="${bookmark.selectedText}"', tag: 'BookmarkDao');
      return id;
    } catch (e, st) {
      AppLogger.instance.e('插入书签失败', tag: 'BookmarkDao', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// 删除书签。
  Future<void> delete(int id) async {
    try {
      await _db.delete(BookmarkTable.tableName, where: 'id = ?', whereArgs: [id]);
      AppLogger.instance.i('书签已删除: id=$id', tag: 'BookmarkDao');
    } catch (e, st) {
      AppLogger.instance.e('删除书签失败: id=$id', tag: 'BookmarkDao', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// 删除指定文档的所有书签。
  Future<void> deleteByDocId(int docId) async {
    try {
      await _db.delete(BookmarkTable.tableName, where: 'doc_id = ?', whereArgs: [docId]);
      AppLogger.instance.i('已删除文档所有书签: docId=$docId', tag: 'BookmarkDao');
    } catch (e, st) {
      AppLogger.instance.e('删除文档书签失败: docId=$docId', tag: 'BookmarkDao', error: e, stackTrace: st);
      rethrow;
    }
  }
}
```

### 步骤 8：创建 HighlightDao

**新增文件**: `packages/core/lib/database/dao/highlight_dao.dart`

```dart
import 'package:core/database/app_database.dart';
import 'package:core/database/tables/highlight_table.dart';
import 'package:core/models/highlight.dart';
import 'package:core/models/highlight_style.dart';
import 'package:core/services/app_logger.dart';

/// 高亮/笔记数据访问对象。
class HighlightDao {
  Database get _db => AppDatabase.instance.db;

  static Highlight _fromRow(Map<String, dynamic> row) {
    return Highlight(
      id: row['id'] as int,
      docId: row['doc_id'] as int,
      startPos: row['start_pos'] as int,
      endPos: row['end_pos'] as int,
      selectedText: row['selected_text'] as String,
      style: HighlightStyle.fromJson(row['style'] as String),
      noteText: row['note_text'] as String?,
      noteDocId: row['note_doc_id'] as int?,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  static Map<String, dynamic> _toRow(Highlight highlight) {
    return {
      'doc_id': highlight.docId,
      'start_pos': highlight.startPos,
      'end_pos': highlight.endPos,
      'selected_text': highlight.selectedText,
      'style': highlight.style.toJson(),
      'note_text': highlight.noteText,
      'note_doc_id': highlight.noteDocId,
      'created_at': highlight.createdAt.toIso8601String(),
      'updated_at': highlight.updatedAt.toIso8601String(),
    };
  }

  /// 获取指定文档的所有高亮。
  Future<List<Highlight>> getByDocId(int docId) async {
    try {
      final rows = await _db.query(
        HighlightTable.tableName,
        where: 'doc_id = ?',
        whereArgs: [docId],
        orderBy: 'start_pos ASC',
      );
      return rows.map(_fromRow).toList();
    } catch (e, st) {
      AppLogger.instance.e('查询高亮失败: docId=$docId', tag: 'HighlightDao', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// 获取有笔记的高亮列表。
  Future<List<Highlight>> getWithNotes(int docId) async {
    try {
      final rows = await _db.query(
        HighlightTable.tableName,
        where: 'doc_id = ? AND note_text IS NOT NULL AND note_text != ""',
        whereArgs: [docId],
        orderBy: 'start_pos ASC',
      );
      return rows.map(_fromRow).toList();
    } catch (e, st) {
      AppLogger.instance.e('查询笔记高亮失败: docId=$docId', tag: 'HighlightDao', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// 获取关联到指定原文的所有笔记文档 ID。
  Future<List<int>> getNoteDocIds(int sourceDocId) async {
    try {
      final rows = await _db.query(
        HighlightTable.tableName,
        columns: ['note_doc_id'],
        where: 'note_doc_id IS NOT NULL AND doc_id = ?',
        whereArgs: [sourceDocId],
      );
      return rows.map((r) => r['note_doc_id'] as int).toList();
    } catch (e, st) {
      AppLogger.instance.e('查询笔记文档ID失败: sourceDocId=$sourceDocId', tag: 'HighlightDao', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// 插入高亮，返回新 ID。
  Future<int> Insert(Highlight highlight) async {
    try {
      final id = await _db.insert(HighlightTable.tableName, _toRow(highlight));
      AppLogger.instance.i('高亮已保存: docId=${highlight.docId}, range=[${highlight.startPos},${highlight.endPos})', tag: 'HighlightDao');
      return id;
    } catch (e, st) {
      AppLogger.instance.e('插入高亮失败', tag: 'HighlightDao', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// 更新高亮（笔记内容或样式）。
  Future<void> update(Highlight highlight) async {
    try {
      final row = _toRow(highlight);
      row['updated_at'] = DateTime.now().toIso8601String();
      await _db.update(
        HighlightTable.tableName,
        row,
        where: 'id = ?',
        whereArgs: [highlight.id],
      );
      AppLogger.instance.i('高亮已更新: id=${highlight.id}', tag: 'HighlightDao');
    } catch (e, st) {
      AppLogger.instance.e('更新高亮失败: id=${highlight.id}', tag: 'HighlightDao', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// 删除高亮。
  Future<void> delete(int id) async {
    try {
      await _db.delete(HighlightTable.tableName, where: 'id = ?', whereArgs: [id]);
      AppLogger.instance.i('高亮已删除: id=$id', tag: 'HighlightDao');
    } catch (e, st) {
      AppLogger.instance.e('删除高亮失败: id=$id', tag: 'HighlightDao', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// 删除指定文档的所有高亮。
  Future<void> deleteByDocId(int docId) async {
    try {
      await _db.delete(HighlightTable.tableName, where: 'doc_id = ?', whereArgs: [docId]);
      AppLogger.instance.i('已删除文档所有高亮: docId=$docId', tag: 'HighlightDao');
    } catch (e, st) {
      AppLogger.instance.e('删除文档高亮失败: docId=$docId', tag: 'HighlightDao', error: e, stackTrace: st);
      rethrow;
    }
  }
}
```

### 步骤 9：修改 DocumentDao — 新增笔记文档查询

**修改文件**: `packages/core/lib/database/dao/document_dao.dart`

新增方法：

```dart
/// 获取指定原文档关联的所有笔记文档。
Future<List<Document>> getNoteDocuments(int sourceDocId) async {
  try {
    final rows = await _db.query(
      DocumentTable.tableName,
      where: 'source_doc_id = ? AND is_deleted = 0',
      whereArgs: [sourceDocId],
      orderBy: 'created_at ASC',
    );
    return rows.map(_fromRow).toList();
  } catch (e, st) {
    AppLogger.instance.e('查询笔记文档失败: sourceDocId=$sourceDocId', tag: 'DocumentDao', error: e, stackTrace: st);
    rethrow;
  }
}

/// 判断文档是否为笔记文档。
Future<bool> isNoteDocument(int docId) async {
  final doc = await getById(docId);
  return doc?.sourceDocId != null;
}
```

### 步骤 10：国际化字符串

**修改文件**: `packages/core/res/strings.csv`

新增以下行（追加到 CSV 末尾）：

```csv
bookmark_saved,Bookmark saved,书签已保存
bookmark_deleted,Bookmark deleted,书签已删除
highlight_saved,Highlight saved,高亮已保存
highlight_deleted,Highlight deleted,高亮已删除
note_document_created,Note document created,笔记文档已创建
```

---

## 四、验收步骤

> **每个步骤完成后、提交代码前，必须通过以下验证命令。未通过验证的代码禁止提交。**

### 验证命令

```bash
# 1. 静态分析（必须 0 error）
dart analyze packages/core

# 2. 运行所有测试（必须全部通过）
flutter test packages/core

# 3. 国际化代码生成（必须成功）
dart run monolith_runner:localization

# 4. 硬编码中文扫描（必须 0 匹配）
grep -r "Text('[一-鿿]" --include="*.dart" packages/core/lib/models/bookmark.dart packages/core/lib/models/highlight.dart packages/core/lib/models/highlight_style.dart packages/core/lib/database/dao/bookmark_dao.dart packages/core/lib/database/dao/highlight_dao.dart packages/core/lib/database/tables/bookmark_table.dart packages/core/lib/database/tables/highlight_table.dart --exclude-dir=gen
```

### 验证标准

| 检查项 | 必须满足 | 不满足时处理 |
|--------|----------|-------------|
| `dart analyze` error 数 | 0 | 修复所有 error 后重新验证 |
| `flutter test` 失败数 | 0 | 修复失败测试后重新验证 |
| 代码生成 | 成功无报错 | 检查 CSV 格式后重新验证 |
| 硬编码中文 | 0 匹配 | 替换为 `_strings.xxx` 后重新验证 |

### 验证时机

- 步骤 1-2 完成后：验证模型类无编译错误
- 步骤 3-5 完成后：验证数据库表创建和迁移无编译错误
- 步骤 6 完成后：验证 Document 模型修改无编译错误
- 步骤 7-9 完成后：验证 DAO 类无编译错误
- 步骤 10 完成后：验证国际化代码生成成功
- **最终提交前**：执行完整验证流程

---

## 五、实施顺序与依赖关系

```
步骤 1 (Bookmark 模型)  ─┐
步骤 2 (Highlight 模型) ─┼─→ 步骤 3-4 (表定义) → 步骤 5 (AppDatabase) → 步骤 6 (Document 模型)
步骤 10 (国际化)        ─┘                                                ↓
                                                              步骤 7 (BookmarkDao)
                                                              步骤 8 (HighlightDao)
                                                              步骤 9 (DocumentDao)
```

步骤 1/2/10 可并行，步骤 3/4 依赖步骤 1/2，步骤 5 依赖 3/4，步骤 6/7/8/9 依赖步骤 5。
