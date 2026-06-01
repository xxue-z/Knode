# G9-3 - 阅读器增强：上下文工具栏实施计划

## 一、现状分析

### 1.1 已有代码

| 文件 | 现状 |
|------|------|
| `packages/wiki/lib/screens/reader_page.dart` | 已有 `_showSelectionContextMenu` 方法，使用 `showModalBottomSheet` 显示 3 个选项（AI 解释、生成题目、复制） |
| `packages/core/lib/services/tts_service.dart` | 已有 TTS 服务，支持 `speak(text)` / `pause()` / `stop()` |
| `packages/core/lib/services/ai_provider.dart` | 已有 AIProvider 接口，支持 `generateAnswer()` 和 `generateQuiz()` |

### 1.2 需要实现

1. 替换现有 `showModalBottomSheet` 为浮动 ContextToolbar
2. 实现 9 个菜单项：复制、书签、朗读、字典、浏览器搜索、问问 AI、全文搜索、知识库搜索、划重点/笔记
3. 全文搜索 UI（匹配计数 + 上下切换）
4. 问问 AI 流程（内置 + 外部应用）

---

## 二、涉及的文件清单

| 序号 | 文件路径 | 操作 | 说明 |
|------|----------|------|------|
| 1 | `packages/wiki/lib/widgets/context_toolbar.dart` | 新增 | 浮动上下文工具栏 Widget |
| 2 | `packages/wiki/lib/screens/reader_page.dart` | 修改 | 替换 _showSelectionContextMenu 为 ContextToolbar |
| 3 | `packages/wiki/lib/widgets/fulltext_search_bar.dart` | 新增 | 文档内全文搜索栏 |
| 4 | `packages/wiki/lib/widgets/note_editor_sheet.dart` | 新增 | 笔记输入底部弹窗 |
| 5 | `packages/wiki/res/strings.csv` | 修改 | 新增工具栏相关国际化字符串 |

---

## 三、实施步骤

### 步骤 1：创建 ContextToolbar Widget

**新增文件**: `packages/wiki/lib/widgets/context_toolbar.dart`

```dart
import 'package:flutter/material.dart';
import 'package:core/services/app_logger.dart';

/// 工具栏菜单项定义。
class ToolbarMenuItem {
  final IconData icon;
  final String label; // 国际化后的标签
  final VoidCallback onTap;

  const ToolbarMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

/// 上下文浮动工具栏。
///
/// 定位到选中区域上方或下方，水平滚动按钮栏。
class ContextToolbar extends StatelessWidget {
  final List<ToolbarMenuItem> items;
  final bool showAbove; // true=显示在选区上方，false=下方

  const ContextToolbar({
    super.key,
    required this.items,
    this.showAbove = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.95),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: items.map((item) => _ToolbarButton(item: item)).toList(),
          ),
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final ToolbarMenuItem item;
  const _ToolbarButton({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        AppLogger.instance.d('工具栏点击: ${item.label}', tag: 'ContextToolbar');
        item.onTap();
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 20),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: const TextStyle(fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
```

### 步骤 2：创建全文搜索栏

**新增文件**: `packages/wiki/lib/widgets/fulltext_search_bar.dart`

```dart
import 'package:flutter/material.dart';
import 'package:core/services/app_logger.dart';

/// 文档内全文搜索栏。
///
/// 显示匹配计数 + 上一个/下一个按钮。
class FullTextSearchBar extends StatefulWidget {
  final String documentText;
  final void Function(int offset) onNavigate; // 跳转到匹配位置

  const FullTextSearchBar({
    super.key,
    required this.documentText,
    required this.onNavigate,
  });

  @override
  State<FullTextSearchBar> createState() => _FullTextSearchBarState();
}

class _FullTextSearchBarState extends State<FullTextSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  List<int> _matchOffsets = [];
  int _currentMatchIndex = -1;

  @override
  void initState() {
    super.initState();
    // 初始搜索词可从外部传入
  }

  void _search(String keyword) {
    if (keyword.isEmpty) {
      setState(() {
        _matchOffsets = [];
        _currentMatchIndex = -1;
      });
      return;
    }

    final offsets = <int>[];
    int startIndex = 0;
    final lowerText = widget.documentText.toLowerCase();
    final lowerKeyword = keyword.toLowerCase();

    while (true) {
      final index = lowerText.indexOf(lowerKeyword, startIndex);
      if (index == -1) break;
      offsets.add(index);
      startIndex = index + 1;
    }

    setState(() {
      _matchOffsets = offsets;
      _currentMatchIndex = offsets.isEmpty ? -1 : 0;
    });

    AppLogger.instance.d('全文搜索: "$keyword", ${offsets.length} 个匹配', tag: 'FullTextSearch');

    if (offsets.isNotEmpty) {
      widget.onNavigate(offsets[0]);
    }
  }

  void _goToPrevious() {
    if (_matchOffsets.isEmpty) return;
    setState(() {
      _currentMatchIndex = (_currentMatchIndex - 1 + _matchOffsets.length) % _matchOffsets.length;
    });
    widget.onNavigate(_matchOffsets[_currentMatchIndex]);
  }

  void _goToNext() {
    if (_matchOffsets.isEmpty) return;
    setState(() {
      _currentMatchIndex = (_currentMatchIndex + 1) % _matchOffsets.length;
    });
    widget.onNavigate(_matchOffsets[_currentMatchIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: _strings.reader_search_hint, // 国际化
                isDense: true,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: _matchOffsets.isNotEmpty
                    ? Text(
                        '${_currentMatchIndex + 1}/${_matchOffsets.length}',
                        style: const TextStyle(fontSize: 12),
                      )
                    : null,
              ),
              onSubmitted: _search,
              onChanged: (v) => _search(v), // 实时搜索
            ),
          ),
          if (_matchOffsets.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_up, size: 20),
              onPressed: _goToPrevious,
              tooltip: _strings.reader_previous_match, // 国际化
            ),
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_down, size: 20),
              onPressed: _goToNext,
              tooltip: _strings.reader_next_match, // 国际化
            ),
          ],
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _matchOffsets = [];
                _currentMatchIndex = -1;
              });
              // 通知父组件关闭搜索栏
            },
          ),
        ],
      ),
    );
  }
}
```

### 步骤 3：创建笔记输入弹窗

**新增文件**: `packages/wiki/lib/widgets/note_editor_sheet.dart`

```dart
import 'package:flutter/material.dart';
import 'package:core/services/app_logger.dart';

/// 笔记输入底部弹窗。
///
/// 返回用户输入的笔记文本，若用户取消则返回 null。
class NoteEditorSheet extends StatefulWidget {
  final String selectedText; // 选中的原文（用于预览）

  const NoteEditorSheet({super.key, required this.selectedText});

  /// 显示笔记输入弹窗，返回笔记文本或 null。
  static Future<String?> show(BuildContext context, String selectedText) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => NoteEditorSheet(selectedText: selectedText),
    );
  }

  @override
  State<NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends State<NoteEditorSheet> {
  final TextEditingController _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Text(_strings.reader_add_note, style: Theme.of(context).textTheme.titleMedium), // 国际化
          const SizedBox(height: 8),
          // 选中文字预览
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.selectedText,
              style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          // 笔记输入框
          TextField(
            controller: _noteController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: _strings.reader_note_hint, // 国际化
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          // 按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(_strings.reader_skip_note), // 国际化
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  final note = _noteController.text.trim();
                  AppLogger.instance.d('笔记输入完成: ${note.length} 字', tag: 'NoteEditor');
                  Navigator.pop(context, note.isEmpty ? null : note);
                },
                child: Text(_strings.reader_save_note), // 国际化
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
```

### 步骤 4：改造 ReaderPage — 替换上下文菜单

**修改文件**: `packages/wiki/lib/screens/reader_page.dart`

替换 `_showSelectionContextMenu` 方法，使用 ContextToolbar：

```dart
import 'package:url_launcher/url_launcher.dart';
import 'package:clipboard/clipboard.dart';
import 'package:core/models/highlight.dart';
import 'package:core/models/highlight_style.dart';
import '../widgets/context_toolbar.dart';
import '../widgets/fulltext_search_bar.dart';
import '../widgets/note_editor_sheet.dart';

/// 显示上下文工具栏。
void _showSelectionContextMenu(TextSelection selection, String selectedText) {
  // 计算工具栏位置
  // 使用 Overlay 或 showDialog 定位到选区附近
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      // 位置计算：选区上方或下方
      top: _calculateToolbarTop(selection),
      left: 16,
      right: 16,
      child: ContextToolbar(
        showAbove: _shouldShowAbove(selection),
        items: [
          // 1. 复制
          ToolbarMenuItem(
            icon: Icons.copy,
            label: _strings.reader_copy,
            onTap: () {
              overlayEntry.remove();
              _copyText(selectedText);
            },
          ),
          // 2. 书签
          ToolbarMenuItem(
            icon: Icons.bookmark_add,
            label: _strings.reader_bookmark,
            onTap: () {
              overlayEntry.remove();
              _saveBookmark(selection, selectedText);
            },
          ),
          // 3. 朗读
          ToolbarMenuItem(
            icon: Icons.volume_up,
            label: _strings.reader_read_aloud,
            onTap: () {
              overlayEntry.remove();
              _speakSelected(selectedText);
            },
          ),
          // 4. 字典
          ToolbarMenuItem(
            icon: Icons.menu_book,
            label: _strings.reader_dictionary,
            onTap: () {
              overlayEntry.remove();
              _showDictSheet(selectedText);
            },
          ),
          // 5. 浏览器搜索
          ToolbarMenuItem(
            icon: Icons.open_in_browser,
            label: _strings.reader_browser_search,
            onTap: () {
              overlayEntry.remove();
              _searchInBrowser(selectedText);
            },
          ),
          // 6. 问问 AI
          ToolbarMenuItem(
            icon: Icons.psychology,
            label: _strings.reader_ask_ai,
            onTap: () {
              overlayEntry.remove();
              _askAI(selectedText);
            },
          ),
          // 7. 全文搜索
          ToolbarMenuItem(
            icon: Icons.find_in_page,
            label: _strings.reader_full_text_search,
            onTap: () {
              overlayEntry.remove();
              _startFullTextSearch(selectedText);
            },
          ),
          // 8. 知识库搜索
          ToolbarMenuItem(
            icon: Icons.search,
            label: _strings.reader_kb_search,
            onTap: () {
              overlayEntry.remove();
              _searchKnowledgeBase(selectedText);
            },
          ),
          // 9. 划重点/笔记
          ToolbarMenuItem(
            icon: Icons.highlight,
            label: _strings.reader_highlight_note,
            onTap: () {
              overlayEntry.remove();
              _addHighlightOrNote(selection, selectedText);
            },
          ),
        ],
      ),
    ),
  );

  overlay.insert(overlayEntry);
}

/// 复制文本。
void _copyText(String text) {
  Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(_strings.reader_copied)), // 国际化
  );
  AppLogger.instance.d('文本已复制', tag: 'Reader');
}

/// 保存书签。
Future<void> _saveBookmark(TextSelection selection, String selectedText) async {
  try {
    final dao = BookmarkDao();
    await dao.insert(Bookmark(
      docId: widget.docId,
      position: selection.start,
      endPosition: selection.end,
      selectedText: selectedText,
      createdAt: DateTime.now(),
    ));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_strings.reader_bookmark_saved)), // 国际化
      );
    }
  } catch (e) {
    AppLogger.instance.e('保存书签失败', tag: 'Reader', error: e);
  }
}

/// 朗读选中文本。
void _speakSelected(String text) {
  TtsService.instance.speak(text);
  setState(() => _isSpeaking = true);
  AppLogger.instance.d('朗读选中文本: ${text.length} 字', tag: 'Reader');
}

/// 打开字典。
void _showDictSheet(String word) {
  // G9-5 中实现
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => const SizedBox(), // 占位，G9-5 替换
  );
}

/// 浏览器搜索。
Future<void> _searchInBrowser(String text) async {
  final url = Uri.parse('https://www.google.com/search?q=${Uri.encodeComponent(text)}');
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
    AppLogger.instance.d('浏览器搜索: $text', tag: 'Reader');
  }
}

/// 问问 AI。
Future<void> _askAI(String text) async {
  // 默认用内置 AI
  try {
    final aiProvider = ref.read(aiProviderProvider);
    final answer = await aiProvider.generateAnswer(
      question: text,
      context: '',
    );
    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(_strings.reader_ai_answer), // 国际化
          content: SingleChildScrollView(child: Text(answer)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_strings.reader_close), // 国际化
            ),
          ],
        ),
      );
    }
  } catch (e) {
    AppLogger.instance.e('AI 回答失败', tag: 'Reader', error: e);
    // 回退：复制到剪贴板
    _copyText(text);
  }
}

/// 启动全文搜索。
void _startFullTextSearch(String text) {
  setState(() {
    _showFullTextSearch = true;
    _searchKeyword = text;
  });
}

/// 知识库搜索。
Future<void> _searchKnowledgeBase(String text) async {
  // 调用已有的 RAG 搜索
  AppLogger.instance.d('知识库搜索: $text', tag: 'Reader');
  // 跳转到搜索结果页（复用已有逻辑）
}

/// 添加高亮/笔记。
Future<void> _addHighlightOrNote(TextSelection selection, String selectedText) async {
  // 弹出样式选择器
  final style = await _showStylePicker();
  if (style == null) return;

  // 弹出笔记输入（可选）
  final note = await NoteEditorSheet.show(context, selectedText);

  // 保存高亮
  try {
    final dao = HighlightDao();
    final now = DateTime.now();
    final highlight = Highlight(
      docId: widget.docId,
      startPos: selection.start,
      endPos: selection.end,
      selectedText: selectedText,
      style: style,
      noteText: note,
      createdAt: now,
      updatedAt: now,
    );
    await dao.Insert(highlight);

    // 刷新高亮
    await _loadHighlights();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_strings.reader_highlight_applied)), // 国际化
      );
    }
  } catch (e) {
    AppLogger.instance.e('添加高亮失败', tag: 'Reader', error: e);
  }
}

/// 显示高亮样式选择器。
Future<HighlightStyle?> _showStylePicker() async {
  // 从设置中读取预设样式
  final presets = HighlightStyle.presets;

  return showDialog<HighlightStyle>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(_strings.reader_select_style), // 国际化
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: presets.map((style) {
          return GestureDetector(
            onTap: () => Navigator.pop(context, style),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: style.type == HighlightType.background
                    ? style.color.withOpacity(style.opacity)
                    : null,
                border: style.type == HighlightType.underline
                    ? Border(bottom: BorderSide(color: style.color, width: 3))
                    : Border.all(color: style.color),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }).toList(),
      ),
    ),
  );
}
```

### 步骤 5：国际化字符串

**修改文件**: `packages/wiki/res/strings.csv`

新增以下行：

```csv
reader_copied,Copied to clipboard,已复制到剪贴板
reader_bookmark_saved,Bookmark saved,书签已保存
reader_ai_answer,AI Answer,AI 回答
reader_close,Close,关闭
reader_add_note,Add Note,添加笔记
reader_note_hint,Enter your note here...,输入笔记内容...
reader_skip_note,Skip,跳过
reader_save_note,Save,保存
reader_search_hint,Search in document...,搜索文档...
reader_previous_match,Previous match,上一个匹配
reader_next_match,Next match,下一个匹配
reader_select_style,Select highlight style,选择高亮样式
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
grep -r "Text('[一-鿿]" --include="*.dart" packages/wiki/lib/widgets/context_toolbar.dart packages/wiki/lib/widgets/fulltext_search_bar.dart packages/wiki/lib/widgets/note_editor_sheet.dart packages/wiki/lib/screens/reader_page.dart --exclude-dir=gen
```

### 验证标准

| 检查项 | 必须满足 | 不满足时处理 |
|--------|----------|-------------|
| `dart analyze` error 数 | 0 | 修复所有 error 后重新验证 |
| `flutter test` 失败数 | 0 | 修复失败测试后重新验证 |
| 代码生成 | 成功无报错 | 检查 CSV 格式后重新验证 |
| 硬编码中文 | 0 匹配 | 替换为 `_strings.xxx` 后重新验证 |

### 验证时机

- 步骤 1 完成后：验证 ContextToolbar 无编译错误
- 步骤 2 完成后：验证 FullTextSearchBar 无编译错误
- 步骤 3 完成后：验证 NoteEditorSheet 无编译错误
- 步骤 4 完成后：验证 ReaderPage 工具栏集成无编译错误
- 步骤 5 完成后：验证国际化代码生成成功
- **最终提交前**：执行完整验证流程

---

## 五、实施顺序与依赖关系

```
步骤 1 (ContextToolbar)    ─┐
步骤 2 (FullTextSearchBar)  ─┼─→ 步骤 4 (ReaderPage 集成)
步骤 3 (NoteEditorSheet)    ─┤
步骤 5 (国际化)             ─┘
```

步骤 1/2/3/5 可并行，步骤 4 依赖 1/2/3 完成。
