import 'package:flutter_test/flutter_test.dart';
import 'package:wiki/widgets/node_label.dart';

void main() {
  group('truncateLabel', () {
    test('short title is not truncated', () {
      expect(truncateLabel('Flutter'), equals('Flutter'));
    });

    test('equal to max length is not truncated', () {
      expect(truncateLabel('12345678'), equals('12345678'));
    });

    test('exceeding max length truncates with ellipsis', () {
      // maxLength=8 → keep 7 chars + '…'
      expect(truncateLabel('Flutter教程详解'), equals('Flutter…'));
    });

    test('Chinese title within max length is not truncated', () {
      // '这是很长的标题'.length == 7 <= 8
      expect(truncateLabel('这是很长的标题'), equals('这是很长的标题'));
    });

    test('Chinese title exceeding max length is truncated', () {
      // '这是非常非常长的标题' has 10 chars > 8 → keep 7 + '…'
      expect(truncateLabel('这是非常非常长的标题'), equals('这是非常非常长…'));
    });

    test('custom max length', () {
      expect(truncateLabel('Hello World', maxLength: 5), equals('Hell…'));
    });

    test('maxLength of 1 returns single character', () {
      expect(truncateLabel('Hello', maxLength: 1), equals('H'));
    });

    test('empty string returns empty', () {
      expect(truncateLabel(''), equals(''));
    });
  });

  group('formatTags', () {
    test('formats short tags without truncation', () {
      expect(formatTags(['flutter', 'dart']), equals('flutter, dart'));
    });

    test('truncates individual long tags', () {
      // 'flutter教程' has 9 chars > 8 → 'flutter…'
      expect(formatTags(['flutter教程', 'dart语言']), equals('flutter…, dart语言'));
    });

    test('limits number of tags', () {
      expect(formatTags(['a', 'b', 'c', 'd'], maxTags: 2), equals('a, b'));
    });

    test('empty list returns empty string', () {
      expect(formatTags([]), equals(''));
    });

    test('custom max tag length', () {
      expect(formatTags(['HelloWorld'], maxTagLength: 5), equals('Hell…'));
    });
  });
}
