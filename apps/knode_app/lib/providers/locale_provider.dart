import 'package:flutter/material.dart';
import 'package:core/database/dao/settings_dao.dart';

/// 管理应用语言切换，读写 settings 表中的 language 配置。
class LocaleProvider extends ChangeNotifier {
  final _dao = SettingsDao();

  Locale _locale = const Locale('zh');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final code = await _dao.get('language');
    if (code != null && code.isNotEmpty) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    await _dao.set('language', locale.languageCode);
    notifyListeners();
  }
}
