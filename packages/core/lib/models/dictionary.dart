/// 词典释义
class DictionaryDefinition {
  /// 单词
  final String word;

  /// 词性（可选）
  final String? partOfSpeech;

  /// 释义文本
  final String definition;

  /// 例句（可选）
  final String? example;

  DictionaryDefinition({
    required this.word,
    this.partOfSpeech,
    required this.definition,
    this.example,
  });
}

/// 词典查询结果
class DictionaryResult {
  final String word;
  final List<DictionaryDefinition> definitions;
  final String? phonetic;

  DictionaryResult({
    required this.word,
    required this.definitions,
    this.phonetic,
  });
}
