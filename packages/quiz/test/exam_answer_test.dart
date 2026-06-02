import 'package:flutter_test/flutter_test.dart';
import 'package:core/models/exam_answer.dart';

void main() {
  group('ExamAnswer Model Tests', () {
    test('ExamAnswer should be created with required fields', () {
      final answer = ExamAnswer(
        id: 1,
        examId: 1,
        questionId: 1,
      );

      expect(answer.id, equals(1));
      expect(answer.examId, equals(1));
      expect(answer.questionId, equals(1));
      expect(answer.userAnswer, isNull);
    });

    test('ExamAnswer should handle optional fields', () {
      final answer = ExamAnswer(
        id: 1,
        examId: 1,
        questionId: 1,
        userAnswer: 'A',
        isCorrect: 1,
        score: 10.0,
        aiFeedback: 'Correct answer!',
        feedback: 'Well done',
        createdAt: '2024-01-01',
      );

      expect(answer.userAnswer, equals('A'));
      expect(answer.isCorrect, equals(1));
      expect(answer.score, equals(10.0));
      expect(answer.aiFeedback, equals('Correct answer!'));
      expect(answer.feedback, equals('Well done'));
    });

    test('ExamAnswer should convert to Map correctly', () {
      final answer = ExamAnswer(
        id: 1,
        examId: 1,
        questionId: 1,
        userAnswer: 'B',
        isCorrect: 0,
      );

      final map = answer.toMap();

      expect(map['id'], equals(1));
      expect(map['examId'], equals(1));
      expect(map['questionId'], equals(1));
      expect(map['userAnswer'], equals('B'));
      expect(map['isCorrect'], equals(0));
    });

    test('ExamAnswer should be created from Map correctly', () {
      final map = {
        'id': 1,
        'examId': 1,
        'questionId': 1,
        'userAnswer': 'A',
        'isCorrect': 1,
        'score': 10.0,
        'aiFeedback': 'Good',
        'feedback': null,
        'createdAt': '2024-01-01',
      };

      final answer = ExamAnswer.fromMap(map);

      expect(answer.id, equals(1));
      expect(answer.userAnswer, equals('A'));
      expect(answer.isCorrect, equals(1));
      expect(answer.score, equals(10.0));
    });

    test('ExamAnswer copyWith should update specified fields only', () {
      final original = ExamAnswer(
        id: 1,
        examId: 1,
        questionId: 1,
        userAnswer: 'A',
      );

      final updated = original.copyWith(
        isCorrect: 1,
        score: 10.0,
      );

      expect(updated.id, equals(1));
      expect(updated.userAnswer, equals('A'));
      expect(updated.isCorrect, equals(1));
      expect(updated.score, equals(10.0));
    });

    test('ExamAnswer should handle correct and incorrect answers', () {
      final correct = ExamAnswer(
        id: 1,
        examId: 1,
        questionId: 1,
        isCorrect: 1,
      );

      final incorrect = ExamAnswer(
        id: 2,
        examId: 1,
        questionId: 1,
        isCorrect: 0,
      );

      expect(correct.isCorrect, equals(1));
      expect(incorrect.isCorrect, equals(0));
    });
  });
}
