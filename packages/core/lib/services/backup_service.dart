import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:core/models/backup_snapshot.dart';
import 'package:core/utils/zip_utils.dart';
import 'package:core/services/app_logger.dart';

import '../gen/strings.dart';

const _strings = L10nStringsMixin();

/// 进度回调。
typedef BackupProgressCallback = void Function(double percent, String message);

class BackupService {
  static const _backupDir = 'knode_backups';
  static const _dbFileName = 'knode.db';
  static const _wikiPrefix = 'wiki/';

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

  // ============================================================
  // 备份
  // ============================================================

  /// 创建 Zip 压缩备份并上传到 WebDAV。
  Future<BackupSnapshot> backup({
    required String dbPath,
    required String wikiRoot,
    BackupProgressCallback? onProgress,
  }) async {
    if (!isConfigured) throw StateError('WebDAV 未配置');

    AppLogger.instance.i('开始备份: dbPath=$dbPath, wikiRoot=$wikiRoot', tag: 'Backup');
    onProgress?.call(0.0, _strings.core_progress_packing);

    final zipBytes = await ZipUtils.compressDirectory(
      directory: wikiRoot,
      prefix: _wikiPrefix,
      dbPath: dbPath,
    );

    onProgress?.call(0.5, _strings.core_progress_uploading);

    final timestamp = _formatTimestamp(DateTime.now());
    final fileName = 'knode_backup_$timestamp.zip';
    final uri = Uri.parse('$_url/$_backupDir/$fileName');

    await _ensureDirectory('$_url/$_backupDir/');

    final client = http.Client();
    try {
      final resp = await client.put(
        uri,
        body: zipBytes,
        headers: { ..._authHeaders, 'content-type': 'application/zip' },
      );
      if (resp.statusCode >= 400) {
        throw StateError('上传失败: HTTP ${resp.statusCode}');
      }
    } finally {
      client.close();
    }

    onProgress?.call(1.0, _strings.core_progress_backup_complete);
    AppLogger.instance.i('备份上传完成: $fileName, 大小=${zipBytes.length}B', tag: 'Backup');

    return BackupSnapshot(
      fileName: fileName,
      sizeBytes: zipBytes.length,
      createdAt: DateTime.now(),
    );
  }

  // ============================================================
  // 恢复
  // ============================================================

  /// 从 WebDAV 下载指定快照并解压恢复。
  Future<void> restore({
    required String dbPath,
    required String wikiRoot,
    BackupSnapshot? snapshot,
    BackupProgressCallback? onProgress,
  }) async {
    if (!isConfigured) throw StateError('WebDAV 未配置');

    final targetSnapshot = snapshot ?? await _getLatestSnapshot();
    if (targetSnapshot == null) throw StateError('没有可用的备份');

    AppLogger.instance.i('开始恢复: ${targetSnapshot.fileName}', tag: 'Backup');
    onProgress?.call(0.0, '正在下载 ${targetSnapshot.fileName}...');

    final uri = Uri.parse('$_url/$_backupDir/${targetSnapshot.fileName}');
    final client = http.Client();
    List<int> zipBytes;
    try {
      final resp = await client.get(uri, headers: _authHeaders);
      if (resp.statusCode != 200) {
        throw StateError('下载失败: HTTP ${resp.statusCode}');
      }
      zipBytes = resp.bodyBytes;
    } finally {
      client.close();
    }

    onProgress?.call(0.4, _strings.core_progress_decompressing);

    final count = await ZipUtils.decompressToDirectory(
      zipBytes: zipBytes,
      targetDirectory: wikiRoot,
      pathMapping: { _dbFileName: dbPath },
    );

    onProgress?.call(1.0, '恢复完成 ($count 个文件)');
    AppLogger.instance.i('恢复完成: $count 个文件', tag: 'Backup');
  }

  // ============================================================
  // 备份列表
  // ============================================================

  /// 获取 WebDAV 上所有备份快照列表，按时间倒序排列。
  Future<List<BackupSnapshot>> listBackups() async {
    if (!isConfigured) throw StateError('WebDAV 未配置');

    final uri = Uri.parse('$_url/$_backupDir/');
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

      if (resp.statusCode >= 400) {
        throw StateError('获取备份列表失败: HTTP ${resp.statusCode}');
      }

      final body = await resp.stream.bytesToString();
      final snapshots = parseBackupList(body);
      AppLogger.instance.d('获取备份列表: ${snapshots.length} 个快照', tag: 'Backup');
      return snapshots;
    } finally {
      client.close();
    }
  }

  /// 按 <D:response> 块解析 PROPFIND 响应，提取 .zip 备份文件信息。
  @visibleForTesting
  List<BackupSnapshot> parseBackupList(String xmlBody) {
    final snapshots = <BackupSnapshot>[];

    final responsePattern = RegExp(r'<D:response>(.*?)</D:response>', dotAll: true, caseSensitive: false);
    final hrefPattern = RegExp(r'<D:href>([^<]+)</D:href>', caseSensitive: false);
    final sizePattern = RegExp(r'<D:getcontentlength>(\d+)</D:getcontentlength>', caseSensitive: false);

    for (final responseMatch in responsePattern.allMatches(xmlBody)) {
      final block = responseMatch.group(1)!;

      final hrefMatch = hrefPattern.firstMatch(block);
      if (hrefMatch == null) continue;
      final href = hrefMatch.group(1) ?? '';
      if (!href.endsWith('.zip')) continue;

      final fileName = href.split('/').last;
      if (!fileName.startsWith('knode_backup_')) continue;

      final createdAt = BackupSnapshot.parseTimestamp(fileName);
      if (createdAt == null) continue;

      final sizeMatch = sizePattern.firstMatch(block);
      final sizeBytes = sizeMatch != null ? (int.tryParse(sizeMatch.group(1)!) ?? 0) : 0;

      snapshots.add(BackupSnapshot(
        fileName: fileName,
        sizeBytes: sizeBytes,
        createdAt: createdAt,
      ));
    }

    snapshots.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return snapshots;
  }

  // ============================================================
  // 删除备份
  // ============================================================

  /// 删除指定的备份快照。
  Future<void> deleteBackup(BackupSnapshot snapshot) async {
    if (!isConfigured) throw StateError('WebDAV 未配置');

    AppLogger.instance.i('删除备份: ${snapshot.fileName}', tag: 'Backup');
    final uri = Uri.parse('$_url/$_backupDir/${snapshot.fileName}');
    final client = http.Client();
    try {
      final resp = await client.delete(uri, headers: _authHeaders);
      if (resp.statusCode >= 400 && resp.statusCode != 404) {
        throw StateError('删除失败: HTTP ${resp.statusCode}');
      }
    } finally {
      client.close();
    }
  }

  // ============================================================
  // 自动清理
  // ============================================================

  /// 自动清理旧备份，保留最近 [keepCount] 个。
  Future<int> autoCleanup({int keepCount = 5}) async {
    if (!isConfigured) throw StateError('WebDAV 未配置');

    final snapshots = await listBackups();
    if (snapshots.length <= keepCount) return 0;

    int deletedCount = 0;
    for (int i = keepCount; i < snapshots.length; i++) {
      try {
        await deleteBackup(snapshots[i]);
        deletedCount++;
      } catch (_) {
        // 单个删除失败不影响整体清理
      }
    }
    if (deletedCount > 0) {
      AppLogger.instance.i('自动清理: 删除 $deletedCount 个旧备份', tag: 'Backup');
    }
    return deletedCount;
  }

  // ============================================================
  // 辅助方法
  // ============================================================

  Future<BackupSnapshot?> _getLatestSnapshot() async {
    final snapshots = await listBackups();
    return snapshots.isNotEmpty ? snapshots.first : null;
  }

  /// 确保 WebDAV 目录存在（MKCOL 请求）。
  Future<void> _ensureDirectory(String dirUrl) async {
    final client = http.Client();
    try {
      await client.send(
        http.Request('MKCOL', Uri.parse(dirUrl))
          ..headers.addAll(_authHeaders),
      );
      // 405 Method Not Allowed 表示目录已存在，忽略
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

  // ============================================================
  // 旧版兼容
  // ============================================================

  Future<bool> testConnection() async {
    if (!isConfigured) return false;
    try {
      final uri = Uri.parse(_url!);
      final resp = await http.get(uri).timeout(const Duration(seconds: 5));
      final ok = resp.statusCode < 400;
      AppLogger.instance.d('WebDAV 连接测试: ${ok ? "成功" : "失败"}', tag: 'Backup');
      return ok;
    } catch (e) {
      AppLogger.instance.d('WebDAV 连接测试: 失败', tag: 'Backup', error: e);
      return false;
    }
  }

  void dispose() {
    _url = null;
    _user = null;
    _pass = null;
  }
}
