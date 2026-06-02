import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:core/models/highlight.dart';
import 'package:core/models/highlight_style.dart';

/// Markdown 工具类，封装 flutter_markdown_plus 的调用。
///
/// 所有需要渲染 Markdown 的地方应通过此类创建 Widget，
/// 而不是直接使用 flutter_markdown_plus。
class MarkdownUtils {
  MarkdownUtils._();

  /// 渲染 Markdown 为无滚动的 Body Widget。
  ///
  /// [data] Markdown 源文本。
  /// [selectable] 文本是否可选中。
  /// [styleSheet] 自定义样式表。
  /// [extensionSet] Markdown 扩展集，默认启用 GitHub Flavored Markdown（含 HTML）。
  /// [onTapLink] 链接点击回调。
  /// [extraBuilders] 额外的自定义 Element Builder。
  static Widget body({
    required String data,
    bool selectable = true,
    MarkdownStyleSheet? styleSheet,
    md.ExtensionSet? extensionSet,
    MarkdownTapLinkCallback? onTapLink,
    Map<String, MarkdownElementBuilder>? extraBuilders,
  }) {
    return MarkdownBody(
      data: data,
      selectable: selectable,
      styleSheet: styleSheet,
      extensionSet: extensionSet ?? md.ExtensionSet.gitHubFlavored,
      onTapLink: onTapLink,
      builders: extraBuilders ?? const <String, MarkdownElementBuilder>{},
    );
  }

  /// 渲染带高亮的 Markdown。
  ///
  /// 利用 HTML `<mark>` 标签将高亮信息注入 Markdown，
  /// 然后通过 flutter_markdown_plus 的 HTML 渲染能力同时保留
  /// Markdown 格式和高亮效果。
  ///
  /// [data] Markdown 源文本。
  /// [highlights] 高亮列表。
  /// [highlightColors] 自定义高亮颜色，key 为 [HighlightType] name。
  /// [selectable] 文本是否可选中。
  /// [styleSheet] 自定义样式表。
  /// [onTapLink] 链接点击回调。
  static Widget bodyWithHighlights({
    required String data,
    required List<Highlight> highlights,
    Map<String, Color>? highlightColors,
    bool selectable = true,
    MarkdownStyleSheet? styleSheet,
    MarkdownTapLinkCallback? onTapLink,
  }) {
    if (highlights.isEmpty) {
      return body(
        data: data,
        selectable: selectable,
        styleSheet: styleSheet,
        onTapLink: onTapLink,
      );
    }

    final enrichedData = _injectHighlightTags(data, highlights, highlightColors);

    return MarkdownBody(
      data: enrichedData,
      selectable: selectable,
      styleSheet: styleSheet,
      extensionSet: md.ExtensionSet.gitHubFlavored,
      onTapLink: onTapLink,
      builders: {
        'mark': MarkElementBuilder(highlightColors: highlightColors),
      },
    );
  }

  /// 将 <mark> 标签注入 Markdown 文本。
  ///
  /// 从前往后遍历高亮区间，拼接普通文本和 <mark> 标签。
  static String _injectHighlightTags(
    String data,
    List<Highlight> highlights,
    Map<String, Color>? highlightColors,
  ) {
    final sorted = List<Highlight>.from(highlights)
      ..sort((a, b) => a.startPos.compareTo(b.startPos));

    final buffer = StringBuffer();
    int lastEnd = 0;

    for (final hl in sorted) {
      final start = hl.startPos.clamp(0, data.length);
      final end = hl.endPos.clamp(0, data.length);
      if (start >= end) continue;

      if (start > lastEnd) {
        buffer.write(data.substring(lastEnd, start));
      }

      final color = _getHighlightColor(hl.style, highlightColors);
      final colorHex = '#${color.toARGB32().toRadixString(16).padLeft(8, '0')}';
      final escaped = _escapeHtml(data.substring(start, end));

      buffer.write(
        '<mark style="background-color:$colorHex;color:inherit;'
        'padding:1px 2px;border-radius:2px;">$escaped</mark>',
      );
      lastEnd = end;
    }

    if (lastEnd < data.length) {
      buffer.write(data.substring(lastEnd));
    }

    return buffer.toString();
  }

  /// 获取高亮颜色。
  static Color _getHighlightColor(
    HighlightStyle style,
    Map<String, Color>? highlightColors,
  ) {
    if (highlightColors != null && highlightColors.containsKey(style.type.name)) {
      return highlightColors[style.type.name]!;
    }
    return style.color;
  }

  /// HTML 转义。
  static String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }
}

/// `<mark>` 标签的自定义 Element Builder。
///
/// 在 flutter_markdown_plus 渲染 HTML 时拦截 `<mark>` 元素，
/// 应用高亮背景色。
class MarkElementBuilder extends MarkdownElementBuilder {
  MarkElementBuilder({this.highlightColors});

  final Map<String, Color>? highlightColors;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final text = element.textContent;
    if (text.isEmpty) return null;

    Color bgColor = const Color(0x4DFFEB3B);
    final inlineStyle = element.attributes['style'];
    if (inlineStyle != null) {
      final colorMatch = RegExp(r'background-color:\s*(#[0-9a-fA-F]+)')
          .firstMatch(inlineStyle);
      if (colorMatch != null) {
        bgColor = Color(int.parse('FF${colorMatch.group(1)!.substring(1)}'));
      }
    }

    final effectiveStyle = parentStyle ?? preferredStyle ?? const TextStyle();

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      child: Text(text, style: effectiveStyle),
    );
  }
}
