import 'package:flutter/material.dart';
import 'package:core/models/highlight.dart';
import 'package:core/models/highlight_style.dart';

/// 将 Highlight 数据注入到富文本 span 树中。
class HighlightApplier {
  /// 根据高亮列表生成带样式的 TextSpan。
  static TextSpan buildSpans({
    required String text,
    required List<Highlight> highlights,
    required TextStyle baseStyle,
  }) {
    final children = <TextSpan>[];
    int currentOffset = 0;

    // 按起始位置排序
    final sorted = List<Highlight>.from(highlights)
      ..sort((a, b) => a.startPos.compareTo(b.startPos));

    for (final highlight in sorted) {
      // 边界保护
      final hlStart = highlight.startPos.clamp(0, text.length);
      final hlEnd = highlight.endPos.clamp(0, text.length);
      if (hlStart >= hlEnd) continue;

      // 高亮前的普通文本
      if (hlStart > currentOffset) {
        children.add(TextSpan(
          text: text.substring(currentOffset, hlStart),
          style: baseStyle,
        ));
      }

      // 高亮文本
      children.add(TextSpan(
        text: text.substring(hlStart, hlEnd),
        style: _applyStyle(baseStyle, highlight.style),
      ));

      currentOffset = hlEnd;
    }

    // 剩余的普通文本
    if (currentOffset < text.length) {
      children.add(TextSpan(
        text: text.substring(currentOffset),
        style: baseStyle,
      ));
    }

    if (children.isEmpty) {
      return TextSpan(text: text, style: baseStyle);
    }

    return TextSpan(style: baseStyle, children: children);
  }

  static TextStyle _applyStyle(TextStyle base, HighlightStyle style) {
    if (style.type == HighlightType.background) {
      return base.copyWith(
        backgroundColor: style.color.withOpacity(style.opacity),
      );
    } else {
      return base.copyWith(
        decoration: TextDecoration.underline,
        decorationColor: style.color,
        decorationThickness: 2,
      );
    }
  }
}
