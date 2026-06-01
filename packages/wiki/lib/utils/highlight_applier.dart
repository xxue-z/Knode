
import 'package:flutter/material.dart';
import 'package:core/models/highlight.dart';
import 'package:core/models/highlight_style.dart';

/// 将 Highlight 数据注入到富文本 span 树中。
class HighlightApplier {
  /// 根据高亮列表生成带样式的 TextSpan。
  static TextSpan buildSpans({
    required String text,
    required List&lt;Highlight&gt; highlights,
    required TextStyle baseStyle,
  }) {
    final children = &lt;TextSpan&gt;[];
    int currentOffset = 0;

    // 按起始位置排序
    final sorted = List&lt;Highlight&gt;.from(highlights)
      ..sort((a, b) =&gt; a.startPosition.compareTo(b.startPosition));

    for (final highlight in sorted) {
      // 高亮前的普通文本
      if (highlight.startPosition &gt; currentOffset) {
        children.add(TextSpan(
          text: text.substring(currentOffset, highlight.startPosition),
          style: baseStyle,
        ));
      }

      // 高亮文本
      final highlightText = text.substring(
        highlight.startPosition,
        highlight.endPosition,
      );
      children.add(TextSpan(
        text: highlightText,
        style: _applyStyle(baseStyle, highlight.style),
      ));

      currentOffset = highlight.endPosition;
    }

    // 剩余的普通文本
    if (currentOffset &lt; text.length) {
      children.add(TextSpan(
        text: text.substring(currentOffset),
        style: baseStyle,
      ));
    }

    return TextSpan(style: baseStyle, children: children);
  }

  static TextStyle _applyStyle(TextStyle base, HighlightStyle style) {
    TextStyle result = base;

    if (style.type == HighlightType.background) {
      result = result.copyWith(backgroundColor: _colorFromHex(style.colorHex));
    } else if (style.type == HighlightType.underline) {
      result = result.copyWith(
        decoration: TextDecoration.underline,
        decorationColor: _colorFromHex(style.colorHex),
        decorationThickness: 2,
      );
    }

    return result;
  }

  static Color _colorFromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
