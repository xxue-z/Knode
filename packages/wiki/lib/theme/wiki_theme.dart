import 'package:flutter/material.dart';
import 'package:core/theme/page_theme.dart';

class WikiTheme {
  WikiTheme._();

  static const light = PageTheme(
    primaryColor: Color(0xFF2196F3),
    backgroundColor: Colors.white,
    surfaceColor: Color(0xFFF5F5F5),
    appBarColor: Colors.white,
    onPrimaryColor: Colors.white,
    onBackgroundColor: Colors.black87,
    icon: Icons.menu_book,
  );

  static const dark = PageTheme(
    primaryColor: Color(0xFF64B5F6),
    backgroundColor: Color(0xFF121212),
    surfaceColor: Color(0xFF1E1E1E),
    appBarColor: Color(0xFF1E1E1E),
    onPrimaryColor: Colors.white,
    onBackgroundColor: Colors.white70,
    icon: Icons.menu_book,
  );

  static PageTheme of({required bool isDark}) => isDark ? dark : light;
}
