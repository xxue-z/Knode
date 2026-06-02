import 'package:flutter_test/flutter_test.dart';
import 'package:core/models/bookmark.dart';

void main() {
  group('Bookmark Model Tests', () {
    test('Bookmark should be created with required fields', () {
      final bookmark = Bookmark(
        docId: 1,
        position: 100,
        endPosition: 150,
        selectedText: 'Test text',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(bookmark.docId, equals(1));
      expect(bookmark.position, equals(100));
      expect(bookmark.endPosition, equals(150));
      expect(bookmark.selectedText, equals('Test text'));
      expect(bookmark.id, isNull);
      expect(bookmark.label, isNull);
    });

    test('Bookmark should handle optional id and label', () {
      final bookmark = Bookmark(
        id: 1,
        docId: 1,
        position: 100,
        endPosition: 150,
        selectedText: 'Test text',
        label: 'Important',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(bookmark.id, equals(1));
      expect(bookmark.label, equals('Important'));
    });

    test('Bookmark copyWith should update specified fields only', () {
      final original = Bookmark(
        id: 1,
        docId: 1,
        position: 100,
        endPosition: 150,
        selectedText: 'Original text',
        label: 'Original label',
        createdAt: DateTime(2024, 1, 1),
      );

      final updated = original.copyWith(
        label: 'Updated label',
        position: 200,
      );

      expect(updated.id, equals(1));
      expect(updated.docId, equals(1));
      expect(updated.position, equals(200));
      expect(updated.endPosition, equals(150));
      expect(updated.selectedText, equals('Original text'));
      expect(updated.label, equals('Updated label'));
    });

    test('Bookmark copyWith should preserve original values when not specified', () {
      final original = Bookmark(
        docId: 1,
        position: 100,
        endPosition: 150,
        selectedText: 'Test',
        createdAt: DateTime(2024, 1, 1),
      );

      final updated = original.copyWith();

      expect(updated.docId, equals(original.docId));
      expect(updated.position, equals(original.position));
      expect(updated.endPosition, equals(original.endPosition));
      expect(updated.selectedText, equals(original.selectedText));
      expect(updated.createdAt, equals(original.createdAt));
    });
  });
}
