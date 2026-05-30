import 'package:test/test.dart';
import 'package:core/utils/date_utils.dart';

void main() {
  group('DateUtils', () {
    final dt = DateTime(2026, 5, 30, 14, 30, 45);

    test('formatFull returns yyyy-MM-dd HH:mm:ss', () {
      expect(DateUtils.formatFull(dt), '2026-05-30 14:30:45');
    });

    test('formatDate returns yyyy-MM-dd', () {
      expect(DateUtils.formatDate(dt), '2026-05-30');
    });

    test('formatTime returns HH:mm:ss', () {
      expect(DateUtils.formatTime(dt), '14:30:45');
    });

    test('formatMonth returns yyyy-MM', () {
      expect(DateUtils.formatMonth(dt), '2026-05');
    });

    test('formatFriendly returns MM月dd日 HH:mm', () {
      expect(DateUtils.formatFriendly(dt), '05月30日 14:30');
    });

    group('formatDuration', () {
      test('formats seconds under 60', () {
        expect(DateUtils.formatDuration(0), '0秒');
        expect(DateUtils.formatDuration(30), '30秒');
        expect(DateUtils.formatDuration(59), '59秒');
      });

      test('formats minutes and seconds', () {
        expect(DateUtils.formatDuration(60), '1分0秒');
        expect(DateUtils.formatDuration(90), '1分30秒');
        expect(DateUtils.formatDuration(3599), '59分59秒');
      });

      test('formats hours and minutes', () {
        expect(DateUtils.formatDuration(3600), '1小时0分');
        expect(DateUtils.formatDuration(3660), '1小时1分');
        expect(DateUtils.formatDuration(7200), '2小时0分');
      });
    });
  });
}
