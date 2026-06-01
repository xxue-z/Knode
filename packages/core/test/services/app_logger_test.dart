import 'package:test/test.dart';
import 'package:core/services/app_logger.dart';

void main() {
  group('LogEntry', () {
    group('parse', () {
      test('parses valid verbose log line', () {
        final line = '2026-05-31 14:30:22.123 VERBOSE [Main] 应用启动';
        final entry = LogEntry.parse(line);
        expect(entry, isNotNull);
        expect(entry!.level, AppLogLevel.verbose);
        expect(entry.tag, 'Main');
        expect(entry.message, '应用启动');
      });

      test('parses valid debug log line', () {
        final line = '2026-05-31 14:30:22.456 DEBUG  [Database] 查询执行';
        final entry = LogEntry.parse(line);
        expect(entry, isNotNull);
        expect(entry!.level, AppLogLevel.debug);
      });

      test('parses valid info log line', () {
        final line = '2026-05-31 14:30:25.789 INFO   [Download] 开始下载';
        final entry = LogEntry.parse(line);
        expect(entry, isNotNull);
        expect(entry!.level, AppLogLevel.info);
      });

      test('parses valid warning log line', () {
        final line = '2026-05-31 14:30:30.012 WARNING [Download] SHA256 校验失败';
        final entry = LogEntry.parse(line);
        expect(entry, isNotNull);
        expect(entry!.level, AppLogLevel.warning);
      });

      test('parses valid error log line', () {
        final line = '2026-05-31 14:30:30.015 ERROR  [Download] 下载失败';
        final entry = LogEntry.parse(line);
        expect(entry, isNotNull);
        expect(entry!.level, AppLogLevel.error);
      });

      test('parses valid fatal log line', () {
        final line = '2026-05-31 14:30:35.123 FATAL  [Main] 数据库初始化失败';
        final entry = LogEntry.parse(line);
        expect(entry, isNotNull);
        expect(entry!.level, AppLogLevel.fatal);
      });

      test('parses line without tag', () {
        final line = '2026-05-31 14:30:22.123 INFO   应用启动';
        final entry = LogEntry.parse(line);
        expect(entry, isNotNull);
        expect(entry!.tag, isNull);
        expect(entry.message, '应用启动');
      });

      test('returns null for invalid format', () {
        expect(LogEntry.parse('invalid line'), isNull);
        expect(LogEntry.parse(''), isNull);
        expect(LogEntry.parse('2026-05-31 14:30:22 INFO test'), isNull);
      });
    });

    group('toFormattedString', () {
      test('formats basic entry', () {
        final entry = LogEntry(
          timestamp: DateTime(2026, 5, 31, 14, 30, 22, 123),
          level: AppLogLevel.info,
          message: 'test message',
          tag: 'Test',
        );
        final formatted = entry.toFormattedString();
        expect(formatted, startsWith('2026-05-31 14:30:22.123'));
        expect(formatted, contains('INFO   [Test] test message'));
      });

      test('formats entry with error', () {
        final entry = LogEntry(
          timestamp: DateTime(2026, 5, 31, 14, 30, 22),
          level: AppLogLevel.error,
          message: 'error occurred',
          error: StateError('test error'),
        );
        final formatted = entry.toFormattedString();
        expect(formatted, contains('ERROR'));
        expect(formatted, contains('error occurred'));
        expect(formatted, contains('ERROR: StateError: test error'));
      });
    });
  });

  group('AppLogLevel', () {
    test('has correct order', () {
      expect(AppLogLevel.verbose.index, 0);
      expect(AppLogLevel.debug.index, 1);
      expect(AppLogLevel.info.index, 2);
      expect(AppLogLevel.warning.index, 3);
      expect(AppLogLevel.error.index, 4);
      expect(AppLogLevel.fatal.index, 5);
    });
  });
}
