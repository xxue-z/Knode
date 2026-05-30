/// String 扩展方法。
extension StringExtensions on String {
  /// 截断字符串到指定长度，超出部分用 [suffix] 替代。
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }

  /// 移除 Markdown 格式符号，返回纯文本。
  String stripMarkdown() {
    return replaceAll(RegExp(r'#+\s'), '')
        .replaceAll(RegExp(r'\*+'), '')
        .replaceAll(RegExp(r'`+'), '')
        .replaceAll(RegExp(r'\[([^\]]*)\]\([^)]*\)'), r'$1')
        .replaceAll(RegExp(r'!\[([^\]]*)\]\([^)]*\)'), '')
        .replaceAll(RegExp(r'~~([^~]*)~~'), r'$1')
        .replaceAll(RegExp(r'\n{2,}'), '\n')
        .trim();
  }

  /// 提取前 N 个字符作为摘要。
  String toSummary({int maxLength = 200}) {
    final plain = stripMarkdown();
    return plain.truncate(maxLength);
  }

  /// 检查是否为有效的 URL。
  bool get isValidUrl {
    return startsWith('http://') || startsWith('https://');
  }

  /// 检查是否为有效的邮箱。
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  /// 首字母大写。
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// 将换行符统一为 \n。
  String get normalizeLineEndings {
    return replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  }

  /// 统计中英文混合字符串的字符数。
  ///
  /// 中文字符计为 2，英文字符计为 1。
  int get mixedLength {
    int count = 0;
    for (final char in runes) {
      if (char > 0x4E00 && char < 0x9FFF) {
        count += 2; // 中文字符
      } else {
        count += 1;
      }
    }
    return count;
  }
}
