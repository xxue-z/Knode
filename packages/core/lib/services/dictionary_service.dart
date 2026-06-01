import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dictionary.dart';
import 'app_logger.dart';

/// 词典服务接口
abstract class DictionaryService {
  Future<DictionaryResult?> lookup(String word);
}

/// 简易词典服务实现
class SimpleDictionaryService implements DictionaryService {
  @override
  Future<DictionaryResult?> lookup(String word) async {
    try {
      // 尝试使用免费词典 API
      final result = await _tryFreeDictionaryApi(word);
      if (result != null) return result;

      // 如果 API 失败，返回一个模拟结果（用于演示）
      return _generateFallbackResult(word);
    } catch (e, stack) {
      AppLogger.instance.e(
        'Failed to look up word: $word',
        tag: 'DictionaryService',
        error: e,
        stackTrace: stack,
      );
      return _generateFallbackResult(word);
    }
  }

  /// 尝试使用 Free Dictionary API
  Future<DictionaryResult?> _tryFreeDictionaryApi(String word) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        if (data.isEmpty) return null;

        final entry = data[0] as Map<String, dynamic>;
        final definitions = <DictionaryDefinition>[];

        final phonetic = entry['phonetic'] as String?;
        final meanings = entry['meanings'] as List;

        for (final meaning in meanings) {
          final partOfSpeech = meaning['partOfSpeech'] as String?;
          final defs = meaning['definitions'] as List;

          for (final def in defs) {
            definitions.add(DictionaryDefinition(
              word: word,
              partOfSpeech: partOfSpeech,
              definition: def['definition'] as String,
              example: def['example'] as String?,
            ));
          }
        }

        return DictionaryResult(
          word: word,
          definitions: definitions,
          phonetic: phonetic,
        );
      }
    } catch (_) {
      // 忽略 API 错误，使用备选方案
    }
    return null;
  }

  /// 生成备选结果（演示用）
  DictionaryResult _generateFallbackResult(String word) {
    return DictionaryResult(
      word: word,
      definitions: [
        DictionaryDefinition(
          word: word,
          partOfSpeech: 'unknown',
          definition: '释义查询服务暂时不可用，请稍后再试',
        ),
      ],
    );
  }
}
