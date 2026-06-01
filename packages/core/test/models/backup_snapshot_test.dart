import 'package:test/test.dart';
import 'package:core/models/backup_snapshot.dart';

void main() {
  group('BackupSnapshot', () {
    group('parseTimestamp', () {
      test('parses valid timestamp format', () {
        final date = BackupSnapshot.parseTimestamp('knode_backup_20260531_143022.zip');
        expect(date, isNotNull);
        expect(date!.year, 2026);
        expect(date.month, 5);
        expect(date.day, 31);
        expect(date.hour, 14);
        expect(date.minute, 30);
        expect(date.second, 22);
      });

      test('parses midnight timestamp', () {
        final date = BackupSnapshot.parseTimestamp('knode_backup_20260501_000000.zip');
        expect(date, isNotNull);
        expect(date!.hour, 0);
        expect(date.minute, 0);
        expect(date.second, 0);
      });

      test('returns null for invalid filename', () {
        expect(BackupSnapshot.parseTimestamp('invalid.zip'), isNull);
      });

      test('returns null for non-matching pattern', () {
        expect(BackupSnapshot.parseTimestamp('other_backup_20260531_143022.zip'), isNull);
      });

      test('returns null for empty string', () {
        expect(BackupSnapshot.parseTimestamp(''), isNull);
      });

      test('returns null for partial match', () {
        expect(BackupSnapshot.parseTimestamp('knode_backup_20260531.zip'), isNull);
      });
    });

    group('sizeFormatted', () {
      test('formats bytes', () {
        final snapshot = BackupSnapshot(
          fileName: 'test.zip',
          sizeBytes: 512,
          createdAt: DateTime.now(),
        );
        expect(snapshot.sizeFormatted, '512 B');
      });

      test('formats kilobytes', () {
        final snapshot = BackupSnapshot(
          fileName: 'test.zip',
          sizeBytes: 2048,
          createdAt: DateTime.now(),
        );
        expect(snapshot.sizeFormatted, '2.0 KB');
      });

      test('formats megabytes', () {
        final snapshot = BackupSnapshot(
          fileName: 'test.zip',
          sizeBytes: 5 * 1024 * 1024,
          createdAt: DateTime.now(),
        );
        expect(snapshot.sizeFormatted, '5.0 MB');
      });

      test('formats large megabytes with one decimal', () {
        final snapshot = BackupSnapshot(
          fileName: 'test.zip',
          sizeBytes: (12 * 1024 * 1024) + (512 * 1024),
          createdAt: DateTime.now(),
        );
        expect(snapshot.sizeFormatted, '12.5 MB');
      });
    });
  });
}
