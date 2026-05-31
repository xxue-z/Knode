import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:core/database/dao/settings_dao.dart';

/// Prompt template info returned by [getAllTemplates].
class PromptTemplateInfo {
  final String agentName;
  final String displayName;
  final bool hasCustom;
  final String contentPreview;

  const PromptTemplateInfo({
    required this.agentName,
    required this.displayName,
    required this.hasCustom,
    required this.contentPreview,
  });

  Map<String, dynamic> toJson() => {
        'agentName': agentName,
        'displayName': displayName,
        'hasCustom': hasCustom,
        'contentPreview': contentPreview,
      };
}

/// Prompt template manager. Loads from assets/prompts/, supports variable
/// substitution and user-defined overrides persisted via SettingsDao.
class PromptManager {
  static const _assetBase = 'assets/prompts/';
  static const Map<String, String> _templateFiles = {
    'qa_with_rag': 'qa_with_rag.txt',
    'quiz_generator': 'quiz_generator.txt',
    'intent_analyzer': 'intent_analyzer.txt',
    'summarizer': 'summarizer.txt',
    'grader': 'grader.txt',
    'tag_generator': 'tag_generator.txt',
    'question_variant': 'question_variant.txt',
    'periodic_exam_generator': 'periodic_exam_generator.txt',
    'search_agent': 'search_agent.txt',
  };

  static const Map<String, String> _displayNames = {
    'qa_with_rag': 'RAG QA',
    'quiz_generator': 'Quiz Generator',
    'intent_analyzer': 'Intent Analyzer',
    'summarizer': 'Summarizer',
    'grader': 'Grader',
    'tag_generator': 'Tag Generator',
    'question_variant': 'Question Variant',
    'periodic_exam_generator': 'Periodic Exam',
    'search_agent': 'Search Agent',
  };

  final SettingsDao _settingsDao;
  final Map<String, String> _cache = {};
  final Map<String, String> _originalCache = {};

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

  Future<void> resetOverride(String agentName) async {
    final customKey = 'prompt_$agentName';
    await _settingsDao.delete(customKey);
    _cache.remove(agentName);
  }

  Future<void> resetAllOverrides() async {
    for (final agentName in _templateFiles.keys) {
      final customKey = 'prompt_$agentName';
      await _settingsDao.delete(customKey);
    }
    _cache.clear();
  }

  Future<List<PromptTemplateInfo>> getAllTemplates() async {
    final list = <PromptTemplateInfo>[];
    for (final entry in _templateFiles.entries) {
      final agentName = entry.key;
      final customKey = 'prompt_$agentName';
      final custom = await _settingsDao.get(customKey);
      final hasCustom = custom != null && custom.isNotEmpty;
      final content =
          hasCustom ? custom : await _getOriginalTemplate(agentName);
      final preview =
          content.length > 80 ? '${content.substring(0, 80)}...' : content;
      list.add(PromptTemplateInfo(
        agentName: agentName,
        displayName: _displayNames[agentName] ?? agentName,
        hasCustom: hasCustom,
        contentPreview: preview,
      ));
    }
    return list;
  }

  Future<String> getOriginalTemplate(String agentName) async {
    return _getOriginalTemplate(agentName);
  }

  Future<String?> getCustomTemplate(String agentName) async {
    final customKey = 'prompt_$agentName';
    return _settingsDao.get(customKey);
  }

  Future<bool> hasOverride(String agentName) async {
    final custom = await getCustomTemplate(agentName);
    return custom != null && custom.isNotEmpty;
  }

  /// Export all templates. Only custom overrides are exported with their
  /// content; default templates are recorded with `is_custom: false` so
  /// that [importFromJson] can skip them on round-trip.
  Future<String> exportAll() async {
    final templates = <String, dynamic>{};
    for (final agentName in _templateFiles.keys) {
      final customKey = 'prompt_$agentName';
      final custom = await _settingsDao.get(customKey);
      final hasCustom = custom != null && custom.isNotEmpty;
      templates[agentName] = {
        'is_custom': hasCustom,
        'content': hasCustom ? custom : await _getOriginalTemplate(agentName),
      };
    }
    return const JsonEncoder.withIndent('  ').convert({
      'version': 1,
      'templates': templates,
    });
  }

  /// Import templates from JSON. Only entries with `is_custom: true` are
  /// saved as overrides; default entries are skipped to preserve the
  /// round-trip invariant.
  Future<int> importFromJson(String jsonString) async {
    final dynamic decoded;
    try {
      decoded = jsonDecode(jsonString);
    } catch (_) {
      throw const FormatException('Invalid JSON format');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Root must be a JSON object');
    }
    // Validate version
    final version = decoded['version'];
    if (version is! int || version < 1) {
      throw const FormatException('Unsupported or missing version field');
    }
    final templates = decoded['templates'];
    if (templates is! Map<String, dynamic>) {
      throw const FormatException('Missing or invalid "templates" field');
    }
    var count = 0;
    for (final entry in templates.entries) {
      final agentName = entry.key;
      final value = entry.value;
      if (!_templateFiles.containsKey(agentName)) continue;

      // New format: { is_custom: bool, content: String }
      if (value is Map<String, dynamic>) {
        final isCustom = value['is_custom'] == true;
        if (!isCustom) continue; // skip non-custom entries
        final content = value['content'];
        if (content is! String) continue;
        await saveCustomTemplate(agentName, content);
        count++;
      } else if (value is String) {
        // Legacy format: plain string (import all for backward compat)
        await saveCustomTemplate(agentName, value);
        count++;
      }
    }
    return count;
  }

  static List<String> extractVariables(String template) {
    final regex = RegExp(r'\{([a-zA-Z_][a-zA-Z0-9_]*)\}');
    final matches = regex.allMatches(template);
    final names = <String>{};
    for (final m in matches) {
      names.add(m.group(1)!);
    }
    return names.toList()..sort();
  }

  List<String> get knownAgents => _templateFiles.keys.toList();

  String displayNameOf(String agentName) =>
      _displayNames[agentName] ?? agentName;

  Future<String> _getOriginalTemplate(String agentName) async {
    if (_originalCache.containsKey(agentName)) {
      return _originalCache[agentName]!;
    }
    final fileName = _templateFiles[agentName];
    if (fileName == null) throw ArgumentError('Unknown agent: $agentName');
    final raw = await rootBundle.loadString('$_assetBase$fileName');
    _originalCache[agentName] = raw;
    return raw;
  }

  void clearCache() {
    _cache.clear();
    _originalCache.clear();
  }
}
