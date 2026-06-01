# G9-2 - 阅读器增强：Markdown 渲染与高亮系统实施计划

## 一、现状分析

### 1.1 已有代码

| 文件 | 现状 |
|------|------|
| `packages/wiki/lib/screens/reader_page.dart` | 使用只读 `TextField` 显示原始 Markdown 文本，无富文本渲染 |
| `packages/wiki/pubspec.yaml` | 无 `flutter_markdown` 依赖 |
| `packages/chat/lib/screens/message_bubble.dart` | 已使用 `flutter_markdown` 的 `MarkdownBody` + `selectable: true` |

### 1.2 需要实现

1. 将阅读器从 `TextField` 改为 `flutter_markdown` 渲染
2. 自定义 MarkdownBuilder 实现高亮注入
3. 高亮应用算法（TextSpan 切割与样式合并）
4. 文本选择回调（获取选中偏移量）
5. 阅读设置持久化（字体、行距、深色模式）

---

## 二、涉及的文件清单

| 序号 | 文件路径 | 操作 | 说明 |
|------|----------|------|------|
| 1 | `packages/wiki/pubspec.yaml` | 修改 | 添加 `flutter_markdown` 依赖 |
| 2 | `packages/wiki/lib/screens/reader_page.dart` | 修改 | 核心改造：TextField → flutter_markdown + 高亮 |
| 3 | `packages/wiki/lib/widgets/highlight_builder.dart` | 新增 | 自定义 MarkdownBuilder，注入高亮样式 |
| 4 | `packages/wiki/lib/utils/highlight_applier.dart` | 新增 | 高亮应用算法（TextSpan 切割） |
| 5 | `packages/wiki/lib/utils/offset_calculator.dart` | 新增 | Markdown AST 偏移量计算器 |
| 6 | `packages/wiki/res/strings.csv` | 修改 | 新增阅读器相关国际化字符串 |

---

## 三、实施步骤

### 步骤 1：添加 flutter_markdown 依赖

**修改文件**: `packages/wiki/pubspec.yaml`

```yaml
dependencies:
  flutter_markdown: ^0.7.6
  # ... 其他依赖不变
```

执行 `dart pub get` 安装。

### 步骤 2：创建偏移量计算器

**新增文件**: `packages/wiki/lib/utils/offset_calculator.dart`

```dart
import 'package:markdown/markdown.dart' as md;

/// 文本片段，记录在全文纯文本中的位置。
class TextSegment {
  final String text;
  final int globalStart;
  int get globalEnd => globalStart + text.length;
  final List<String> tags; // Markdown 标签路径（如 ['p', 'strong']）

  const TextSegment({
    required this.text,
    required this.globalStart,
    this.tags = const [],
  });
}

/// 从 Markdown AST 中提取文本片段列表，计算全局偏移量。
class OffsetCalculator {
  final List<TextSegment> segments = [];
  int _offset = 0;

  /// 计算 Markdown 源文本的片段列表。
  List<TextSegment> calculate(String markdown) {
    segments.clear();
    _offset = 0;

    final document = md.Document(
      extensionSet: md.ExtensionSet.gitHubFlavored,
      encodeHtml: false,
    );
    final nodes = document.parseLines(const LineSplitter().convert(markdown));

    for (final node in nodes) {
      _walkNode(node, []);
    }

    return List.unmodifiable(segments);
  }

  void _walkNode(md.Node node, List<String> tagPath) {
    if (node is md.Text) {
      final text = node.text;
      if (text.isNotEmpty) {
        segments.add(TextSegment(
          text: text,
          globalStart: _offset,
          tags: List.unmodifiable(tagPath),
        ));
        _offset += text.length;
      }
    } else if (node is md.Element) {
      final newTags = [...tagPath, node.tag];
      if (node.children != null) {
        for (final child in node.children!) {
          _walkNode(child, newTags);
        }
      }
      // 块级元素后添加换行
      if (_isBlockElement(node.tag)) {
        segments.add(TextSegment(
          text: '\n',
          globalStart: _offset,
          tags: List.unmodifiable(tagPath),
        ));
        _offset += 1;
      }
    }
  }

  bool _isBlockElement(String tag) {
    const blockTags = {'p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'li', 'blockquote', 'pre', 'hr'};
    return blockTags.contains(tag);
  }
}
```

**日志接入**:
```dart
import 'package:core/services/app_logger.dart';

// 在 calculate 方法中
AppLogger.instance.d('Markdown 偏移量计算完成: ${segments.length} 个片段, 总长度=$_offset', tag: 'OffsetCalculator');
```

### 步骤 3：创建高亮应用算法

**新增文件**: `packages/wiki/lib/utils/highlight_applier.dart`

```dart
import 'package:flutter/material.dart';
import 'package:core/models/highlight.dart';
import 'package:core/models/highlight_style.dart';
import 'package:core/services/app_logger.dart';
import 'offset_calculator.dart';

/// 高亮应用器。
///
/// 将高亮数据应用到 TextSegment 列表上，生成带高亮样式的 TextSpan。
class HighlightApplier {
  /// 将高亮应用到片段列表，返回最终的 TextSpan。
  static TextSpan apply({
    required List<TextSegment> segments,
    required List<Highlight> highlights,
    required TextStyle baseStyle,
  }) {
    if (highlights.isEmpty) {
      return _buildSimpleSpan(segments, baseStyle);
    }

    // 将高亮按起始位置排序
    final sortedHL = [...highlights]..sort((a, b) => a.startPos.compareTo(b.startPos));

    // 构建带样式的 TextSpan 列表
    final List<TextSpan> children = [];

    for (final seg in segments) {
      _applySegmentHighlights(seg, sortedHL, baseStyle, children);
    }

    return TextSpan(children: children);
  }

  /// 对单个片段应用高亮。
  static void _applySegmentHighlights(
    TextSegment seg,
    List<Highlight> highlights,
    TextStyle baseStyle,
    List<TextSpan> output,
  ) {
    // 找出与当前片段相交的高亮
    final intersecting = highlights.where((hl) =>
        hl.startPos < seg.globalEnd && hl.endPos > seg.globalStart
    ).toList();

    if (intersecting.isEmpty) {
      // 无高亮，直接添加
      if (seg.text.isNotEmpty) {
        output.add(TextSpan(text: seg.text, style: baseStyle));
      }
      return;
    }

    // 有高亮，需要切割片段
    int cursor = seg.globalStart;

    for (final hl in intersecting) {
      final hlStart = hl.startPos.clamp(seg.globalStart, seg.globalEnd);
      final hlEnd = hl.endPos.clamp(seg.globalStart, seg.globalEnd);

      // 高亮前的普通文本
      if (cursor < hlStart) {
        final text = _substring(seg.text, cursor - seg.globalStart, hlStart - seg.globalStart);
        if (text.isNotEmpty) {
          output.add(TextSpan(text: text, style: baseStyle));
        }
      }

      // 高亮文本
      final hlText = _substring(seg.text, hlStart - seg.globalStart, hlEnd - seg.globalStart);
      if (hlText.isNotEmpty) {
        final hlStyle = _mergeHighlightStyle(baseStyle, hl.style);
        output.add(TextSpan(text: hlText, style: hlStyle));
      }

      cursor = hlEnd;
    }

    // 高亮后的剩余文本
    if (cursor < seg.globalEnd) {
      final text = _substring(seg.text, cursor - seg.globalStart, seg.text.length);
      if (text.isNotEmpty) {
        output.add(TextSpan(text: text, style: baseStyle));
      }
    }
  }

  /// 合并基础样式和高亮样式。
  static TextStyle _mergeHighlightStyle(TextStyle base, HighlightStyle hl) {
    if (hl.type == HighlightType.background) {
      return base.copyWith(
        background: Paint()..color = hl.color.withOpacity(hl.opacity),
      );
    } else {
      return base.copyWith(
        decoration: TextDecoration.underline,
        decorationColor: hl.color,
        decorationThickness: 2,
      );
    }
  }

  /// 安全子字符串提取。
  static String _substring(String text, int start, int end) {
    final s = start.clamp(0, text.length);
    final e = end.clamp(0, text.length);
    return s >= e ? '' : text.substring(s, e);
  }

  /// 无高亮时直接构建 TextSpan。
  static TextSpan _buildSimpleSpan(List<TextSegment> segments, TextStyle baseStyle) {
    return TextSpan(
      children: segments
          .where((s) => s.text.isNotEmpty)
          .map((s) => TextSpan(text: s.text, style: baseStyle))
          .toList(),
    );
  }
}
```

**日志接入**:
```dart
// 在 apply 方法开头
AppLogger.instance.d('应用高亮: ${highlights.length} 个高亮, ${segments.length} 个片段', tag: 'HighlightApplier');
```

### 步骤 4：创建自定义 MarkdownBuilder

**新增文件**: `packages/wiki/lib/widgets/highlight_builder.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:core/models/highlight.dart';
import 'package:core/services/app_logger.dart';
import '../utils/offset_calculator.dart';
import '../utils/highlight_applier.dart';

/// 支持高亮的 Markdown 构建器。
///
/// 在 flutter_markdown 渲染管线中注入高亮样式。
class HighlightMarkdownBuilder implements MarkdownBuilder {
  final List<Highlight> highlights;
  final TextStyle baseStyle;

  const HighlightMarkdownBuilder({
    required this.highlights,
    required this.baseStyle,
  });

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    // 不在此处处理，由 visitText 处理
    return null;
  }

  @override
  Widget? visitText(md.Text text) {
    // 不在此处处理
    return null;
  }

  /// 构建带高亮的 RichText Widget。
  ///
  /// 此方法由阅读器在获取到 AST 后调用，
  /// 将整个文档的文本片段和高亮合并为一个 RichText。
  Widget buildRichText({
    required List<TextSegment> segments,
    required TextStyle textStyle,
  }) {
    final span = HighlightApplier.apply(
      segments: segments,
      highlights: highlights,
      baseStyle: textStyle,
    );

    return SelectableText.rich(
      span,
      style: textStyle,
    );
  }
}
```

### 步骤 5：改造 ReaderPage

**修改文件**: `packages/wiki/lib/screens/reader_page.dart`

核心改动：

1. **替换 TextField 为 flutter_markdown + 高亮渲染**
2. **阅读设置持久化**
3. **文本选择回调获取偏移量**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:core/models/highlight.dart';
import 'package:core/services/app_logger.dart';
import 'package:core/services/tts_service.dart';
import '../utils/offset_calculator.dart';
import '../utils/highlight_applier.dart';

class ReaderPage extends ConsumerStatefulWidget {
  final int docId;
  final String? title;
  const ReaderPage({super.key, required this.docId, this.title});
  @override
  ConsumerState<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ReaderPage> {
  // --- 已有状态 ---
  String _content = '';
  // ... 其他已有字段 ...

  // --- 新增状态 ---
  List<TextSegment> _segments = [];
  List<Highlight> _highlights = [];
  final OffsetCalculator _offsetCalculator = OffsetCalculator();

  @override
  void initState() {
    super.initState();
    _loadContent();
    _loadSettings(); // 新增：加载持久化设置
    _loadHighlights(); // 新增：加载高亮数据
  }

  /// 加载持久化的阅读设置。
  Future<void> _loadSettings() async {
    try {
      final settingsDao = SettingsDao();
      final fontSize = await settingsDao.getDouble('reader_font_size') ?? 16.0;
      final lineSpacing = await settingsDao.getDouble('reader_line_spacing') ?? 1.6;
      final isDarkMode = await settingsDao.getBool('reader_dark_mode') ?? false;
      if (mounted) {
        setState(() {
          _fontSize = fontSize;
          _lineSpacing = lineSpacing;
          _isDarkMode = isDarkMode;
        });
      }
      AppLogger.instance.d('阅读设置已加载: size=$_fontSize, spacing=$_lineSpacing, dark=$_isDarkMode', tag: 'Reader');
    } catch (e) {
      AppLogger.instance.w('加载阅读设置失败，使用默认值', tag: 'Reader', error: e);
    }
  }

  /// 保存阅读设置。
  Future<void> _saveSettings() async {
    try {
      final settingsDao = SettingsDao();
      await settingsDao.setDouble('reader_font_size', _fontSize);
      await settingsDao.setDouble('reader_line_spacing', _lineSpacing);
      await settingsDao.setBool('reader_dark_mode', _isDarkMode);
      AppLogger.instance.d('阅读设置已保存', tag: 'Reader');
    } catch (e) {
      AppLogger.instance.w('保存阅读设置失败', tag: 'Reader', error: e);
    }
  }

  /// 加载高亮数据。
  Future<void> _loadHighlights() async {
    try {
      final dao = HighlightDao();
      final highlights = await dao.getByDocId(widget.docId);
      if (mounted) {
        setState(() => _highlights = highlights);
      }
      AppLogger.instance.d('高亮已加载: ${highlights.length} 条', tag: 'Reader');
    } catch (e) {
      AppLogger.instance.w('加载高亮失败', tag: 'Reader', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = _isDarkMode ? Colors.white : Colors.black87;
    final bgColor = _isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final textStyle = TextStyle(
      fontSize: _fontSize,
      height: _lineSpacing,
      color: textColor,
    );

    return Scaffold(
      backgroundColor: bgColor,
      body: _content.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(textStyle),
    );
  }

  Widget _buildContent(TextStyle textStyle) {
    // 计算偏移量（可缓存）
    if (_segments.isEmpty) {
      _segments = _offsetCalculator.calculate(_content);
    }

    // 构建带高亮的 TextSpan
    final span = HighlightApplier.apply(
      segments: _segments,
      highlights: _highlights,
      baseStyle: textStyle,
    );

    return GestureDetector(
      onTap: _toggleToolbar,
      child: Stack(
        children: [
          // 主内容区
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText.rich(
                  span,
                  style: textStyle,
                  onSelectionChanged: (selection, cause) {
                    if (cause == SelectionChangedCause.longPress && !selection.isCollapsed) {
                      _onTextSelected(selection);
                    }
                  },
                ),
                const SizedBox(height: 24),
                // ... 标签显示等 ...
              ],
            ),
          ),
          // 工具栏
          if (_showToolbar) _buildToolbar(),
        ],
      ),
    );
  }

  /// 文本选中回调。
  void _onTextSelected(TextSelection selection) {
    final selectedText = _content.substring(selection.start, selection.end);
    AppLogger.instance.d('文本选中: "$selectedText" [${selection.start},${selection.end})', tag: 'Reader');
    // 后续步骤中弹出 ContextToolbar
    _showSelectionContextMenu(selection, selectedText);
  }

  /// 显示选择上下文菜单（占位，后续步骤替换为 ContextToolbar）。
  void _showSelectionContextMenu(TextSelection selection, String selectedText) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: Text(_strings.reader_copy), // 国际化
              onTap: () {
                Navigator.pop(context);
                _copyText(selectedText);
              },
            ),
            // ... 后续步骤添加更多菜单项 ...
          ],
        ),
      ),
    );
  }

  void _copyText(String text) {
    // ... 已有复制逻辑 ...
  }

  void _toggleToolbar() {
    setState(() => _showToolbar = !_showToolbar);
  }
}
```

### 步骤 6：国际化字符串

**修改文件**: `packages/wiki/res/strings.csv`

新增以下行：

```csv
reader_copy,Copy,复制
reader_bookmark,Bookmark,书签
reader_read_aloud,Read Aloud,朗读
reader_dictionary,Dictionary,字典
reader_browser_search,Browser Search,浏览器搜索
reader_ask_ai,Ask AI,问问 AI
reader_full_text_search,Full Text Search,全文搜索
reader_kb_search,Knowledge Base Search,知识库搜索
reader_highlight_note,Highlight / Note,划重点/笔记
reader_no_bookmarks,No bookmarks,暂无书签
reader_no_highlights,No highlights,暂无笔记
reader_toc,Table of Contents,目录
reader_settings_saved,Reading settings saved,阅读设置已保存
reader_highlight_applied,Highlight applied,高亮已添加
reader_note_saved,Note saved,笔记已保存
```

---

## 四、高亮应用算法详解

### 4.1 算法概述

将高亮区间映射到 TextSegment 列表上，对相交的片段进行切割并合并样式。

### 4.2 算法步骤

```
输入：
  - segments: List<TextSegment>  // 文本片段，每个有 globalStart/globalEnd
  - highlights: List<Highlight>  // 高亮列表，每个有 startPos/endPos/style

输出：
  - TextSpan 树，带高亮样式

流程：
  1. 将 highlights 按 startPos 排序
  2. 遍历每个 segment：
     a. 找出与当前 segment 相交的所有 highlights
     b. 若无相交，直接输出 TextSpan(text, baseStyle)
     c. 若有相交：
        - 维护 cursor = segment.globalStart
        - 遍历每个相交的 highlight：
          · 输出 cursor ~ hlStart 的普通文本
          · 输出 hlStart ~ hlEnd 的高亮文本（合并样式）
          · cursor = hlEnd
        - 输出 cursor ~ segment.globalEnd 的剩余文本
  3. 返回 TextSpan(children: [...])
```

### 4.3 样式合并规则

```
基础样式 baseStyle + 高亮样式 hlStyle → 最终样式

背景色高亮（type = bg）:
  baseStyle.copyWith(
    background: Paint()..color = hlColor.withOpacity(opacity)
  )

下划线高亮（type = underline）:
  baseStyle.copyWith(
    decoration: TextDecoration.underline,
    decorationColor: hlColor,
    decorationThickness: 2,
  )
```

### 4.4 边界处理

- 高亮起始在 segment 之前 → 从 segment 开始
- 高亮结束在 segment 之后 → 到 segment 结束
- 多个高亮重叠 → 依次应用（后者覆盖前者）
- 空文本片段 → 跳过

---

## 五、验收步骤

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
grep -r "Text('[一-鿿]" --include="*.dart" packages/wiki/lib/screens/reader_page.dart packages/wiki/lib/widgets/highlight_builder.dart packages/wiki/lib/utils/offset_calculator.dart packages/wiki/lib/utils/highlight_applier.dart --exclude-dir=gen
```

### 验证标准

| 检查项 | 必须满足 | 不满足时处理 |
|--------|----------|-------------|
| `dart analyze` error 数 | 0 | 修复所有 error 后重新验证 |
| `flutter test` 失败数 | 0 | 修复失败测试后重新验证 |
| 代码生成 | 成功无报错 | 检查 CSV 格式后重新验证 |
| 硬编码中文 | 0 匹配 | 替换为 `_strings.xxx` 后重新验证 |

### 验证时机

- 步骤 1 完成后：验证 `flutter_markdown` 依赖安装成功
- 步骤 2-3 完成后：验证偏移量计算和高亮应用算法无编译错误
- 步骤 4 完成后：验证 HighlightMarkdownBuilder 无编译错误
- 步骤 5 完成后：验证 ReaderPage 改造无编译错误
- 步骤 6 完成后：验证国际化代码生成成功
- **最终提交前**：执行完整验证流程

---

## 六、实施顺序与依赖关系

```
步骤 1 (flutter_markdown 依赖)
  ↓
步骤 2 (OffsetCalculator) ─┐
步骤 3 (HighlightApplier)  ─┼─→ 步骤 4 (HighlightBuilder) → 步骤 5 (ReaderPage 改造)
步骤 6 (国际化)             ─┘
```

步骤 1 是基础，步骤 2/3/6 可并行，步骤 4 依赖 2/3，步骤 5 依赖 4。
