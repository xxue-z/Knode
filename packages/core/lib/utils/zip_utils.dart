import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

class ZipUtils {
  ZipUtils._();

  static Future<List<int>> compressFiles(Map<String, String> files) async {
    final archive = Archive();
    for (final entry in files.entries) {
      final file = File(entry.value);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        archive.addFile(ArchiveFile(entry.key, bytes.length, bytes));
      }
    }
    final zipBytes = ZipEncoder().encode(archive);
    if (zipBytes == null) throw StateError('Zip 压缩失败');
    return zipBytes;
  }

  static Future<List<int>> compressDirectory({
    required String directory,
    String prefix = '',
    String? dbPath,
  }) async {
    final files = <String, String>{};

    if (dbPath != null) {
      final dbFile = File(dbPath);
      if (await dbFile.exists()) {
        files['knode.db'] = dbPath;
      }
    }

    final dir = Directory(directory);
    if (await dir.exists()) {
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          final relPath = p.relative(entity.path, from: directory);
          files['$prefix$relPath'] = entity.path;
        }
      }
    }

    return compressFiles(files);
  }

  static List<ArchiveEntry> decompressToList(List<int> zipBytes) {
    final archive = ZipDecoder().decodeBytes(zipBytes);
    final entries = <ArchiveEntry>[];
    for (final file in archive) {
      if (file.isFile) {
        final content = file.content;
        if (content is! List<int>) continue;
        entries.add(ArchiveEntry(
          name: file.name,
          content: content,
        ));
      }
    }
    return entries;
  }

  static Future<int> decompressToDirectory({
    required List<int> zipBytes,
    required String targetDirectory,
    Map<String, String>? pathMapping,
  }) async {
    final archive = ZipDecoder().decodeBytes(zipBytes);
    int count = 0;

    for (final file in archive) {
      if (!file.isFile) continue;

      final filePath = file.name;
      String targetPath;

      if (pathMapping != null && pathMapping.containsKey(filePath)) {
        targetPath = pathMapping[filePath]!;
      } else {
        targetPath = p.join(targetDirectory, filePath);
      }

      final targetFile = File(targetPath);
      await targetFile.parent.create(recursive: true);
      final content = file.content;
      if (content is! List<int>) continue;
      await targetFile.writeAsBytes(content);
      count++;
    }

    return count;
  }

  static List<int>? extractFile(List<int> zipBytes, String fileName) {
    final archive = ZipDecoder().decodeBytes(zipBytes);
    for (final file in archive) {
      if (file.isFile && file.name == fileName) {
        final content = file.content;
        return content is List<int> ? content : null;
      }
    }
    return null;
  }
}

class ArchiveEntry {
  final String name;
  final List<int> content;
  const ArchiveEntry({required this.name, required this.content});
}
