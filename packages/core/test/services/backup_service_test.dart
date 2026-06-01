import 'package:test/test.dart';
import 'package:core/services/backup_service.dart';

void main() {
  group('BackupService', () {
    late BackupService service;

    setUp(() {
      service = BackupService();
    });

    group('parseBackupList', () {
      test('parses standard PROPFIND response with multiple files', () {
        final xml = '''<?xml version="1.0" encoding="utf-8"?>
<D:multistatus xmlns:D="DAV:">
  <D:response>
    <D:href>/dav/knode_backups/</D:href>
    <D:propstat>
      <D:prop>
        <D:resourcetype><D:collection/></D:resourcetype>
      </D:prop>
      <D:status>HTTP/1.1 200 OK</D:status>
    </D:propstat>
  </D:response>
  <D:response>
    <D:href>/dav/knode_backups/knode_backup_20260531_143022.zip</D:href>
    <D:propstat>
      <D:prop>
        <D:getcontentlength>1048576</D:getcontentlength>
      </D:prop>
      <D:status>HTTP/1.1 200 OK</D:status>
    </D:propstat>
  </D:response>
  <D:response>
    <D:href>/dav/knode_backups/knode_backup_20260530_090000.zip</D:href>
    <D:propstat>
      <D:prop>
        <D:getcontentlength>2097152</D:getcontentlength>
      </D:prop>
      <D:status>HTTP/1.1 200 OK</D:status>
    </D:propstat>
  </D:response>
</D:multistatus>''';

        final snapshots = service.parseBackupList(xml);

        expect(snapshots.length, 2);
        // 按时间倒序
        expect(snapshots[0].fileName, 'knode_backup_20260531_143022.zip');
        expect(snapshots[0].sizeBytes, 1048576);
        expect(snapshots[0].createdAt.year, 2026);
        expect(snapshots[0].createdAt.month, 5);
        expect(snapshots[0].createdAt.day, 31);
        expect(snapshots[1].fileName, 'knode_backup_20260530_090000.zip');
        expect(snapshots[1].sizeBytes, 2097152);
      });

      test('handles directory entry without getcontentlength', () {
        final xml = '''<?xml version="1.0" encoding="utf-8"?>
<D:multistatus xmlns:D="DAV:">
  <D:response>
    <D:href>/dav/knode_backups/</D:href>
    <D:propstat>
      <D:prop>
        <D:resourcetype><D:collection/></D:resourcetype>
      </D:prop>
      <D:status>HTTP/1.1 200 OK</D:status>
    </D:propstat>
  </D:response>
  <D:response>
    <D:href>/dav/knode_backups/knode_backup_20260531_143022.zip</D:href>
    <D:propstat>
      <D:prop>
        <D:getcontentlength>512000</D:getcontentlength>
      </D:prop>
      <D:status>HTTP/1.1 200 OK</D:status>
    </D:propstat>
  </D:response>
</D:multistatus>''';

        final snapshots = service.parseBackupList(xml);

        expect(snapshots.length, 1);
        expect(snapshots[0].fileName, 'knode_backup_20260531_143022.zip');
        expect(snapshots[0].sizeBytes, 512000);
      });

      test('ignores non-zip files and non-matching names', () {
        final xml = '''<?xml version="1.0" encoding="utf-8"?>
<D:multistatus xmlns:D="DAV:">
  <D:response>
    <D:href>/dav/knode_backups/other_file.txt</D:href>
    <D:propstat>
      <D:prop><D:getcontentlength>100</D:getcontentlength></D:prop>
      <D:status>HTTP/1.1 200 OK</D:status>
    </D:propstat>
  </D:response>
  <D:response>
    <D:href>/dav/knode_backups/other_backup_20260531_143022.zip</D:href>
    <D:propstat>
      <D:prop><D:getcontentlength>200</D:getcontentlength></D:prop>
      <D:status>HTTP/1.1 200 OK</D:status>
    </D:propstat>
  </D:response>
  <D:response>
    <D:href>/dav/knode_backups/knode_backup_20260531_143022.zip</D:href>
    <D:propstat>
      <D:prop><D:getcontentlength>300</D:getcontentlength></D:prop>
      <D:status>HTTP/1.1 200 OK</D:status>
    </D:propstat>
  </D:response>
</D:multistatus>''';

        final snapshots = service.parseBackupList(xml);

        expect(snapshots.length, 1);
        expect(snapshots[0].fileName, 'knode_backup_20260531_143022.zip');
        expect(snapshots[0].sizeBytes, 300);
      });

      test('handles missing getcontentlength gracefully', () {
        final xml = '''<?xml version="1.0" encoding="utf-8"?>
<D:multistatus xmlns:D="DAV:">
  <D:response>
    <D:href>/dav/knode_backups/knode_backup_20260531_143022.zip</D:href>
    <D:propstat>
      <D:prop></D:prop>
      <D:status>HTTP/1.1 200 OK</D:status>
    </D:propstat>
  </D:response>
</D:multistatus>''';

        final snapshots = service.parseBackupList(xml);

        expect(snapshots.length, 1);
        expect(snapshots[0].sizeBytes, 0);
      });

      test('returns empty list for empty response', () {
        final xml = '''<?xml version="1.0" encoding="utf-8"?>
<D:multistatus xmlns:D="DAV:">
</D:multistatus>''';

        final snapshots = service.parseBackupList(xml);
        expect(snapshots.isEmpty, true);
      });

      test('returns empty list for empty string', () {
        final snapshots = service.parseBackupList('');
        expect(snapshots.isEmpty, true);
      });

      test('ignores files with invalid timestamp', () {
        final xml = '''<?xml version="1.0" encoding="utf-8"?>
<D:multistatus xmlns:D="DAV:">
  <D:response>
    <D:href>/dav/knode_backups/knode_backup_invalid.zip</D:href>
    <D:propstat>
      <D:prop><D:getcontentlength>100</D:getcontentlength></D:prop>
      <D:status>HTTP/1.1 200 OK</D:status>
    </D:propstat>
  </D:response>
  <D:response>
    <D:href>/dav/knode_backups/knode_backup_20260531_143022.zip</D:href>
    <D:propstat>
      <D:prop><D:getcontentlength>200</D:getcontentlength></D:prop>
      <D:status>HTTP/1.1 200 OK</D:status>
    </D:propstat>
  </D:response>
</D:multistatus>''';

        final snapshots = service.parseBackupList(xml);

        expect(snapshots.length, 1);
        expect(snapshots[0].fileName, 'knode_backup_20260531_143022.zip');
      });

      test('sorts by date descending', () {
        final xml = '''<?xml version="1.0" encoding="utf-8"?>
<D:multistatus xmlns:D="DAV:">
  <D:response>
    <D:href>/dav/knode_backups/knode_backup_20260529_090000.zip</D:href>
    <D:propstat>
      <D:prop><D:getcontentlength>100</D:getcontentlength></D:prop>
      <D:status>HTTP/1.1 200 OK</D:status>
    </D:propstat>
  </D:response>
  <D:response>
    <D:href>/dav/knode_backups/knode_backup_20260531_143022.zip</D:href>
    <D:propstat>
      <D:prop><D:getcontentlength>200</D:getcontentlength></D:prop>
      <D:status>HTTP/1.1 200 OK</D:status>
    </D:propstat>
  </D:response>
  <D:response>
    <D:href>/dav/knode_backups/knode_backup_20260530_090000.zip</D:href>
    <D:propstat>
      <D:prop><D:getcontentlength>300</D:getcontentlength></D:prop>
      <D:status>HTTP/1.1 200 OK</D:status>
    </D:propstat>
  </D:response>
</D:multistatus>''';

        final snapshots = service.parseBackupList(xml);

        expect(snapshots.length, 3);
        expect(snapshots[0].fileName, 'knode_backup_20260531_143022.zip');
        expect(snapshots[1].fileName, 'knode_backup_20260530_090000.zip');
        expect(snapshots[2].fileName, 'knode_backup_20260529_090000.zip');
      });
    });

    group('isConfigured', () {
      test('returns false when not configured', () {
        expect(service.isConfigured, false);
      });

      test('returns true after configure', () {
        service.configure(url: 'https://example.com/dav', user: 'test', pass: 'pass');
        expect(service.isConfigured, true);
      });

      test('returns false after dispose', () {
        service.configure(url: 'https://example.com/dav', user: 'test', pass: 'pass');
        service.dispose();
        expect(service.isConfigured, false);
      });
    });
  });
}
