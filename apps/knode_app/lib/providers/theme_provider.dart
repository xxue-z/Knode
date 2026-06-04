import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:knode_app/utils/preferences_util.dart';

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
    PreferencesUtil.saveThemeMode(modeString);
  }

  /// 从持久化存储恢复主题模式
  Future<void> restoreThemeMode() async {
    final modeString = await PreferencesUtil.loadThemeMode();
    state = modeString == 'light'
        ? ThemeMode.light
        : modeString == 'dark'
            ? ThemeMode.dark
            : ThemeMode.system;
  }
}

/// 主题状态Provider
final themeNotifierProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);
