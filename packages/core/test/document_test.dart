import 'package:flutter_test/flutter_test.dart';
import 'package:core/models/document.dart';

void main() {
  group('Document Model Tests', () {
    test('Document should be created with required fields', () {
      final document = Document(
        id: 1,
        title: 'Test Document',
        fileName: 'test.md',
        wordCount: 100,
        readingTime: 5,
        readCount: 0,
        isDeleted: 0,
        createdAt: '2024-01-01',
        updatedAt: '2024-01-01',
      );

      expect(document.id, equals(1));
      expect(document.title, equals('Test Document'));
      expect(document.fileName, equals('test.md'));
      expect(document.wordCount, equals(100));
      expect(document.isDeleted, equals(0));
    });

    test('Document should convert to Map correctly', () {
      final document = Document(
        id: 1,
        title: 'Test Document',
        fileName: 'test.md',
        wordCount: 100,
        readingTime: 5,
        readCount: 0,
        isDeleted: 0,
        createdAt: '2024-01-01',
        updatedAt: '2024-01-01',
        tags: ['tag1', 'tag2'],
      );

      final map = document.toMap();

      expect(map['id'], equals(1));
      expect(map['title'], equals('Test Document'));
      expect(map['fileName'], equals('test.md'));
      expect(map['tags'], equals(['tag1', 'tag2']));
    });

    test('Document should be created from Map correctly', () {
      final map = {
        'id': 1,
        'title': 'Test Document',
        'fileName': 'test.md',
        'filePath': '/path/to/file',
        'categoryId': 1,
        'wordCount': 100,
        'readingTime': 5,
        'readCount': 0,
        'isDeleted': 0,
        'tags': ['tag1', 'tag2'],
        'linksTo': [1, 2],
        'manualTags': 1,
        'createdAt': '2024-01-01',
        'updatedAt': '2024-01-01',
      };

      final document = Document.fromMap(map);

      expect(document.id, equals(1));
      expect(document.title, equals('Test Document'));
      expect(document.filePath, equals('/path/to/file'));
      expect(document.categoryId, equals(1));
      expect(document.tags, equals(['tag1', 'tag2']));
      expect(document.linksTo, equals([1, 2]));
      expect(document.manualTags, equals(1));
    });

    test('Document copyWith should update specified fields only', () {
      final original = Document(
        id: 1,
        title: 'Original Title',
        fileName: 'test.md',
        wordCount: 100,
        readingTime: 5,
        readCount: 0,
        isDeleted: 0,
        createdAt: '2024-01-01',
        updatedAt: '2024-01-01',
      );

      final updated = original.copyWith(
        title: 'Updated Title',
        wordCount: 200,
      );

      expect(updated.id, equals(1));
      expect(updated.title, equals('Updated Title'));
      expect(updated.fileName, equals('test.md'));
      expect(updated.wordCount, equals(200));
      expect(updated.readingTime, equals(5));
    });

    test('Document should handle null optional fields', () {
      final document = Document(
        id: 1,
        title: 'Test',
        fileName: 'test.md',
        wordCount: 100,
        readingTime: 5,
        readCount: 0,
        isDeleted: 0,
        createdAt: '2024-01-01',
        updatedAt: '2024-01-01',
      );

      expect(document.filePath, isNull);
      expect(document.categoryId, isNull);
      expect(document.contentText, isNull);
      expect(document.summary, isNull);
      expect(document.sourceDocId, isNull);
    });

    test('Document should handle empty tags and linksTo', () {
      final document = Document(
        id: 1,
        title: 'Test',
        fileName: 'test.md',
        wordCount: 100,
        readingTime: 5,
        readCount: 0,
        isDeleted: 0,
        createdAt: '2024-01-01',
        updatedAt: '2024-01-01',
      );

      expect(document.tags, isEmpty);
      expect(document.linksTo, isEmpty);
    });

    test('Document fromMap should handle null tags and linksTo', () {
      final map = {
        'id': 1,
        'title': 'Test',
        'fileName': 'test.md',
        'wordCount': 100,
        'readingTime': 5,
        'readCount': 0,
        'isDeleted': 0,
        'createdAt': '2024-01-01',
        'updatedAt': '2024-01-01',
      };

      final document = Document.fromMap(map);

      expect(document.tags, isEmpty);
      expect(document.linksTo, isEmpty);
    });
  });
}
