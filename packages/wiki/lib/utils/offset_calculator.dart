import 'package:flutter/material.dart';

/// 字符偏移量与渲染位置之间的映射计算器。
///
/// 使用 TextPainter 预计算每行文本的起始/结束偏移和位置。
class OffsetCalculator {
  final String text;
  final TextStyle style;
  final double maxWidth;

  late TextPainter _painter;
  late List<_LineInfo> _lines;
  bool _initialized = false;

  OffsetCalculator({
    required this.text,
    required this.style,
    required this.maxWidth,
  }) {
    _init();
  }

  void _init() {
    _painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    _lines = [];
    int offset = 0;

    // 使用简单的行分割方式
    final lines = text.split('\n');
    for (int i = 0; i < lines.length; i++) {
      final lineLength = lines[i].length;
      _lines.add(_LineInfo(
        startOffset: offset,
        endOffset: offset + lineLength,
        y: i * 20.0, // 简化的行高计算
        height: 20.0,
      ));
      offset += lineLength + 1; // +1 for newline
    }

    _initialized = true;
  }

  /// 将字符偏移转换为（y 坐标，高度）。
  OffsetResult? offsetToPosition(int offset) {
    if (!_initialized) return null;
    for (final line in _lines) {
      if (offset >= line.startOffset && offset < line.endOffset) {
        return OffsetResult(y: line.y, height: line.height);
      }
    }
    return null;
  }

  void dispose() {
    _painter.dispose();
  }
}

class _LineInfo {
  final int startOffset;
  final int endOffset;
  final double y;
  final double height;

  _LineInfo({
    required this.startOffset,
    required this.endOffset,
    required this.y,
    required this.height,
  });
}

class OffsetResult {
  final double y;
  final double height;

  OffsetResult({required this.y, required this.height});
}
