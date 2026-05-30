import 'dart:io';
import 'package:path/path.dart' as p;

/// 文件操作工具类。
class FileUtils {
  FileUtils._();

  /// 确保目录存在，不存在则创建。
  static Future<void> ensureDir(String dirPath) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  /// 读取文件内容，文件不存在返回 null。
  static Future<String?> readFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return null;
    return file.readAsString();
  }

  /// 写入文件内容，自动创建目录。
  static Future<void> writeFile(String filePath, String content) async {
    final file = File(filePath);
    await ensureDir(p.dirname(filePath));
    await file.writeAsString(content);
  }

  /// 删除文件，文件不存在则忽略。
  static Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// 复制文件。
  static Future<void> copyFile(String sourcePath, String targetPath) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw FileSystemException('源文件不存在', sourcePath);
    }
    await ensureDir(p.dirname(targetPath));
    await source.copy(targetPath);
  }

  /// 获取文件大小（字节），文件不存在返回 -1。
  static Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return -1;
    return file.length();
  }

  /// 格式化文件大小为可读字符串。
  static String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// 列出目录下的文件。
  static Future<List<FileSystemEntity>> listFiles(
    String dirPath, {
    bool recursive = false,
    String? extension,
  }) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) return [];

    final entities = dir.listSync(recursive: recursive);
    if (extension == null) return entities;

    return entities.where((e) => e.path.endsWith(extension)).toList();
  }

  /// 检查文件是否存在。
  static Future<bool> exists(String filePath) {
    return File(filePath).exists();
  }
}
