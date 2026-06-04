import 'package:flutter/material.dart';
import 'package:core/theme/page_theme.dart';

class QuizTheme {
  QuizTheme._();

  static const light = PageTheme(
    primaryColor: Color(0xFFFF9800),
    backgroundColor: Colors.white,
    surfaceColor: Color(0xFFF5F5F5),
    appBarColor: Colors.white,
    onPrimaryColor: Colors.white,
    onBackgroundColor: Colors.black87,
    icon: Icons.quiz,
  );

  static const dark = PageTheme(
    primaryColor: Color(0xFFFFB74D),
    backgroundColor: Color(0xFF121212),
    surfaceColor: Color(0xFF1E1E1E),
    appBarColor: Color(0xFF1E1E1E),
    onPrimaryColor: Colors.white,
    onBackgroundColor: Colors.white70,
    icon: Icons.quiz,
  );

  static PageTheme of({required bool isDark}) => isDark ? dark : light;
}
