import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:core/models/highlight.dart';
import 'package:wiki/utils/highlight_applier.dart';

/// 带高亮支持的 Markdown 阅读器组件。
class MarkdownReader extends StatelessWidget {
  final String markdown;
  final List<Highlight> highlights;
  final TextStyle textStyle;
  final MarkdownStyleSheet? styleSheet;
  final ScrollController? controller;

  const MarkdownReader({
    super.key,
    required this.markdown,
    required this.highlights,
    required this.textStyle,
    this.styleSheet,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // 如果没有高亮，直接使用 MarkdownBody
    if (highlights.isEmpty) {
      return MarkdownBody(
        data: markdown,
        styleSheet: styleSheet,
      );
    }

    // 有高亮时，使用 RichText + 高亮
    // 注意：这是一个简化实现，将 Markdown 作为纯文本处理
    // 完整的 Markdown 高亮需要自定义 builders
    final span = HighlightApplier.buildSpans(
      text: markdown,
      highlights: highlights,
      baseStyle: textStyle,
    );

    return RichText(
      text: span,
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
    );
  }
}
