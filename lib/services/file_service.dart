import 'dart:io';

import 'package:path/path.dart' as p;

/// 文件系统操作服务，负责文档内容文件的读写和目录管理。
class FileService {
  /// 知识库根目录，所有文档 .md 文件存放于此。
  final String _rootPath;

  FileService(this._rootPath);

  /// 确保根目录存在。
  Future<void> init() async {
    final dir = Directory(_rootPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  /// 获取文档文件的完整路径。
  String _docPath(String fileName) => p.join(_rootPath, fileName);

  /// 读取文档内容。
  Future<String> readContent(String fileName) async {
    final file = File(_docPath(fileName));
    if (!await file.exists()) {
      throw FileSystemException('Document file not found', _docPath(fileName));
    }
    return await file.readAsString();
  }

  /// 写入文档内容。
  Future<void> writeContent(String fileName, String content) async {
    final file = File(_docPath(fileName));
    await file.writeAsString(content);
  }

  /// 删除文档文件。
  Future<void> deleteFile(String fileName) async {
    final file = File(_docPath(fileName));
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// 检查文件是否存在。
  Future<bool> fileExists(String fileName) async {
    return await File(_docPath(fileName)).exists();
  }

  /// 生成唯一的文件名（基于标题的 snake_case + 时间戳）。
  String generateFileName(String title) {
    final sanitized = title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\u4e00-\u9fff]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${sanitized}_$timestamp.md';
  }

  /// 复制文件到目标路径。
  Future<String> copyFile(String sourcePath, String destFileName) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw FileSystemException('Source file not found', sourcePath);
    }
    final dest = File(_docPath(destFileName));
    await source.copy(dest.path);
    return dest.path;
  }

  /// 列出根目录下所有 .md 文件名。
  Future<List<String>> listFiles() async {
    final dir = Directory(_rootPath);
    if (!await dir.exists()) return [];
    final entities = await dir.list().toList();
    return entities
        .whereType<File>()
        .where((f) => p.extension(f.path) == '.md')
        .map((f) => p.basename(f.path))
        .toList();
  }
}
