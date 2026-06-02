import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:core/utils/markdown_utils.dart';
import 'package:core/models/highlight.dart';

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
    return MarkdownUtils.bodyWithHighlights(
      data: markdown,
      highlights: highlights,
      styleSheet: styleSheet,
    );
  }
}
