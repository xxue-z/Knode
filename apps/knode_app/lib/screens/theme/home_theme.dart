import 'package:flutter/material.dart';
import 'page_theme.dart';

class HomeTheme {
  HomeTheme._();

  static const light = PageTheme(
    primaryColor: Color(0xFF4CAF50),
    backgroundColor: Colors.white,
    surfaceColor: Color(0xFFF5F5F5),
    appBarColor: Colors.white,
    onPrimaryColor: Colors.white,
    onBackgroundColor: Colors.black87,
    icon: Icons.home,
  );

  static const dark = PageTheme(
    primaryColor: Color(0xFF81C784),
    backgroundColor: Color(0xFF121212),
    surfaceColor: Color(0xFF1E1E1E),
    appBarColor: Color(0xFF1E1E1E),
    onPrimaryColor: Colors.white,
    onBackgroundColor: Colors.white70,
    icon: Icons.home,
  );

  static PageTheme of({required bool isDark}) => isDark ? dark : light;
}
