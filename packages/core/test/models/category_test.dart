import 'package:test/test.dart';
import 'package:core/models/category.dart';

void main() {
  group('Category', () {
    final now = DateTime(2026, 5, 30, 14, 30).toIso8601String();
    final category = Category(
      id: 1,
      name: '笔记',
      parentId: 0,
      sortOrder: 1,
      createdAt: now,
      updatedAt: now,
    );

    test('fromMap creates correct instance', () {
      final map = {
        'id': 1,
        'name': '笔记',
        'parentId': 0,
        'sortOrder': 1,
        'createdAt': now,
        'updatedAt': now,
      };
      final result = Category.fromMap(map);
      expect(result.id, 1);
      expect(result.name, '笔记');
      expect(result.parentId, 0);
      expect(result.sortOrder, 1);
    });

    test('toMap returns correct map', () {
      final map = category.toMap();
      expect(map['id'], 1);
      expect(map['name'], '笔记');
      expect(map['parentId'], 0);
      expect(map['sortOrder'], 1);
    });

    test('fromMap → toMap roundtrip', () {
      final map = category.toMap();
      final restored = Category.fromMap(map);
      expect(restored.id, category.id);
      expect(restored.name, category.name);
      expect(restored.parentId, category.parentId);
      expect(restored.sortOrder, category.sortOrder);
    });

    test('copyWith creates new instance with overrides', () {
      final modified = category.copyWith(name: '学习资料', sortOrder: 2);
      expect(modified.name, '学习资料');
      expect(modified.sortOrder, 2);
      expect(modified.id, category.id); // unchanged
      expect(modified.parentId, category.parentId); // unchanged
    });

    test('copyWith with no args returns equal instance', () {
      final copy = category.copyWith();
      expect(copy.id, category.id);
      expect(copy.name, category.name);
    });
  });
}
