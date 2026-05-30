import 'package:test/test.dart';
import 'package:core/models/document.dart';

void main() {
  group('Document', () {
    test('fromMap creates correct instance with all fields', () {
      final map = {
        'id': 1,
        'title': 'Flutter 入门指南',
        'fileName': 'flutter_guide.md',
        'filePath': '/docs/flutter_guide.md',
        'categoryId': 2,
        'originalFormat': 'pdf',
        'originalFilePath': '/imports/guide.pdf',
        'contentText': '# Flutter\n\n内容...',
        'summary': 'Flutter 入门教程',
        'wordCount': 1500,
        'readingTime': 300,
        'readCount': 5,
        'lastReadAt': '2026-05-30',
        'isDeleted': 0,
        'createdAt': '2026-05-01',
        'updatedAt': '2026-05-30',
      };
      final doc = Document.fromMap(map);
      expect(doc.id, 1);
      expect(doc.title, 'Flutter 入门指南');
      expect(doc.fileName, 'flutter_guide.md');
      expect(doc.wordCount, 1500);
      expect(doc.isDeleted, 0);
    });

    test('fromMap handles null optional fields', () {
      final map = {
        'id': 2,
        'title': '无路径文档',
        'fileName': 'no_path.md',
        'wordCount': 100,
        'readingTime': 30,
        'readCount': 0,
        'isDeleted': 0,
        'createdAt': '2026-05-30',
        'updatedAt': '2026-05-30',
      };
      final doc = Document.fromMap(map);
      expect(doc.filePath, isNull);
      expect(doc.categoryId, isNull);
      expect(doc.originalFormat, isNull);
      expect(doc.contentText, isNull);
      expect(doc.summary, isNull);
      expect(doc.lastReadAt, isNull);
    });

    test('toMap → fromMap roundtrip', () {
      final doc = Document(
        id: 3,
        title: '测试文档',
        fileName: 'test.md',
        filePath: '/test.md',
        categoryId: 1,
        wordCount: 500,
        readingTime: 120,
        readCount: 3,
        isDeleted: 0,
        createdAt: '2026-05-30',
        updatedAt: '2026-05-30',
      );
      final map = doc.toMap();
      final restored = Document.fromMap(map);
      expect(restored.id, doc.id);
      expect(restored.title, doc.title);
      expect(restored.fileName, doc.fileName);
      expect(restored.filePath, doc.filePath);
      expect(restored.wordCount, doc.wordCount);
    });

    test('copyWith creates new instance with overrides', () {
      final doc = Document(
        id: 1,
        title: '原始标题',
        fileName: 'test.md',
        wordCount: 100,
        readingTime: 30,
        readCount: 0,
        isDeleted: 0,
        createdAt: '2026-05-30',
        updatedAt: '2026-05-30',
      );
      final modified = doc.copyWith(
        title: '新标题',
        readCount: 1,
        lastReadAt: '2026-05-31',
      );
      expect(modified.title, '新标题');
      expect(modified.readCount, 1);
      expect(modified.lastReadAt, '2026-05-31');
      expect(modified.id, doc.id);
      expect(modified.fileName, doc.fileName);
    });
  });
}
