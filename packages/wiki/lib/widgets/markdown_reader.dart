
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:core/models/highlight.dart';
import 'package:wiki/utils/highlight_applier.dart';

/// 带高亮支持的 Markdown 阅读器组件。
class MarkdownReader extends StatelessWidget {
  final String markdown;
  final List&lt;Highlight&gt; highlights;
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
    // 简单实现：使用 MarkdownBody 配合自定义 builders
    // 为了简化，先用普通文本用 RichText + 高亮
    // 先实现纯文本高亮版本
    // 完整的 Markdown 高亮需要自定义 builders
    return MarkdownBody(
      data: markdown,
      styleSheet: styleSheet,
      // 自定义文本元素 builder 来支持高亮
      builders: {
        'p': _HighlightParagraphBuilder(highlights, textStyle),
      },
    );
  }
}

/// 自定义 Paragraph Builder，用于给段落文本添加高亮。
class _HighlightParagraphBuilder extends MarkdownElementBuilder {
  final List&lt;Highlight&gt; highlights;
  final TextStyle baseStyle;

  _HighlightParagraphBuilder(this.highlights, this.baseStyle);

  @override
  Widget? buildText(MarkdownElement element, TextStyle? preferredStyle) {
    // 对于纯文本段落，使用 HighlightApplier 生成带高亮的 TextSpan
    final text = element.textContent;
    final span = HighlightApplier.buildSpans(
      text: text,
      highlights: highlights,
      baseStyle: preferredStyle ?? baseStyle,
    );
    return RichText(text: span);
  }
}
