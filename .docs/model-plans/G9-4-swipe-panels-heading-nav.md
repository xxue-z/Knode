# G9-4 - 阅读器增强：侧滑面板与标题导航实施计划

## 一、现状分析

### 1.1 已有代码

| 文件 | 现状 |
|------|------|
| `packages/wiki/lib/screens/reader_page.dart` | 无手势导航，无侧滑面板，无标题目录 |
| `packages/core/lib/database/dao/bookmark_dao.dart` | G9-1 新建，提供书签 CRUD |
| `packages/core/lib/database/dao/highlight_dao.dart` | G9-1 新建，提供高亮 CRUD |
| `packages/wiki/lib/utils/offset_calculator.dart` | G9-2 新建，可提取 AST 中的标题节点 |

### 1.2 需要实现

1. 左滑→右：书签侧滑面板
2. 右滑→左：笔记侧滑面板
3. 标题导航（目录）：从 Markdown AST 提取 H1/H2/H3，树形展示，点击定位

---

## 二、涉及的文件清单

| 序号 | 文件路径 | 操作 | 说明 |
|------|----------|------|------|
| 1 | `packages/wiki/lib/widgets/bookmark_panel.dart` | 新增 | 书签侧滑面板 |
| 2 | `packages/wiki/lib/widgets/note_panel.dart` | 新增 | 笔记侧滑面板 |
| 3 | `packages/wiki/lib/widgets/heading_nav_sheet.dart` | 新增 | 标题导航底部弹窗 |
| 4 | `packages/wiki/lib/utils/heading_parser.dart` | 新增 | Markdown 标题解析器 |
| 5 | `packages/wiki/lib/screens/reader_page.dart` | 修改 | 集成手势导航和标题导航 |
| 6 | `packages/wiki/res/strings.csv` | 修改 | 新增面板和导航相关国际化字符串 |

---

## 三、实施步骤

### 步骤 1：创建标题解析器

**新增文件**: `packages/wiki/lib/utils/heading_parser.dart`

```dart
import 'package:markdown/markdown.dart' as md;
import 'package:core/services/app_logger.dart';

/// 文档标题节点。
class HeadingNode {
  final String title;
  final int level; // 1=H1, 2=H2, 3=H3
  final int offset; // 在纯文本中的字符偏移量

  const HeadingNode({
    required this.title,
    required this.level,
    required this.offset,
  });
}

/// 从 Markdown 源文本中提取标题（H1/H2/H3）。
class HeadingParser {
  /// 解析 Markdown 源文本，返回标题列表。
  static List<HeadingNode> parse(String markdown) {
    final document = md.Document(
      extensionSet: md.ExtensionSet.gitHubFlavored,
      encodeHtml: false,
    );
    final nodes = document.parseLines(const LineSplitter().convert(markdown));

    final headings = <HeadingNode>[];
    int offset = 0;

    for (final node in nodes) {
      _extractHeadings(node, headings, offset);
      // 累积偏移量
      offset = _calculateNodeLength(node, offset);
    }

    AppLogger.instance.d('标题解析完成: ${headings.length} 个标题', tag: 'HeadingParser');
    return headings;
  }

  /// 递归提取标题节点。
  static void _extractHeadings(md.Node node, List<HeadingNode> headings, int offset) {
    if (node is md.Element && _isHeadingTag(node.tag)) {
      final level = int.parse(node.tag.substring(1)); // h1→1, h2→2, ...
      final title = _extractText(node);
      if (title.isNotEmpty) {
        headings.add(HeadingNode(
          title: title,
          level: level,
          offset: offset,
        ));
      }
    }
    if (node is md.Element && node.children != null) {
      int childOffset = offset;
      for (final child in node.children!) {
        _extractHeadings(child, headings, childOffset);
        childOffset = _calculateNodeLength(child, childOffset);
      }
    }
  }

  /// 提取节点的纯文本内容。
  static String _extractText(md.Node node) {
    if (node is md.Text) return node.text;
    if (node is md.Element && node.children != null) {
      return node.children!.map(_extractText).join();
    }
    return '';
  }

  /// 判断是否为标题标签。
  static bool _isHeadingTag(String tag) {
    return tag == 'h1' || tag == 'h2' || tag == 'h3' ||
           tag == 'h4' || tag == 'h5' || tag == 'h6';
  }

  /// 计算节点的文本长度。
  static int _calculateNodeLength(md.Node node, int currentOffset) {
    if (node is md.Text) return currentOffset + node.text.length;
    if (node is md.Element) {
      int offset = currentOffset;
      if (node.children != null) {
        for (final child in node.children!) {
          offset = _calculateNodeLength(child, offset);
        }
      }
      // 块级元素加换行
      if (_isBlockElement(node.tag)) offset += 1;
      return offset;
    }
    return currentOffset;
  }

  static bool _isBlockElement(String tag) {
    const blockTags = {'p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'li', 'blockquote', 'pre', 'hr'};
    return blockTags.contains(tag);
  }
}
```

### 步骤 2：创建书签侧滑面板

**新增文件**: `packages/wiki/lib/widgets/bookmark_panel.dart`

```dart
import 'package:flutter/material.dart';
import 'package:core/models/bookmark.dart';
import 'package:core/database/dao/bookmark_dao.dart';
import 'package:core/services/app_logger.dart';

/// 书签侧滑面板。
///
/// 从左往右滑动呼出，展示当前文档的所有书签。
class BookmarkPanel extends StatelessWidget {
  final int docId;
  final void Function(Bookmark bookmark) onTap;
  final void Function(Bookmark bookmark) onDelete;

  const BookmarkPanel({
    super.key,
    required this.docId,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Bookmark>>(
      future: BookmarkDao().getByDocId(docId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final bookmarks = snapshot.data ?? [];

        if (bookmarks.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bookmark_border, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  _strings.reader_no_bookmarks, // 国际化
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: bookmarks.length,
          itemBuilder: (context, index) {
            final bm = bookmarks[index];
            return Dismissible(
              key: ValueKey(bm.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) {
                onDelete(bm);
                AppLogger.instance.d('书签滑动删除: id=${bm.id}', tag: 'BookmarkPanel');
              },
              child: ListTile(
                leading: const Icon(Icons.bookmark, color: Colors.amber),
                title: Text(
                  bm.selectedText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  _formatDate(bm.createdAt), // 日期格式化
                  style: const TextStyle(fontSize: 11),
                ),
                onTap: () => onTap(bm),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
```

### 步骤 3：创建笔记侧滑面板

**新增文件**: `packages/wiki/lib/widgets/note_panel.dart`

```dart
import 'package:flutter/material.dart';
import 'package:core/models/highlight.dart';
import 'package:core/database/dao/highlight_dao.dart';
import 'package:core/services/app_logger.dart';

/// 笔记侧滑面板。
///
/// 从右往左滑动呼出，展示当前文档的所有高亮/笔记。
class NotePanel extends StatelessWidget {
  final int docId;
  final void Function(Highlight highlight) onTap;
  final VoidCallback onViewNoteDocuments;

  const NotePanel({
    super.key,
    required this.docId,
    required this.onTap,
    required this.onViewNoteDocuments,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Highlight>>(
      future: HighlightDao().getWithNotes(docId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final highlights = snapshot.data ?? [];

        if (highlights.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.note_alt_outlined, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  _strings.reader_no_highlights, // 国际化
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: highlights.length,
                itemBuilder: (context, index) {
                  final hl = highlights[index];
                  return ListTile(
                    leading: Container(
                      width: 4,
                      height: 32,
                      decoration: BoxDecoration(
                        color: hl.style.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    title: Text(
                      hl.selectedText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: hl.noteText != null
                        ? Text(
                            hl.noteText!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                          )
                        : null,
                    onTap: () => onTap(hl),
                  );
                },
              ),
            ),
            // 底部入口：查看笔记文档
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.description, size: 20),
              title: Text(_strings.reader_view_note_documents), // 国际化
              dense: true,
              onTap: onViewNoteDocuments,
            ),
          ],
        );
      },
    );
  }
}
```

### 步骤 4：创建标题导航底部弹窗

**新增文件**: `packages/wiki/lib/widgets/heading_nav_sheet.dart`

```dart
import 'package:flutter/material.dart';
import '../utils/heading_parser.dart';
import 'package:core/services/app_logger.dart';

/// 标题导航底部弹窗（目录）。
///
/// 从 Markdown AST 提取 H1/H2/H3，树形展示，点击定位。
class HeadingNavSheet extends StatelessWidget {
  final List<HeadingNode> headings;
  final void Function(HeadingNode heading) onTap;

  const HeadingNavSheet({
    super.key,
    required this.headings,
    required this.onTap,
  });

  /// 显示标题导航弹窗。
  static void show(
    BuildContext context, {
    required List<HeadingNode> headings,
    required void Function(HeadingNode heading) onTap,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => HeadingNavSheet(headings: headings, onTap: onTap),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (headings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            _strings.reader_no_headings, // 国际化
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // 标题栏
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.toc, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    _strings.reader_toc, // 国际化
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 标题列表
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: headings.length,
                itemBuilder: (context, index) {
                  final heading = headings[index];
                  final indent = heading.level - 1;

                  return InkWell(
                    onTap: () {
                      AppLogger.instance.d('标题导航点击: ${heading.title}', tag: 'HeadingNav');
                      Navigator.pop(context);
                      onTap(heading);
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 16.0 + indent * 24.0,
                        right: 16,
                        top: 8,
                        bottom: 8,
                      ),
                      child: Row(
                        children: [
                          if (heading.level == 1)
                            Icon(Icons.circle, size: 8, color: Theme.of(context).colorScheme.primary)
                          else if (heading.level == 2)
                            Icon(Icons.circle_outlined, size: 6, color: Colors.grey[600])
                          else
                            Icon(Icons.remove, size: 6, color: Colors.grey[400]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              heading.title,
                              style: TextStyle(
                                fontSize: heading.level == 1 ? 16 : 14,
                                fontWeight: heading.level == 1 ? FontWeight.bold : FontWeight.normal,
                                color: heading.level == 1
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
```

### 步骤 5：改造 ReaderPage — 集成手势导航和标题导航

**修改文件**: `packages/wiki/lib/screens/reader_page.dart`

核心改动：

```dart
import '../widgets/bookmark_panel.dart';
import '../widgets/note_panel.dart';
import '../widgets/heading_nav_sheet.dart';
import '../utils/heading_parser.dart';

class _ReaderPageState extends ConsumerState<ReaderPage> {
  // --- 新增状态 ---
  List<HeadingNode> _headings = [];

  @override
  void initState() {
    super.initState();
    _loadContent();
    _loadSettings();
    _loadHighlights();
    _parseHeadings(); // 新增
  }

  /// 解析文档标题。
  void _parseHeadings() {
    if (_content.isNotEmpty) {
      _headings = HeadingParser.parse(_content);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... 已有代码 ...

    return Scaffold(
      backgroundColor: bgColor,
      // 左侧 Drawer：书签面板
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.bookmark, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(_strings.reader_bookmarks, style: Theme.of(context).textTheme.titleMedium), // 国际化
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: BookmarkPanel(
                  docId: widget.docId,
                  onTap: (bm) {
                    Navigator.pop(context); // 关闭 Drawer
                    _scrollToOffset(bm.position);
                  },
                  onDelete: (bm) async {
                    await BookmarkDao().delete(bm.id!);
                    // 刷新面板
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // 右侧 Drawer：笔记面板
      endDrawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.note_alt, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(_strings.reader_notes, style: Theme.of(context).textTheme.titleMedium), // 国际化
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: NotePanel(
                  docId: widget.docId,
                  onTap: (hl) {
                    Navigator.pop(context);
                    _scrollToOffset(hl.startPos);
                  },
                  onViewNoteDocuments: () {
                    Navigator.pop(context);
                    _viewNoteDocuments();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: GestureDetector(
        // 左滑→右：打开书签面板
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
            // 从左往右滑
            Scaffold.of(context).openDrawer();
          } else if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
            // 从右往左滑
            Scaffold.of(context).openEndDrawer();
          }
        },
        onTap: _toggleToolbar,
        child: Stack(
          children: [
            // ... 已有内容 ...
            // 工具栏中新增目录按钮
            if (_showToolbar) _buildToolbar(),
          ],
        ),
      ),
    );
  }

  /// 滚动到指定偏移量。
  void _scrollToOffset(int offset) {
    // 根据偏移量找到对应的段落位置并滚动
    // 使用 Scrollable.ensureVisible 或直接跳转
    AppLogger.instance.d('滚动到偏移量: $offset', tag: 'Reader');
    // 具体实现依赖于内容渲染方式
  }

  /// 查看笔记文档。
  Future<void> _viewNoteDocuments() async {
    try {
      final dao = DocumentDao();
      final noteDocs = await dao.getNoteDocuments(widget.docId);
      if (noteDocs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_strings.reader_no_note_documents)), // 国际化
          );
        }
        return;
      }
      // 显示笔记文档列表
      if (mounted) {
        showModalBottomSheet(
          context: context,
          builder: (context) => ListView.builder(
            shrinkWrap: true,
            itemCount: noteDocs.length,
            itemBuilder: (context, index) {
              final doc = noteDocs[index];
              return ListTile(
                leading: const Icon(Icons.description),
                title: Text(doc.title),
                onTap: () {
                  Navigator.pop(context);
                  // 打开笔记文档
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReaderPage(docId: doc.id!, title: doc.title),
                    ),
                  );
                },
              );
            },
          ),
        );
      }
    } catch (e) {
      AppLogger.instance.e('查看笔记文档失败', tag: 'Reader', error: e);
    }
  }

  /// 在工具栏中新增目录按钮。
  Widget _buildToolbar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Text(
                widget.title ?? '',
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // 目录按钮（新增）
            IconButton(
              icon: const Icon(Icons.toc),
              tooltip: _strings.reader_toc, // 国际化
              onPressed: () {
                HeadingNavSheet.show(
                  context,
                  headings: _headings,
                  onTap: (heading) => _scrollToOffset(heading.offset),
                );
              },
            ),
            // ... 已有 TTS、字体、行距、深色模式按钮 ...
          ],
        ),
      ),
    );
  }
}
```

### 步骤 6：国际化字符串

**修改文件**: `packages/wiki/res/strings.csv`

新增以下行：

```csv
reader_bookmarks,Bookmarks,书签
reader_notes,Notes,笔记
reader_no_note_documents,No note documents,暂无笔记文档
reader_no_headings,No headings found,未找到标题
```

---

## 四、验收步骤

> **每个步骤完成后、提交代码前，必须通过以下验证命令。未通过验证的代码禁止提交。**

### 验证命令

```bash
# 1. 静态分析（必须 0 error）
dart analyze packages/wiki

# 2. 运行所有测试（必须全部通过）
flutter test packages/wiki

# 3. 国际化代码生成（必须成功）
dart run monolith_runner:localization

# 4. 硬编码中文扫描（必须 0 匹配）
grep -r "Text('[一-鿿]" --include="*.dart" packages/wiki/lib/widgets/bookmark_panel.dart packages/wiki/lib/widgets/note_panel.dart packages/wiki/lib/widgets/heading_nav_sheet.dart packages/wiki/lib/utils/heading_parser.dart packages/wiki/lib/screens/reader_page.dart --exclude-dir=gen
```

### 验证标准

| 检查项 | 必须满足 | 不满足时处理 |
|--------|----------|-------------|
| `dart analyze` error 数 | 0 | 修复所有 error 后重新验证 |
| `flutter test` 失败数 | 0 | 修复失败测试后重新验证 |
| 代码生成 | 成功无报错 | 检查 CSV 格式后重新验证 |
| 硬编码中文 | 0 匹配 | 替换为 `_strings.xxx` 后重新验证 |

### 验证时机

- 步骤 1 完成后：验证 HeadingParser 无编译错误
- 步骤 2-3 完成后：验证 BookmarkPanel/NotePanel 无编译错误
- 步骤 4 完成后：验证 HeadingNavSheet 无编译错误
- 步骤 5 完成后：验证 ReaderPage 集成无编译错误
- 步骤 6 完成后：验证国际化代码生成成功
- **最终提交前**：执行完整验证流程

---

## 五、实施顺序与依赖关系

```
步骤 1 (HeadingParser)     ─┐
步骤 2 (BookmarkPanel)      ─┼─→ 步骤 5 (ReaderPage 集成)
步骤 3 (NotePanel)          ─┤
步骤 4 (HeadingNavSheet)    ─┤
步骤 6 (国际化)             ─┘
```

步骤 1/2/3/4/6 可并行，步骤 5 依赖 1/2/3/4 完成。
