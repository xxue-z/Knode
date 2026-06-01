import 'ai_provider.dart';
import 'cloud_ai_provider.dart';
import 'package:core/database/dao/settings_dao.dart';

/// AIProvider 工厂，根据配置创建云端或本地 Provider。
class AIProviderFactory {
  /// 从 settings 表读取配置，创建对应的 AIProvider 实例。
  static Future<AIProvider> create(SettingsDao settingsDao) async {
    final type = await settingsDao.get('ai_provider_type') ?? 'cloud';

    switch (type) {
      case 'cloud':
        return _createCloudProvider(settingsDao);
      case 'local':
        // LocalAIProvider 由 main.dart 中单独初始化（需要加载模型文件）
        return _createCloudProvider(settingsDao); // 回退到云端
      default:
        return _createCloudProvider(settingsDao);
    }
  }

  static Future<CloudAIProvider> _createCloudProvider(SettingsDao settingsDao) async {
    final baseUrl = await settingsDao.get('ai_base_url') ?? 'https://api.openai.com';
    final apiKey = await settingsDao.get('ai_api_key') ?? '';
    final model = await settingsDao.get('ai_model') ?? 'gpt-4o-mini';
    final specStr = await settingsDao.get('ai_api_spec') ?? 'openai';

    final apiSpec = specStr == 'anthropic' ? ApiSpec.anthropic : ApiSpec.openai;

    return CloudAIProvider(
      baseUrl: baseUrl,
      apiKey: apiKey,
      model: model,
      apiSpec: apiSpec,
    );
  }
}
