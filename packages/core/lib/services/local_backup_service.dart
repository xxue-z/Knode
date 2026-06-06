import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:core/models/backup_snapshot.dart';
import 'package:core/utils/zip_utils.dart';
import 'package:core/services/app_logger.dart';
import '../gen/strings.dart';

const _strings = L10nStringsMixin();

typedef BackupProgressCallback = void Function(double percent, String message);

class LocalBackupService {
  static const _backupDirName = 'knode_backups';
  static const _dbFileName = 'knode.db';
  static const _wikiPrefix = 'wiki/';
  // static const _maxBackups = 10; // unused

  /// 创建本地 Zip 压缩备份到指定目录。
  Future<BackupSnapshot> backup({
    required String dbPath,
    required String wikiRoot,
    required String backupRoot,
    BackupProgressCallback? onProgress,
  }) async {
    AppLogger.instance.i('开始本地备份: backupRoot=', tag: 'LocalBackup');
    onProgress?.call(0.0, _strings.core_progress_packing);

    final zipBytes = await ZipUtils.compressDirectory(
      directory: wikiRoot,
      prefix: _wikiPrefix,
      dbPath: dbPath,
    );

    onProgress?.call(0.5, '保存到本地...');

    // final timestamp = _formatTimestamp(DateTime.now()); // unused
    final fileName = 'knode_backup_.zip';
    final backupDir = Directory(p.join(backupRoot, _backupDirName));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    final file = File(p.join(backupDir.path, fileName));
    await file.writeAsBytes(zipBytes);

    onProgress?.call(1.0, _strings.core_progress_backup_complete);
    AppLogger.instance.i('本地备份完成: , 大小=B', tag: 'LocalBackup');

    return BackupSnapshot(
      fileName: fileName,
      sizeBytes: zipBytes.length,
      createdAt: DateTime.now(),
      filePath: file.path,
    );
  }

  /// 从本地备份目录恢复指定快照。
  Future<void> restore({
    required String dbPath,
    required String wikiRoot,
    required String backupRoot,
    BackupSnapshot? snapshot,
    BackupProgressCallback? onProgress,
  }) async {
    final targetSnapshot = snapshot ?? await _getLatestSnapshot(backupRoot);
    if (targetSnapshot == null) throw StateError('没有可用的本地备份');

    AppLogger.instance.i('开始本地恢复: ', tag: 'LocalBackup');
    onProgress?.call(0.0, '读取 ...');

    final file = File(targetSnapshot.filePath ?? p.join(backupRoot, _backupDirName, targetSnapshot.fileName));
    if (!await file.exists()) {
      throw StateError('备份文件不存在: ');
    }

    final zipBytes = await file.readAsBytes();
    onProgress?.call(0.4, _strings.core_progress_decompressing);

    await ZipUtils.decompressToDirectory(
      zipBytes: zipBytes,
      targetDirectory: wikiRoot,
      pathMapping: {_dbFileName: dbPath},
    );

    onProgress?.call(1.0, '恢复完成 ( 个文件)');
    AppLogger.instance.i('本地恢复完成:  个文件', tag: 'LocalBackup');
  }

  /// 获取本地备份快照列表，按时间倒序排列。
  Future<List<BackupSnapshot>> listBackups(String backupRoot) async {
    final backupDir = Directory(p.join(backupRoot, _backupDirName));
    if (!await backupDir.exists()) return [];

    final snapshots = <BackupSnapshot>[];
    await for (final entity in backupDir.list()) {
      if (entity is! File) continue;
      if (!entity.path.endsWith('.zip')) continue;

      final fileName = p.basename(entity.path);
      if (!fileName.startsWith('knode_backup_')) continue;

      final createdAt = BackupSnapshot.parseTimestamp(fileName);
      if (createdAt == null) continue;

      final stat = await entity.stat();
      snapshots.add(BackupSnapshot(
        fileName: fileName,
        sizeBytes: stat.size,
        createdAt: createdAt,
        filePath: entity.path,
      ));
    }

    snapshots.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    AppLogger.instance.i('本地备份列表:  个快照', tag: 'LocalBackup');
    return snapshots;
  }

  /// 获取上次备份时间。
  Future<DateTime?> getLastBackupTime(String backupRoot) async {
    final snapshots = await listBackups(backupRoot);
    return snapshots.isNotEmpty ? snapshots.first.createdAt : null;
  }

  /// 删除指定备份文件。
  Future<void> deleteBackup(BackupSnapshot snapshot) async {
    final file = File(snapshot.filePath ?? '');
    if (await file.exists()) {
      await file.delete();
      AppLogger.instance.i('删除本地备份: ', tag: 'LocalBackup');
    }
  }

  /// 自动清理旧备份，保留最近 [keepCount] 个。
  Future<int> autoCleanup(String backupRoot, {int keepCount = 5}) async {
    final snapshots = await listBackups(backupRoot);
    if (snapshots.length <= keepCount) return 0;

    int deletedCount = 0;
    for (int i = keepCount; i < snapshots.length; i++) {
      try {
        await deleteBackup(snapshots[i]);
        deletedCount++;
      } catch (_) {}
    }
    if (deletedCount > 0) {
      AppLogger.instance.i('本地自动清理: 删除  个旧备份', tag: 'LocalBackup');
    }
    return deletedCount;
  }

  Future<BackupSnapshot?> _getLatestSnapshot(String backupRoot) async {
    final snapshots = await listBackups(backupRoot);
    return snapshots.isNotEmpty ? snapshots.first : null;
  }

}
