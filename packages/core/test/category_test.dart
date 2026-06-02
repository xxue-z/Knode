import 'package:flutter_test/flutter_test.dart';
import 'package:core/models/category.dart';

void main() {
  group('Category Model Tests', () {
    test('Category should be created with required fields', () {
      final category = Category(
        id: 1,
        name: 'Test Category',
        parentId: 0,
        sortOrder: 1,
        createdAt: '2024-01-01',
        updatedAt: '2024-01-01',
      );

      expect(category.id, equals(1));
      expect(category.name, equals('Test Category'));
      expect(category.parentId, equals(0));
      expect(category.sortOrder, equals(1));
    });

    test('Category should convert to Map correctly', () {
      final category = Category(
        id: 1,
        name: 'Test Category',
        parentId: 0,
        sortOrder: 1,
        createdAt: '2024-01-01',
        updatedAt: '2024-01-01',
      );

      final map = category.toMap();

      expect(map['id'], equals(1));
      expect(map['name'], equals('Test Category'));
      expect(map['parentId'], equals(0));
      expect(map['sortOrder'], equals(1));
    });

    test('Category should be created from Map correctly', () {
      final map = {
        'id': 1,
        'name': 'Test Category',
        'parentId': 0,
        'sortOrder': 1,
        'createdAt': '2024-01-01',
        'updatedAt': '2024-01-01',
      };

      final category = Category.fromMap(map);

      expect(category.id, equals(1));
      expect(category.name, equals('Test Category'));
      expect(category.parentId, equals(0));
      expect(category.sortOrder, equals(1));
    });

    test('Category copyWith should update specified fields only', () {
      final original = Category(
        id: 1,
        name: 'Original Name',
        parentId: 0,
        sortOrder: 1,
        createdAt: '2024-01-01',
        updatedAt: '2024-01-01',
      );

      final updated = original.copyWith(
        name: 'Updated Name',
        sortOrder: 2,
      );

      expect(updated.id, equals(1));
      expect(updated.name, equals('Updated Name'));
      expect(updated.parentId, equals(0));
      expect(updated.sortOrder, equals(2));
    });

    test('Category should support nested categories', () {
      final parent = Category(
        id: 1,
        name: 'Parent',
        parentId: 0,
        sortOrder: 1,
        createdAt: '2024-01-01',
        updatedAt: '2024-01-01',
      );

      final child = Category(
        id: 2,
        name: 'Child',
        parentId: 1,
        sortOrder: 1,
        createdAt: '2024-01-01',
        updatedAt: '2024-01-01',
      );

      expect(parent.parentId, equals(0));
      expect(child.parentId, equals(1));
      expect(child.parentId, equals(parent.id));
    });
  });
}
