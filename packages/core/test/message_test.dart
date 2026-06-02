import 'package:flutter_test/flutter_test.dart';
import 'package:core/models/message.dart';

void main() {
  group('Message Model Tests', () {
    test('Message should be created with required fields', () {
      final message = Message(
        id: 1,
        conversationId: 1,
        role: 'user',
        content: 'Hello',
        contentType: 'text',
        createdAt: '2024-01-01',
      );

      expect(message.id, equals(1));
      expect(message.conversationId, equals(1));
      expect(message.role, equals('user'));
      expect(message.content, equals('Hello'));
      expect(message.contentType, equals('text'));
    });

    test('Message should handle optional fields', () {
      final message = Message(
        id: 1,
        conversationId: 1,
        role: 'assistant',
        content: 'Response',
        contentType: 'text',
        mediaPath: '/path/to/media',
        citations: '[1]',
        createdAt: '2024-01-01',
      );

      expect(message.mediaPath, equals('/path/to/media'));
      expect(message.citations, equals('[1]'));
    });

    test('Message should convert to Map correctly', () {
      final message = Message(
        id: 1,
        conversationId: 1,
        role: 'user',
        content: 'Hello',
        contentType: 'text',
        createdAt: '2024-01-01',
      );

      final map = message.toMap();

      expect(map['id'], equals(1));
      expect(map['conversationId'], equals(1));
      expect(map['role'], equals('user'));
      expect(map['content'], equals('Hello'));
    });

    test('Message should be created from Map correctly', () {
      final map = {
        'id': 1,
        'conversationId': 1,
        'role': 'user',
        'content': 'Hello',
        'contentType': 'text',
        'mediaPath': null,
        'citations': null,
        'createdAt': '2024-01-01',
      };

      final message = Message.fromMap(map);

      expect(message.id, equals(1));
      expect(message.role, equals('user'));
      expect(message.mediaPath, isNull);
      expect(message.citations, isNull);
    });

    test('Message copyWith should update specified fields only', () {
      final original = Message(
        id: 1,
        conversationId: 1,
        role: 'user',
        content: 'Original',
        contentType: 'text',
        createdAt: '2024-01-01',
      );

      final updated = original.copyWith(
        content: 'Updated',
        citations: '[1]',
      );

      expect(updated.id, equals(1));
      expect(updated.content, equals('Updated'));
      expect(updated.citations, equals('[1]'));
      expect(updated.role, equals('user'));
    });

    test('Message should handle different roles', () {
      final userMessage = Message(
        id: 1,
        conversationId: 1,
        role: 'user',
        content: 'Question',
        contentType: 'text',
        createdAt: '2024-01-01',
      );

      final assistantMessage = Message(
        id: 2,
        conversationId: 1,
        role: 'assistant',
        content: 'Answer',
        contentType: 'text',
        createdAt: '2024-01-01',
      );

      expect(userMessage.role, equals('user'));
      expect(assistantMessage.role, equals('assistant'));
    });
  });
}
