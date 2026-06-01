import 'dart:io';
import 'package:test/test.dart';
import 'package:core/utils/zip_utils.dart';

void main() {
  group('ZipUtils', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('zip_utils_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('compressFiles', () {
      test('compresses files to zip bytes', () async {
        final file1 = File('${tempDir.path}/test1.txt');
        await file1.writeAsString('Hello World');
        final file2 = File('${tempDir.path}/test2.txt');
        await file2.writeAsString('Dart is great');

        final zipBytes = await ZipUtils.compressFiles({
          'test1.txt': file1.path,
          'test2.txt': file2.path,
        });

        expect(zipBytes.isNotEmpty, true);
        expect(zipBytes.length, greaterThan(0));
      });

      test('skips non-existent files', () async {
        final file1 = File('${tempDir.path}/exists.txt');
        await file1.writeAsString('Content');

        final zipBytes = await ZipUtils.compressFiles({
          'exists.txt': file1.path,
          'missing.txt': '${tempDir.path}/missing.txt',
        });

        expect(zipBytes.isNotEmpty, true);
      });

      test('throws on empty files map', () async {
        final zipBytes = await ZipUtils.compressFiles({});
        expect(zipBytes.isEmpty, true);
      });
    });

    group('compressDirectory', () {
      test('compresses directory with files', () async {
        final subDir = Directory('${tempDir.path}/wiki');
        await subDir.create();
        await File('${subDir.path}/doc1.md').writeAsString('# Doc 1');
        await File('${subDir.path}/doc2.md').writeAsString('# Doc 2');

        final zipBytes = await ZipUtils.compressDirectory(
          directory: tempDir.path,
          prefix: 'wiki/',
        );

        expect(zipBytes.isNotEmpty, true);
      });

      test('includes database file when provided', () async {
        final dbFile = File('${tempDir.path}/knode.db');
        await dbFile.writeAsString('database content');

        final zipBytes = await ZipUtils.compressDirectory(
          directory: tempDir.path,
          dbPath: dbFile.path,
        );

        expect(zipBytes.isNotEmpty, true);
      });
    });

    group('decompressToList', () {
      test('decompresses zip to list of entries', () async {
        final file1 = File('${tempDir.path}/test.txt');
        await file1.writeAsString('Test content');
        final zipBytes = await ZipUtils.compressFiles({
          'test.txt': file1.path,
        });

        final entries = ZipUtils.decompressToList(zipBytes);

        expect(entries.length, 1);
        expect(entries.first.name, 'test.txt');
        expect(String.fromCharCodes(entries.first.content), 'Test content');
      });

      test('returns empty list for empty zip', () async {
        final entries = ZipUtils.decompressToList([]);
        expect(entries.isEmpty, true);
      });
    });

    group('decompressToDirectory', () {
      test('decompresses zip to target directory', () async {
        final file1 = File('${tempDir.path}/test.txt');
        await file1.writeAsString('Original content');
        final zipBytes = await ZipUtils.compressFiles({
          'test.txt': file1.path,
        });

        final extractDir = Directory('${tempDir.path}/extract');
        await extractDir.create();

        final count = await ZipUtils.decompressToDirectory(
          zipBytes: zipBytes,
          targetDirectory: extractDir.path,
        );

        expect(count, 1);
        final extractedFile = File('${extractDir.path}/test.txt');
        expect(await extractedFile.exists(), true);
        expect(await extractedFile.readAsString(), 'Original content');
      });

      test('uses path mapping correctly', () async {
        final file1 = File('${tempDir.path}/test.txt');
        await file1.writeAsString('Content');
        final zipBytes = await ZipUtils.compressFiles({
          'knode.db': file1.path,
        });

        final extractDir = Directory('${tempDir.path}/extract');
        await extractDir.create();
        final dbPath = '${extractDir.path}/custom_db.db';

        final count = await ZipUtils.decompressToDirectory(
          zipBytes: zipBytes,
          targetDirectory: extractDir.path,
          pathMapping: { 'knode.db': dbPath },
        );

        expect(count, 1);
        expect(await File(dbPath).exists(), true);
      });
    });

    group('extractFile', () {
      test('extracts single file from zip', () async {
        final file1 = File('${tempDir.path}/test1.txt');
        await file1.writeAsString('File 1 content');
        final file2 = File('${tempDir.path}/test2.txt');
        await file2.writeAsString('File 2 content');
        final zipBytes = await ZipUtils.compressFiles({
          'test1.txt': file1.path,
          'test2.txt': file2.path,
        });

        final content = ZipUtils.extractFile(zipBytes, 'test1.txt');

        expect(content, isNotNull);
        expect(String.fromCharCodes(content!), 'File 1 content');
      });

      test('returns null for non-existent file', () async {
        final file = File('${tempDir.path}/test.txt');
        await file.writeAsString('Content');
        final zipBytes = await ZipUtils.compressFiles({
          'test.txt': file.path,
        });

        final content = ZipUtils.extractFile(zipBytes, 'missing.txt');

        expect(content, isNull);
      });
    });
  });
}
