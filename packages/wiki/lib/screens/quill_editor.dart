import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// flutter_quill 编辑器封装组件。
///
/// 提供统一的编辑器配置和工具栏，支持 Markdown ↔ Quill Delta 转换。
class QuillEditorWidget extends StatefulWidget {
  const QuillEditorWidget({
    super.key,
    required this.content,
    this.onChanged,
  });

  /// 初始 Markdown 内容。
  final String content;

  /// 内容变更回调（返回 Markdown 格式）。
  final ValueChanged<String>? onChanged;

  @override
  State<QuillEditorWidget> createState() => _QuillEditorWidgetState();
}

class _QuillEditorWidgetState extends State<QuillEditorWidget> {
  late QuillController _controller;
  late final FocusNode _focusNode;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _scrollController = ScrollController();
    _controller = _buildController(widget.content);
    _controller.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(covariant QuillEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      _controller.removeListener(_onChanged);
      _controller = _buildController(widget.content);
      _controller.addListener(_onChanged);
    }
  }

  QuillController _buildController(String markdown) {
    final document = markdownToDelta(markdown);
    return QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  void _onChanged() {
    widget.onChanged?.call(deltaToMarkdown(_controller.document));
  }

  // ──────────────────────────────────────────────
  //  Markdown ↔ Delta 转换
  // ──────────────────────────────────────────────

  /// 将 Markdown 文本转换为 Quill [Document]。
  ///
  /// 支持：标题（# ~ ###）、无序列表（- ）、有序列表（1. ）、引用（> ），
  /// 以及行内格式：加粗（**）、斜体（*）、行内代码（`）、链接（[]()）和图片（![]()）。
  static Document markdownToDelta(String markdown) {
    final lines = markdown.split('\n');
    final ops = <Map<String, dynamic>>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final blockAttrs = <String, dynamic>{};
      String text = line;

      // ── Block-level parsing ──
      if (text.startsWith('### ')) {
        blockAttrs['header'] = 3;
        text = text.substring(4);
      } else if (text.startsWith('## ')) {
        blockAttrs['header'] = 2;
        text = text.substring(3);
      } else if (text.startsWith('# ')) {
        blockAttrs['header'] = 1;
        text = text.substring(2);
      } else if (text.startsWith('> ')) {
        blockAttrs['blockquote'] = true;
        text = text.substring(2);
      } else if (text.startsWith('- ')) {
        blockAttrs['list'] = 'bullet';
        text = text.substring(2);
      } else {
        final orderedMatch = RegExp(r'^\d+\.\s').firstMatch(text);
        if (orderedMatch != null) {
          blockAttrs['list'] = 'ordered';
          text = text.substring(orderedMatch.end);
        }
      }

      // ── Inline formatting ──
      ops.addAll(_parseInline(text));

      // ── Newline (with or without block attributes) ──
      final newlineOp = <String, dynamic>{'insert': '\n'};
      if (blockAttrs.isNotEmpty) {
        newlineOp['attributes'] = blockAttrs;
      }
      ops.add(newlineOp);
    }

    if (ops.isEmpty) {
      ops.add({'insert': '\n'});
    }

    return Document.fromJson(ops);
  }

  /// 解析行内 Markdown 格式，返回 Delta 操作列表。
  ///
  /// 支持：图片 ![alt](url)、链接 [text](url)、
  /// 加粗 **text**、斜体 *text*、行内代码 `code`。
  static List<Map<String, dynamic>> _parseInline(String text) {
    final ops = <Map<String, dynamic>>[];

    final pattern = RegExp(
      r'!\[([^\]]*)\]\(([^)]+)\)'   // group 1,2: image
      r'|\[([^\]]+)\]\(([^)]+)\)'   // group 3,4: link
      r'|\*\*(.+?)\*\*'             // group 5: bold
      r'|\*(.+?)\*'                 // group 6: italic
      r'|`(.+?)`',                  // group 7: inline code
    );

    int lastEnd = 0;
    for (final match in pattern.allMatches(text)) {
      if (match.start > lastEnd) {
        ops.add({'insert': text.substring(lastEnd, match.start)});
      }

      if (match.group(1) != null) {
        ops.add({'insert': {'image': match.group(2)!}});
      } else if (match.group(3) != null) {
        ops.add({
          'insert': match.group(3),
          'attributes': {'link': match.group(4)},
        });
      } else if (match.group(5) != null) {
        ops.add({
          'insert': match.group(5),
          'attributes': {'bold': true},
        });
      } else if (match.group(6) != null) {
        ops.add({
          'insert': match.group(6),
          'attributes': {'italic': true},
        });
      } else if (match.group(7) != null) {
        ops.add({
          'insert': match.group(7),
          'attributes': {'code': true},
        });
      }

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      ops.add({'insert': text.substring(lastEnd)});
    }

    if (ops.isEmpty) {
      ops.add({'insert': text});
    }

    return ops;
  }

  /// 将 Quill [Document] 转换为 Markdown 字符串。
  ///
  /// 遍历 Delta 操作，将行内属性映射回 Markdown 语法，
  /// 将块级属性映射为行首标记。
  static String deltaToMarkdown(Document doc) {
    final buffer = StringBuffer();
    final delta = doc.toDelta();
    String lineText = '';

    for (final op in delta.operations) {
      if (!op.isInsert) continue;
      final data = op.value;
      final attrs = op.attributes;

      if (data is Map) {
        // 嵌入式资源（图片等）
        if (data.containsKey('image')) {
          buffer.write('![](${data['image']})');
        }
      } else if (data is String) {
        if (data == '\n') {
          buffer.write(_getBlockPrefix(attrs));
          buffer.write(lineText);
          buffer.write('\n');
          lineText = '';
        } else {
          lineText += _applyInlineMarkdown(data, attrs);
        }
      }
    }

    if (lineText.isNotEmpty) {
      buffer.write(lineText);
    }

    return buffer.toString();
  }

  /// 根据块级属性生成 Markdown 行首标记。
  static String _getBlockPrefix(Map<String, dynamic>? attrs) {
    if (attrs == null) return '';
    if (attrs['header'] == 1) return '# ';
    if (attrs['header'] == 2) return '## ';
    if (attrs['header'] == 3) return '### ';
    if (attrs['blockquote'] == true) return '> ';
    if (attrs['list'] == 'bullet') return '- ';
    if (attrs['list'] == 'ordered') return '1. ';
    return '';
  }

  /// 根据行内属性将文本包裹为 Markdown 语法。
  static String _applyInlineMarkdown(String text, Map<String, dynamic>? attrs) {
    if (attrs == null || attrs.isEmpty) return text;

    if (attrs.containsKey('link')) {
      return '[$text](${attrs['link']})';
    }
    if (attrs['code'] == true) {
      return '`$text`';
    }
    if (attrs['bold'] == true && attrs['italic'] == true) {
      return '***$text***';
    }
    if (attrs['bold'] == true) {
      return '**$text**';
    }
    if (attrs['italic'] == true) {
      return '*$text*';
    }
    return text;
  }

  // ──────────────────────────────────────────────
  //  Lifecycle
  // ──────────────────────────────────────────────

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QuillSimpleToolbar(
          controller: _controller,
        ),
        const Divider(height: 1),
        Expanded(
          child: QuillEditor(
            controller: _controller,
            focusNode: _focusNode,
            scrollController: _scrollController,
            config: const QuillEditorConfig(
              padding: EdgeInsets.all(16),
              autoFocus: false,
              expands: true,
            ),
          ),
        ),
      ],
    );
  }
}
