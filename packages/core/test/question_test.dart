import 'package:flutter_test/flutter_test.dart';
import 'package:core/models/question.dart';

void main() {
  group('Question Model Tests', () {
    test('Question should be created with required fields', () {
      final question = Question(
        id: 1,
        type: 'single_choice',
        stem: 'What is Flutter?',
        answer: 'A UI toolkit',
        difficulty: 1,
        createdAt: '2024-01-01',
      );

      expect(question.id, equals(1));
      expect(question.type, equals('single_choice'));
      expect(question.stem, equals('What is Flutter?'));
      expect(question.answer, equals('A UI toolkit'));
      expect(question.difficulty, equals(1));
    });

    test('Question should handle optional fields', () {
      final question = Question(
        id: 1,
        type: 'single_choice',
        stem: 'What is Flutter?',
        options: '["A", "B", "C"]',
        answer: 'A',
        explanation: 'Flutter is a UI toolkit.',
        sourceFileIds: '1,2,3',
        difficulty: 2,
        tags: 'flutter,ui',
        createdAt: '2024-01-01',
        contentHash: 'abc123',
      );

      expect(question.options, equals('["A", "B", "C"]'));
      expect(question.explanation, equals('Flutter is a UI toolkit.'));
      expect(question.sourceFileIds, equals('1,2,3'));
      expect(question.tags, equals('flutter,ui'));
      expect(question.contentHash, equals('abc123'));
    });

    test('Question should convert to Map correctly', () {
      final question = Question(
        id: 1,
        type: 'single_choice',
        stem: 'What is Flutter?',
        answer: 'A UI toolkit',
        difficulty: 1,
        createdAt: '2024-01-01',
      );

      final map = question.toMap();

      expect(map['id'], equals(1));
      expect(map['type'], equals('single_choice'));
      expect(map['stem'], equals('What is Flutter?'));
      expect(map['answer'], equals('A UI toolkit'));
    });

    test('Question should be created from Map correctly', () {
      final map = {
        'id': 1,
        'type': 'single_choice',
        'stem': 'What is Flutter?',
        'options': '["A", "B"]',
        'answer': 'A',
        'explanation': 'Explanation',
        'sourceFileIds': null,
        'difficulty': 1,
        'tags': null,
        'createdAt': '2024-01-01',
        'contentHash': null,
      };

      final question = Question.fromMap(map);

      expect(question.id, equals(1));
      expect(question.type, equals('single_choice'));
      expect(question.options, equals('["A", "B"]'));
      expect(question.explanation, equals('Explanation'));
    });

    test('Question copyWith should update specified fields only', () {
      final original = Question(
        id: 1,
        type: 'single_choice',
        stem: 'Original question',
        answer: 'A',
        difficulty: 1,
        createdAt: '2024-01-01',
      );

      final updated = original.copyWith(
        stem: 'Updated question',
        difficulty: 2,
      );

      expect(updated.id, equals(1));
      expect(updated.stem, equals('Updated question'));
      expect(updated.difficulty, equals(2));
      expect(updated.answer, equals('A'));
    });

    test('Question should support different types', () {
      final singleChoice = Question(
        id: 1,
        type: 'single_choice',
        stem: 'Single choice question',
        answer: 'A',
        difficulty: 1,
        createdAt: '2024-01-01',
      );

      final multipleChoice = Question(
        id: 2,
        type: 'multiple_choice',
        stem: 'Multiple choice question',
        answer: 'A,B',
        difficulty: 2,
        createdAt: '2024-01-01',
      );

      final fillBlank = Question(
        id: 3,
        type: 'fill_blank',
        stem: 'Fill in the blank',
        answer: 'answer',
        difficulty: 1,
        createdAt: '2024-01-01',
      );

      final essay = Question(
        id: 4,
        type: 'essay',
        stem: 'Essay question',
        answer: 'Sample answer',
        difficulty: 3,
        createdAt: '2024-01-01',
      );

      expect(singleChoice.type, equals('single_choice'));
      expect(multipleChoice.type, equals('multiple_choice'));
      expect(fillBlank.type, equals('fill_blank'));
      expect(essay.type, equals('essay'));
    });
  });
}
