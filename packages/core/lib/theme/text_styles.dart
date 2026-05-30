import 'package:flutter/material.dart';

/// 知维（Knode）应用字体排版系统
///
/// 基于 Material 3 Typography，提供中英文字体搭配、
/// 行高及字间距规范，覆盖标题、正文、注释等不同层级。
class KnodeTextStyles {
  KnodeTextStyles._();  // ---------------------------------------------------------------------------
  // 字体族
  // ---------------------------------------------------------------------------

  /// 英文首选字体
  static const String _enFontFamily = 'Roboto';

  /// 中文首选字体（系统默认即可，这里显式声明便于后续替换）
  static const String _zhFontFamily = 'Noto Sans SC';

  /// 等宽字体（代码片段等场景）
  static const String _monoFontFamily = 'Roboto Mono';

  /// 通用字体族列表：英文在前、中文在后，系统会按顺序回退
  static const List<String> _fontFamilyFallback = [
    _enFontFamily,
    _zhFontFamily,
  ];

  // ---------------------------------------------------------------------------
  // 基础参数
  // ---------------------------------------------------------------------------

  /// 标准行高倍数（正文）
  static const double _bodyHeight = 1.5;

  /// 标题行高倍数
  static const double _headlineHeight = 1.3;

  /// 注释 / 标签行高倍数
  static const double _labelHeight = 1.3;

  /// 标准字间距（正文）
  static const double _bodyLetterSpacing = 0.15;

  /// 标题字间距
  static const double _headlineLetterSpacing = 0.0;

  /// 标签字间距
  static const double _labelLetterSpacing = 0.1;

  // ---------------------------------------------------------------------------
  // Display -- 超大展示文字
  // ---------------------------------------------------------------------------

  static const TextStyle displayLarge = TextStyle(
    fontFamily: _enFontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 57.0,
    fontWeight: FontWeight.w400,
    height: _headlineHeight,
    letterSpacing: -0.25,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: _enFontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 45.0,
    fontWeight: FontWeight.w400,
    height: _headlineHeight,
    letterSpacing: 0.0,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: _enFontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 36.0,
    fontWeight: FontWeight.w400,
    height: _headlineHeight,
    letterSpacing: 0.0,
  );

  // ---------------------------------------------------------------------------
  // Headline -- 标题
  // ---------------------------------------------------------------------------

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _enFontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 32.0,
    fontWeight: FontWeight.w600,
    height: _headlineHeight,
    letterSpacing: _headlineLetterSpacing,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _enFontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 28.0,
    fontWeight: FontWeight.w600,
    height: _headlineHeight,
    letterSpacing: _headlineLetterSpacing,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _enFontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    height: _headlineHeight,
    letterSpacing: _headlineLetterSpacing,
  );

  // ---------------------------------------------------------------------------
  // Title -- 小标题 / 卡片标题
  // ---------------------------------------------------------------------------

  static const TextStyle titleLarge = TextStyle(
    fontFamily: _enFontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 22.0,
    fontWeight: FontWeight.w500,
    height: _headlineHeight,
    letterSpacing: 0.0,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: _enFontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    height: _headlineHeight,
    letterSpacing: 0.15,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: _enFontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    height: _headlineHeight,
    letterSpacing: 0.1,
  );

  // ---------------------------------------------------------------------------
  // Body -- 正文
  // ---------------------------------------------------------------------------

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _enFontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    height: _bodyHeight,
    letterSpacing: _bodyLetterSpacing,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _enFontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: _bodyHeight,
    letterSpacing: _bodyLetterSpacing,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _enFontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: _bodyHeight,
    letterSpacing: _bodyLetterSpacing,
  );

  // ---------------------------------------------------------------------------
  // Label -- 标签 / 按钮 / 提示
  // ---------------------------------------------------------------------------

  static const TextStyle labelLarge = TextStyle(
    fontFamily: _enFontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    height: _labelHeight,
    letterSpacing: _labelLetterSpacing,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: _enFontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    height: _labelHeight,
    letterSpacing: _labelLetterSpacing,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _enFontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 11.0,
    fontWeight: FontWeight.w500,
    height: _labelHeight,
    letterSpacing: _labelLetterSpacing,
  );

  // ---------------------------------------------------------------------------
  // 业务扩展 -- 聊天消息
  // ---------------------------------------------------------------------------

  /// 用户/AI 聊天气泡正文
  static const TextStyle chatMessage = TextStyle(
    fontFamily: _enFontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 15.0,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0.1,
  );

  /// 聊天时间戳
  static const TextStyle chatTimestamp = TextStyle(
    fontFamily: _enFontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 11.0,
    fontWeight: FontWeight.w400,
    height: _labelHeight,
    letterSpacing: 0.1,
  );

  // ---------------------------------------------------------------------------
  // 业务扩展 -- 代码块
  // ---------------------------------------------------------------------------

  /// 内联代码
  static const TextStyle inlineCode = TextStyle(
    fontFamily: _monoFontFamily,
    fontFamilyFallback: [_monoFontFamily, _zhFontFamily],
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.0,
  );

  /// 代码块
  static const TextStyle codeBlock = TextStyle(
    fontFamily: _monoFontFamily,
    fontFamilyFallback: [_monoFontFamily, _zhFontFamily],
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0.0,
  );

  // ---------------------------------------------------------------------------
  // 辅助方法
  // ---------------------------------------------------------------------------

  /// 根据 [TextTheme] 的插槽名称返回对应样式，
  /// 便于在无法直接访问本类常量时做动态查找。
  ///
  /// 返回 `null` 表示未匹配到有效名称。
  static TextStyle? resolve(String slotName) {
    switch (slotName) {
      case 'displayLarge':
        return displayLarge;
      case 'displayMedium':
        return displayMedium;
      case 'displaySmall':
        return displaySmall;
      case 'headlineLarge':
        return headlineLarge;
      case 'headlineMedium':
        return headlineMedium;
      case 'headlineSmall':
        return headlineSmall;
      case 'titleLarge':
        return titleLarge;
      case 'titleMedium':
        return titleMedium;
      case 'titleSmall':
        return titleSmall;
      case 'bodyLarge':
        return bodyLarge;
      case 'bodyMedium':
        return bodyMedium;
      case 'bodySmall':
        return bodySmall;
      case 'labelLarge':
        return labelLarge;
      case 'labelMedium':
        return labelMedium;
      case 'labelSmall':
        return labelSmall;
      default:
        return null;
    }
  }

  /// 构建一个完整的 [TextTheme] 实例，方便直接注入 [ThemeData]。
  static const TextTheme textTheme = TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}
