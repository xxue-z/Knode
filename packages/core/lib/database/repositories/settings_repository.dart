import '../dao/settings_dao.dart';

/// 设置仓库层。
///
/// 封装 SettingsDao，提供业务级别的设置操作。
class SettingsRepository {
  final SettingsDao _dao;

  SettingsRepository(this._dao);

  /// 获取指定键的值，不存在返回默认值。
  Future<String> get(String key, {String defaultValue = ''}) async {
    final value = await _dao.get(key);
    return value ?? defaultValue;
  }

  /// 设置键值对。
  Future<void> set(String key, String value) async {
    await _dao.set(key, value);
  }

  /// 删除指定键。
  Future<void> delete(String key) async {
    await _dao.delete(key);
  }

  /// 获取所有设置。
  Future<Map<String, String>> getAll() async {
    return _dao.getAll();
  }

  /// 获取 AI 提供商类型（cloud / local）。
  Future<String> getAiType() async {
    return get('ai_type', defaultValue: 'cloud');
  }

  /// 设置 AI 提供商类型。
  Future<void> setAiType(String type) async {
    await set('ai_type', type);
  }

  /// 获取云端 API Key。
  Future<String?> getApiKey() async {
    return _dao.get('api_key');
  }

  /// 设置云端 API Key。
  Future<void> setApiKey(String key) async {
    await set('api_key', key);
  }

  /// 获取云端 Base URL。
  Future<String?> getBaseUrl() async {
    return _dao.get('base_url');
  }

  /// 设置云端 Base URL。
  Future<void> setBaseUrl(String url) async {
    await set('base_url', url);
  }

  /// 获取当前加载的本地模型 ID。
  Future<String?> getLocalModelId() async {
    return _dao.get('local_model_id');
  }

  /// 设置当前加载的本地模型 ID。
  Future<void> setLocalModelId(String modelId) async {
    await set('local_model_id', modelId);
  }

  /// 获取模型仓库 URL。
  Future<String> getModelRepoUrl() async {
    return get('model_repo_url');
  }

  /// 设置模型仓库 URL。
  Future<void> setModelRepoUrl(String url) async {
    await set('model_repo_url', url);
  }
}
