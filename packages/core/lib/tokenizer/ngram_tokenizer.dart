import 'tokenizer.dart';
import 'stop_words.dart';

class NgramTokenizer implements Tokenizer {
  @override
  List<String> tokenize(String text) {
    if (text.trim().isEmpty) return [];
    final cleaned = text.replaceAll(RegExp(r'[^\u4e00-\u9fff\w]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.isEmpty) return [];
    final seen = <String>{};
    final result = <String>[];
    final sentences = cleaned.split(' ');
    for (final sentence in sentences) {
      final chars = sentence.split('');
      if (chars.length >= 2) {
        for (int i = 0; i <= chars.length - 2; i++) {
          final bigram = chars.sublist(i, i + 2).join();
          if (!seen.contains(bigram) && !StopWords.isStopWord(bigram) && !_isPurePunctOrDigit(bigram)) {
            seen.add(bigram);
            result.add(bigram);
          }
        }
      }
      if (chars.length >= 3) {
        for (int i = 0; i <= chars.length - 3; i++) {
          final trigram = chars.sublist(i, i + 3).join();
          if (!seen.contains(trigram) && !StopWords.isStopWord(trigram) && !_isPurePunctOrDigit(trigram)) {
            seen.add(trigram);
            result.add(trigram);
          }
        }
      }
    }
    return result;
  }

  @override
  String tokenizeToString(String text) => tokenize(text).join(' ');

  static bool _isPurePunctOrDigit(String s) => RegExp(r'^[\d\p{P}\p{S}]+$', unicode: true).hasMatch(s);
}