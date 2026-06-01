import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:core/models/backup_snapshot.dart';
import 'package:core/utils/zip_utils.dart';
import 'package:core/gen/strings.dart';

final _strings = const L10nStringsMixin();

typedef BackupProgressCallback = void Function(double percent, String message);

class BackupService {
  String? _url;
  String? _user;
  String? _pass;

  void configure({required String url, required String user, required String pass}) {
    _url = url;
    _user = user;
    _pass = pass;
  }

  bool get isConfigured => _url != null && _user != null;

  Map<String, String> get _authHeaders => {
    'authorization': 'Basic ${base64Encode(utf8.encode('$_user:$_pass'))}',
  };

  Future<BackupSnapshot> backup({
    required String dbPath,
    required String wikiRoot,
    BackupProgressCallback? onProgress,
  }) async {
    if (!isConfigured) throw StateError(_strings.core_webdav_not_configured);

    onProgress?.call(0.0, _strings.knode_app_packing_files);

    final zipBytes = await ZipUtils.compressDirectory(
      directory: wikiRoot,
      prefix: 'wiki/',
      dbPath: dbPath,
    );

    onProgress?.call(0.5, _strings.knode_app_uploading);

    final timestamp = _formatTimestamp(DateTime.now());
    final fileName = 'knode_backup_$timestamp.zip';
    final uri = Uri.parse('$_url/knode_backups/$fileName');

    await _ensureDirectory('$_url/knode_backups/');

    final client = http.Client();
    try {
      final resp = await client.put(
        uri,
        body: zipBytes,
        headers: { ..._authHeaders, 'content-type': 'application/zip' },
      );
      if (resp.statusCode >= 400) {
        throw StateError('${_strings.knode_app_upload_failed}: HTTP ${resp.statusCode}');
      }
    } finally {
      client.close();
    }

    onProgress?.call(1.0, _strings.knode_app_backup_complete);

    return BackupSnapshot(
      fileName: fileName,
      sizeBytes: zipBytes.length,
      createdAt: DateTime.now(),
    );
  }

  Future<void> restore({
    required String dbPath,
    required String wikiRoot,
    BackupSnapshot? snapshot,
    BackupProgressCallback? onProgress,
  }) async {
    if (!isConfigured) throw StateError(_strings.core_webdav_not_configured);

    final targetSnapshot = snapshot ?? await _getLatestSnapshot();
    if (targetSnapshot == null) throw StateError(_strings.knode_app_no_backups_available);

    onProgress?.call(0.0, '${_strings.knode_app_downloading} ${targetSnapshot.fileName}...');

    final uri = Uri.parse('$_url/knode_backups/${targetSnapshot.fileName}');
    final client = http.Client();
    List<int> zipBytes;
    try {
      final resp = await client.get(uri, headers: _authHeaders);
      if (resp.statusCode != 200) {
        throw StateError('${_strings.knode_app_download_failed}: HTTP ${resp.statusCode}');
      }
      zipBytes = resp.bodyBytes;
    } finally {
      client.close();
    }

    onProgress?.call(0.4, _strings.knode_app_decompressing);

    final count = await ZipUtils.decompressToDirectory(
      zipBytes: zipBytes,
      targetDirectory: wikiRoot,
      pathMapping: { 'knode.db': dbPath },
    );

    onProgress?.call(1.0, '${_strings.knode_app_restore_complete} ($count)');
  }

  Future<List<BackupSnapshot>> listBackups() async {
    if (!isConfigured) throw StateError(_strings.core_webdav_not_configured);

    final uri = Uri.parse('$_url/knode_backups/');
    final client = http.Client();
    try {
      final resp = await client.send(http.Request('PROPFIND', uri)
        ..headers.addAll({
          ..._authHeaders,
          'depth': '1',
          'content-type': 'application/xml',
        })
        ..body = '''<?xml version="1.0" encoding="utf-8"?>
<D:propfind xmlns:D="DAV:">
  <D:allprop/>
</D:propfind>''');

      final body = await resp.stream.bytesToString();
      return _parseBackupList(body);
    } finally {
      client.close();
    }
  }

  List<BackupSnapshot> _parseBackupList(String xmlBody) {
    final snapshots = <BackupSnapshot>[];

    final hrefPattern = RegExp(r'<D:href>([^<]+)</D:href>', caseSensitive: false);
    final sizePattern = RegExp(
      r'<D:getcontentlength>(\d+)</D:getcontentlength>',
      caseSensitive: false,
    );

    final hrefs = hrefPattern.allMatches(xmlBody).toList();
    final sizes = sizePattern.allMatches(xmlBody).toList();

    for (int i = 0; i < hrefs.length; i++) {
      final href = hrefs[i].group(1) ?? '';
      if (!href.endsWith('.zip')) continue;

      final fileName = href.split('/').last;
      if (!fileName.startsWith('knode_backup_')) continue;

      final createdAt = BackupSnapshot.parseTimestamp(fileName);
      if (createdAt == null) continue;

      int sizeBytes = 0;
      if (i < sizes.length) {
        sizeBytes = int.tryParse(sizes[i].group(1)!) ?? 0;
      }

      snapshots.add(BackupSnapshot(
        fileName: fileName,
        sizeBytes: sizeBytes,
        createdAt: createdAt,
      ));
    }

    snapshots.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return snapshots;
  }

  Future<void> deleteBackup(BackupSnapshot snapshot) async {
    if (!isConfigured) throw StateError(_strings.core_webdav_not_configured);

    final uri = Uri.parse('$_url/knode_backups/${snapshot.fileName}');
    final client = http.Client();
    try {
      final resp = await client.delete(uri, headers: _authHeaders);
      if (resp.statusCode >= 400 && resp.statusCode != 404) {
        throw StateError('${_strings.knode_app_delete_failed}: HTTP ${resp.statusCode}');
      }
    } finally {
      client.close();
    }
  }

  Future<int> autoCleanup({int keepCount = 5}) async {
    if (!isConfigured) throw StateError(_strings.core_webdav_not_configured);

    final snapshots = await listBackups();
    if (snapshots.length <= keepCount) return 0;

    int deletedCount = 0;
    for (int i = keepCount; i < snapshots.length; i++) {
      try {
        await deleteBackup(snapshots[i]);
        deletedCount++;
      } catch (_) {}
    }
    return deletedCount;
  }

  Future<BackupSnapshot?> _getLatestSnapshot() async {
    final snapshots = await listBackups();
    return snapshots.isNotEmpty ? snapshots.first : null;
  }

  Future<void> _ensureDirectory(String dirUrl) async {
    final client = http.Client();
    try {
      await client.send(
        http.Request('MKCOL', Uri.parse(dirUrl))
          ..headers.addAll(_authHeaders),
      );
    } finally {
      client.close();
    }
  }

  String _formatTimestamp(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}'
        '${dt.month.toString().padLeft(2, '0')}'
        '${dt.day.toString().padLeft(2, '0')}_'
        '${dt.hour.toString().padLeft(2, '0')}'
        '${dt.minute.toString().padLeft(2, '0')}'
        '${dt.second.toString().padLeft(2, '0')}';
  }

  Future<bool> testConnection() async {
    if (!isConfigured) return false;
    try {
      final uri = Uri.parse(_url!);
      final resp = await http.get(uri).timeout(const Duration(seconds: 5));
      return resp.statusCode < 400;
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _url = null;
    _user = null;
    _pass = null;
  }
}
