import 'package:flutter/services.dart';
import '../data/dao/settings_dao.dart';

/// 提示词模板管理器。从 assets/prompts/ 加载，支持变量替换和用户自定义覆盖。
class PromptManager {
  static const _assetBase = 'assets/prompts/';
  static const Map<String, String> _templateFiles = {
    'qa_with_rag': 'qa_with_rag.txt',
    'quiz_generator': 'quiz_generator.txt',
    'intent_analyzer': 'intent_analyzer.txt',
    'summarizer': 'summarizer.txt',
    'grader': 'grader.txt',
  };

  final SettingsDao _settingsDao;
  final Map<String, String> _cache = {};
  PromptManager(this._settingsDao);

  Future<String> loadTemplate(String agentName) async {
    if (_cache.containsKey(agentName)) return _cache[agentName]!;
    final customKey = 'prompt_$agentName';
    final custom = await _settingsDao.get(customKey);
    if (custom != null && custom.isNotEmpty) {
      _cache[agentName] = custom;
      return custom;
    }
    final fileName = _templateFiles[agentName];
    if (fileName == null) throw ArgumentError('Unknown agent: $agentName');
    final raw = await rootBundle.loadString('$_assetBase$fileName');
    _cache[agentName] = raw;
    return raw;
  }

  String render(String template, Map<String, String> variables) {
    var result = template;
    for (final entry in variables.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value);
    }
    return result;
  }

  Future<void> saveCustomTemplate(String agentName, String template) async {
    await _settingsDao.set('prompt_$agentName', template);
    _cache.remove(agentName);
  }

  void clearCache() => _cache.clear();
}
