import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/database/dao/settings_dao.dart';

Locale _initialLocale = const Locale('zh');

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => _initialLocale;

  void update(Locale locale) {
    if (state == locale) return;
    state = locale;
  }

  Future<void> setLocale(Locale locale) async {
    if (state == locale) return;
    state = locale;
    await SettingsDao().set('language', locale.languageCode);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

Future<Locale> loadSavedLocale() async {
  try {
    final code = await SettingsDao().get('language');
    if (code != null && code.isNotEmpty) {
      _initialLocale = Locale(code);
    }
  } catch (_) {}
  return _initialLocale;
}
