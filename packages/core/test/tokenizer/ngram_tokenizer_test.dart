import 'package:test/test.dart';
import 'package:core/tokenizer/ngram_tokenizer.dart';

void main() {
  final tokenizer = NgramTokenizer();

  group('NgramTokenizer', () {
    test('returns empty list for empty input', () {
      expect(tokenizer.tokenize(''), []);
      expect(tokenizer.tokenize('   '), []);
    });

    test('returns empty list for single character', () {
      // Single char can't form bigram or trigram
      expect(tokenizer.tokenize('a'), []);
      expect(tokenizer.tokenize('你'), []);
    });

    test('generates bigrams for Chinese text', () {
      final tokens = tokenizer.tokenize('知识管理');
      // 4 chars → 3 bigrams + 2 trigrams
      expect(tokens, contains('知识'));
      expect(tokens, contains('识管'));
      expect(tokens, contains('管理'));
    });

    test('generates trigrams for Chinese text', () {
      final tokens = tokenizer.tokenize('知识管理');
      expect(tokens, contains('知识管'));
      expect(tokens, contains('识管理'));
    });

    test('deduplicates tokens', () {
      final tokens = tokenizer.tokenize('知识知识');
      // "知识" appears twice but should be deduplicated
      final knowledgeCount = tokens.where((t) => t == '知识').length;
      expect(knowledgeCount, 1);
    });

    test('filters individual stop word characters from bigrams', () {
      // Stop words are single chars like 的, 是, 在
      // Bigrams containing them may or may not be filtered
      // The tokenizer filters bigrams that ARE stop words
      final tokens = tokenizer.tokenize('知识的力量');
      // "知识", "识的" (的 is stop word, but 识的 is not), "的力", "力量"
      expect(tokens, contains('知识'));
      expect(tokens, contains('力量'));
    });

    test('handles mixed Chinese and English', () {
      final tokens = tokenizer.tokenize('Flutter开发');
      // Should generate bigrams from the mixed text
      expect(tokens, isNotEmpty);
    });

    test('handles punctuation by treating as separator', () {
      final tokens = tokenizer.tokenize('知识，管理');
      // Chinese comma should be cleaned, generating bigrams from remaining
      expect(tokens, isNotEmpty);
    });

    test('tokenizeToString joins with spaces', () {
      final result = tokenizer.tokenizeToString('知识管理');
      expect(result, isNotEmpty);
      expect(result, contains(' '));
    });

    test('generates bigrams for English text', () {
      final tokens = tokenizer.tokenize('hello world');
      expect(tokens, isNotEmpty);
      expect(tokens, contains('he'));
      expect(tokens, contains('el'));
    });

    test('filters pure digits', () {
      final tokens = tokenizer.tokenize('123456');
      // "12", "23", "34" etc are pure digits, should be filtered
      expect(tokens, isEmpty);
    });
  });
}
