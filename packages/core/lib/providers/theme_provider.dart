import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _keyThemeMode = 'theme_mode';

/// 主题状态Notifier
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  /// 设置主题模式
  void setThemeMode(ThemeMode mode) {
    state = mode;
    final modeString = mode == ThemeMode.system
        ? 'system'
        : mode == ThemeMode.light
            ? 'light'
            : 'dark';
    _saveThemeMode(modeString);
  }

  /// 从持久化存储恢复主题模式
  Future<void> restoreThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString(_keyThemeMode) ?? 'system';
    state = modeString == 'light'
        ? ThemeMode.light
        : modeString == 'dark'
            ? ThemeMode.dark
            : ThemeMode.system;
  }

  static Future<void> _saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode);
  }
}

/// 主题状态Provider
final themeNotifierProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);
