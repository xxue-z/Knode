import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ai_provider.dart';
import 'cloud_ai_provider.dart';
import '../data/dao/settings_dao.dart';

class AIProviderFactory {
  static Future<AIProvider> create(SettingsDao settingsDao) async {
    final type = await settingsDao.get('ai_provider_type') ?? 'cloud';
    final baseUrl = await settingsDao.get('ai_base_url') ?? 'https://api.openai.com';
    final apiKey = await settingsDao.get('ai_api_key') ?? '';
    final model = await settingsDao.get('ai_model') ?? 'gpt-4o-mini';

    switch (type) {
      case 'cloud':
        return CloudAIProvider(baseUrl: baseUrl, apiKey: apiKey, model: model);
      default:
        return CloudAIProvider(baseUrl: baseUrl, apiKey: apiKey, model: model);
    }
  }
}