import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:knode_app/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ThemeNotifier', () {
    test('initial state is system theme mode', () {
      final container = ProviderContainer();
      final themeMode = container.read(themeNotifierProvider);

      expect(themeMode, ThemeMode.system);
    });

    test('setThemeMode updates theme mode', () async {
      final container = ProviderContainer();
      final notifier = container.read(themeNotifierProvider.notifier);

      notifier.setThemeMode(ThemeMode.dark);
      final themeMode = container.read(themeNotifierProvider);

      expect(themeMode, ThemeMode.dark);
    });

    test('setThemeMode can set to light', () async {
      final container = ProviderContainer();
      final notifier = container.read(themeNotifierProvider.notifier);

      notifier.setThemeMode(ThemeMode.light);
      final themeMode = container.read(themeNotifierProvider);

      expect(themeMode, ThemeMode.light);
    });
  });
}
