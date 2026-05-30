import 'dart:convert';
import 'package:dio/dio.dart';
import '../ai/prompt_manager.dart';
import 'package:core/database/dao/settings_dao.dart';

class PromptRemoteSyncService {
  final PromptManager _promptManager;
  final SettingsDao _settingsDao;
  final Dio _dio = Dio();

  PromptRemoteSyncService(this._promptManager, this._settingsDao);

  Future<int> syncFromRemote({required String remoteUrl}) async {
    try {
      final resp = await _dio.get(remoteUrl);
      final data = resp.data;
      if (data is! Map<String, dynamic>) throw StateError('远程模板格式错误');
      int updated = 0;
      for (final entry in data.entries) {
        final agentName = entry.key;
        final templateData = entry.value as Map<String, dynamic>;
        final remoteVersion = templateData['version'] as int? ?? 0;
        final remoteContent = templateData['content'] as String? ?? '';
        if (remoteContent.isEmpty) continue;
        final localVersionStr = await _settingsDao.get('prompt_version_$agentName');
        final localVersion = int.tryParse(localVersionStr ?? '') ?? 0;
        if (remoteVersion > localVersion) {
          final customKey = 'prompt_$agentName';
          final existing = await _settingsDao.get(customKey);
          if (existing == null || existing.isEmpty) {
            await _settingsDao.set(customKey, remoteContent);
          }
          await _settingsDao.set('prompt_version_$agentName', remoteVersion.toString());
          _promptManager.clearCache();
          updated++;
        }
      }
      return updated;
    } catch (e) {
      throw StateError('远程同步失败: $e');
    }
  }

  void dispose() => _dio.close(force: true);
}