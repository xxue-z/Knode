
/// 从 Markdown 文本中提取标题列表。
///
/// 每个标题包含：
/// - 级别（1-6）
/// - 文本内容
/// - 起始字符偏移
class HeadingItem {
  final int level;
  final String text;
  final int offset;

  HeadingItem({
    required this.level,
    required this.text,
    required this.offset,
  });
}

class HeadingExtractor {
  /// 提取 Markdown 中的所有标题。
  static List&lt;HeadingItem&gt; extract(String markdown) {
    final List&lt;HeadingItem&gt; headings = [];
    final lines = markdown.split('\n');
    int currentOffset = 0;

    for (final line in lines) {
      // 匹配 # 开头的标题
      final match = RegExp(r'^(#{1,6})\s+(.*)$').firstMatch(line);
      if (match != null) {
        final level = match.group(1)!.length;
        final text = match.group(2)!.trim();
        headings.add(HeadingItem(
          level: level,
          text: text,
          offset: currentOffset,
        ));
      }
      // 加上换行符的长度
      currentOffset += line.length + 1;
    }

    return headings;
  }
}
