import 'package:flutter/material.dart';

/// 页面主题配置
class PageTheme {
  final Color primaryColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color appBarColor;
  final Color onPrimaryColor;
  final Color onBackgroundColor;
  final String? backgroundImage;
  final IconData icon;

  const PageTheme({
    required this.primaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.appBarColor,
    required this.onPrimaryColor,
    required this.onBackgroundColor,
    this.backgroundImage,
    required this.icon,
  });

  /// 根据主题模式获取对应的主题配置
  static PageTheme of(BuildContext context, {required bool isDark}) {
    return isDark ? _defaultDark : _defaultLight;
  }

  static const _defaultLight = PageTheme(
    primaryColor: Colors.blue,
    backgroundColor: Colors.white,
    surfaceColor: Color(0xFFF5F5F5),
    appBarColor: Colors.white,
    onPrimaryColor: Colors.white,
    onBackgroundColor: Colors.black87,
    icon: Icons.home,
  );

  static const _defaultDark = PageTheme(
    primaryColor: Colors.lightBlue,
    backgroundColor: Color(0xFF121212),
    surfaceColor: Color(0xFF1E1E1E),
    appBarColor: Color(0xFF1E1E1E),
    onPrimaryColor: Colors.white,
    onBackgroundColor: Colors.white70,
    icon: Icons.home,
  );
}
