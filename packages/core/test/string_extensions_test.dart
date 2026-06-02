import 'package:flutter_test/flutter_test.dart';
import 'package:core/extensions/string_extensions.dart';

void main() {
  group('String Extensions Tests', () {
    group('truncate', () {
      test('should return original string if shorter than max length', () {
        expect('hello'.truncate(10), equals('hello'));
      });

      test('should truncate string if longer than max length', () {
        expect('hello world'.truncate(8), equals('hello...'));
      });

      test('should use custom suffix', () {
        expect('hello world'.truncate(8, suffix: '…'), equals('hello w…'));
      });

      test('should handle exact length', () {
        expect('hello'.truncate(5), equals('hello'));
      });
    });

    group('stripMarkdown', () {
      test('should remove heading markers', () {
        expect('# Title'.stripMarkdown(), equals('Title'));
        expect('## Subtitle'.stripMarkdown(), equals('Subtitle'));
      });

      test('should remove bold and italic markers', () {
        expect('**bold**'.stripMarkdown(), equals('bold'));
        expect('*italic*'.stripMarkdown(), equals('italic'));
      });

      test('should remove code markers', () {
        expect('`code`'.stripMarkdown(), equals('code'));
      });

      test('should extract link text', () {
        expect('[link](http://example.com)'.stripMarkdown(), equals('link'));
      });

      test('should remove images', () {
        expect('![alt](http://example.com/img.png)'.stripMarkdown(), equals(''));
      });

      test('should remove strikethrough markers', () {
        expect('~~strikethrough~~'.stripMarkdown(), equals('strikethrough'));
      });

      test('should normalize multiple newlines', () {
        expect('line1\n\n\nline2'.stripMarkdown(), equals('line1\nline2'));
      });
    });

    group('toSummary', () {
      test('should extract summary with default max length', () {
        final text = 'This is a long text that should be truncated to the default max length of 200 characters. ' * 2;
        final summary = text.toSummary();
        expect(summary.length, lessThanOrEqualTo(200));
      });

      test('should extract summary with custom max length', () {
        expect('hello world'.toSummary(maxLength: 5), equals('he...'));
      });
    });

    group('isValidUrl', () {
      test('should return true for valid http URL', () {
        expect('http://example.com'.isValidUrl, isTrue);
      });

      test('should return true for valid https URL', () {
        expect('https://example.com'.isValidUrl, isTrue);
      });

      test('should return false for invalid URL', () {
        expect('example.com'.isValidUrl, isFalse);
        expect('ftp://example.com'.isValidUrl, isFalse);
      });
    });

    group('isValidEmail', () {
      test('should return true for valid email', () {
        expect('test@example.com'.isValidEmail, isTrue);
        expect('user.name@domain.co.uk'.isValidEmail, isTrue);
      });

      test('should return false for invalid email', () {
        expect('invalid'.isValidEmail, isFalse);
        expect('test@'.isValidEmail, isFalse);
        expect('@example.com'.isValidEmail, isFalse);
      });
    });

    group('capitalize', () {
      test('should capitalize first letter', () {
        expect('hello'.capitalize, equals('Hello'));
        expect('world'.capitalize, equals('World'));
      });

      test('should handle empty string', () {
        expect(''.capitalize, equals(''));
      });

      test('should not change already capitalized string', () {
        expect('Hello'.capitalize, equals('Hello'));
      });
    });

    group('normalizeLineEndings', () {
      test('should convert CRLF to LF', () {
        expect('line1\r\nline2'.normalizeLineEndings, equals('line1\nline2'));
      });

      test('should convert CR to LF', () {
        expect('line1\rline2'.normalizeLineEndings, equals('line1\nline2'));
      });

      test('should handle mixed line endings', () {
        expect('line1\r\nline2\rline3'.normalizeLineEndings, equals('line1\nline2\nline3'));
      });
    });

    group('mixedLength', () {
      test('should count English characters as 1', () {
        expect('hello'.mixedLength, equals(5));
      });

      test('should count Chinese characters as 2', () {
        expect('你好'.mixedLength, equals(4));
      });

      test('should handle mixed content', () {
        expect('hello你好'.mixedLength, equals(9));
      });

      test('should handle empty string', () {
        expect(''.mixedLength, equals(0));
      });
    });
  });
}
