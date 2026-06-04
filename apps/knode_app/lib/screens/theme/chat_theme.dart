import 'package:flutter/material.dart';
import 'page_theme.dart';

class ChatTheme {
  ChatTheme._();

  static const light = PageTheme(
    primaryColor: Color(0xFF9C27B0),
    backgroundColor: Colors.white,
    surfaceColor: Color(0xFFF5F5F5),
    appBarColor: Colors.white,
    onPrimaryColor: Colors.white,
    onBackgroundColor: Colors.black87,
    icon: Icons.chat,
  );

  static const dark = PageTheme(
    primaryColor: Color(0xFFCE93D8),
    backgroundColor: Color(0xFF121212),
    surfaceColor: Color(0xFF1E1E1E),
    appBarColor: Color(0xFF1E1E1E),
    onPrimaryColor: Colors.white,
    onBackgroundColor: Colors.white70,
    icon: Icons.chat,
  );

  static PageTheme of({required bool isDark}) => isDark ? dark : light;
}
