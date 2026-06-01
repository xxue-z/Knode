
import 'package:flutter/material.dart';

/// 阅读器主题
enum ReaderTheme {
  light,
  sepia,
  dark,
}

/// 阅读器设置
class ReaderSettings {
  /// 字体大小
  final double fontSize;
  
  /// 行间距
  final double lineSpacing;
  
  /// 页边距
  final double pageMargin;
  
  /// 主题
  final ReaderTheme theme;
  
  /// 自动滚动速度 (0 表示关闭
  final double autoScrollSpeed;

  ReaderSettings({
    this.fontSize = 16.0,
    this.lineSpacing = 1.6,
    this.pageMargin = 24.0,
    this.theme = ReaderTheme.light,
    this.autoScrollSpeed = 0.0,
  });

  ReaderSettings copyWith({
    double? fontSize,
    double? lineSpacing,
    double? pageMargin,
    ReaderTheme? theme,
    double? autoScrollSpeed,
  }) {
    return ReaderSettings(
      fontSize: fontSize ?? this.fontSize,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      pageMargin: pageMargin ?? this.pageMargin,
      theme: theme ?? this.theme,
      autoScrollSpeed: autoScrollSpeed ?? this.autoScrollSpeed,
    );
  }

  /// 获取背景色
  Color get backgroundColor {
    switch (theme) {
      case ReaderTheme.light:
        return Colors.white;
      case ReaderTheme.sepia:
        return const Color(0xFFF4ECD8);
      case ReaderTheme.dark:
        return const Color(0xFF1E1E1E);
    }
  }

  /// 获取文本颜色
  Color get textColor {
    switch (theme) {
      case ReaderTheme.light:
        return Colors.black87;
      case ReaderTheme.sepia:
        return Colors.black87;
      case ReaderTheme.dark:
        return Colors.white70;
    }
  }
}
