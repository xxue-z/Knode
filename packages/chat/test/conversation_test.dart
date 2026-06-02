import 'package:flutter_test/flutter_test.dart';
import 'package:core/models/conversation.dart';

void main() {
  group('Conversation Model Tests', () {
    test('Conversation should be created with required fields', () {
      final conversation = Conversation(
        id: 1,
        status: 'active',
        createdAt: '2024-01-01',
        updatedAt: '2024-01-01',
      );

      expect(conversation.id, equals(1));
      expect(conversation.status, equals('active'));
      expect(conversation.title, isNull);
      expect(conversation.enableWebSearch, equals(0));
    });

    test('Conversation should handle optional fields', () {
      final conversation = Conversation(
        id: 1,
        title: 'Test Conversation',
        status: 'active',
        wikiFileId: 1,
        createdAt: '2024-01-01',
        updatedAt: '2024-01-01',
        enableWebSearch: 1,
      );

      expect(conversation.title, equals('Test Conversation'));
      expect(conversation.wikiFileId, equals(1));
      expect(conversation.enableWebSearch, equals(1));
    });

    test('Conversation should convert to Map correctly', () {
      final conversation = Conversation(
        id: 1,
        title: 'Test',
        status: 'active',
        createdAt: '2024-01-01',
        updatedAt: '2024-01-01',
      );

      final map = conversation.toMap();

      expect(map['id'], equals(1));
      expect(map['title'], equals('Test'));
      expect(map['status'], equals('active'));
    });

    test('Conversation should be created from Map correctly', () {
      final map = {
        'id': 1,
        'title': 'Test',
        'status': 'active',
        'wikiFileId': null,
        'createdAt': '2024-01-01',
        'updatedAt': '2024-01-01',
        'enableWebSearch': 1,
      };

      final conversation = Conversation.fromMap(map);

      expect(conversation.id, equals(1));
      expect(conversation.title, equals('Test'));
      expect(conversation.enableWebSearch, equals(1));
    });

    test('Conversation copyWith should update specified fields only', () {
      final original = Conversation(
        id: 1,
        title: 'Original',
        status: 'active',
        createdAt: '2024-01-01',
        updatedAt: '2024-01-01',
      );

      final updated = original.copyWith(
        title: 'Updated',
        enableWebSearch: 1,
      );

      expect(updated.id, equals(1));
      expect(updated.title, equals('Updated'));
      expect(updated.status, equals('active'));
      expect(updated.enableWebSearch, equals(1));
    });

    test('Conversation should support different statuses', () {
      final active = Conversation(
        id: 1,
        status: 'active',
        createdAt: '2024-01-01',
        updatedAt: '2024-01-01',
      );

      final archived = Conversation(
        id: 2,
        status: 'archived',
        createdAt: '2024-01-01',
        updatedAt: '2024-01-01',
      );

      expect(active.status, equals('active'));
      expect(archived.status, equals('archived'));
    });
  });
}
