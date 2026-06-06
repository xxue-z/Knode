import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/extensions/riverpod_compat.dart';
import 'package:core/database/dao/settings_dao.dart';

final settingsDaoProvider = Provider<SettingsDao>((ref) => throw UnimplementedError('请在 main.dart 中覆盖'));

class SettingsNotifier extends AsyncNotifier<Map<String, String>> {
  @override
  Future<Map<String, String>> build() async {
    final dao = ref.read(settingsDaoProvider);
    return dao.getAll();
  }

  Future<void> set(String key, String value) async {
    final dao = ref.read(settingsDaoProvider);
    await dao.set(key, value);
    final current = state.valueOrNull ?? {};
    state = AsyncData({...current, key: value});
  }

  String get(String key, {String defaultValue = ''}) {
    return state.valueOrNull?[key] ?? defaultValue;
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, Map<String, String>>(
  SettingsNotifier.new,
);
