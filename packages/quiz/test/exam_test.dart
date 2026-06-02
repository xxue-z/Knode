import 'package:flutter_test/flutter_test.dart';
import 'package:core/models/exam.dart';

void main() {
  group('Exam Model Tests', () {
    test('Exam should be created with required fields', () {
      final exam = Exam(
        id: 1,
        examType: 'daily',
        status: 'pending',
      );

      expect(exam.id, equals(1));
      expect(exam.examType, equals('daily'));
      expect(exam.status, equals('pending'));
      expect(exam.title, isNull);
    });

    test('Exam should handle optional fields', () {
      final exam = Exam(
        id: 1,
        examType: 'quick',
        title: 'Quick Quiz',
        questionCount: 10,
        totalScore: 100.0,
        obtainedScore: 85.0,
        timeLimit: 600,
        startedAt: '2024-01-01T10:00:00',
        finishedAt: '2024-01-01T10:10:00',
        status: 'completed',
      );

      expect(exam.title, equals('Quick Quiz'));
      expect(exam.questionCount, equals(10));
      expect(exam.totalScore, equals(100.0));
      expect(exam.obtainedScore, equals(85.0));
      expect(exam.timeLimit, equals(600));
    });

    test('Exam should convert to Map correctly', () {
      final exam = Exam(
        id: 1,
        examType: 'daily',
        title: 'Daily Quiz',
        status: 'active',
      );

      final map = exam.toMap();

      expect(map['id'], equals(1));
      expect(map['examType'], equals('daily'));
      expect(map['title'], equals('Daily Quiz'));
      expect(map['status'], equals('active'));
    });

    test('Exam should be created from Map correctly', () {
      final map = {
        'id': 1,
        'examType': 'quick',
        'title': 'Test',
        'questionCount': 5,
        'totalScore': null,
        'obtainedScore': null,
        'timeLimit': null,
        'startedAt': null,
        'finishedAt': null,
        'status': 'pending',
        'configJson': null,
        'createdAt': '2024-01-01',
        'updatedAt': '2024-01-01',
      };

      final exam = Exam.fromMap(map);

      expect(exam.id, equals(1));
      expect(exam.examType, equals('quick'));
      expect(exam.questionCount, equals(5));
    });

    test('Exam copyWith should update specified fields only', () {
      final original = Exam(
        id: 1,
        examType: 'daily',
        status: 'pending',
      );

      final updated = original.copyWith(
        status: 'active',
        startedAt: '2024-01-01T10:00:00',
      );

      expect(updated.id, equals(1));
      expect(updated.status, equals('active'));
      expect(updated.startedAt, equals('2024-01-01T10:00:00'));
      expect(updated.examType, equals('daily'));
    });

    test('Exam should support different types', () {
      final daily = Exam(id: 1, examType: 'daily', status: 'pending');
      final quick = Exam(id: 2, examType: 'quick', status: 'pending');
      final wrong = Exam(id: 3, examType: 'wrong', status: 'pending');

      expect(daily.examType, equals('daily'));
      expect(quick.examType, equals('quick'));
      expect(wrong.examType, equals('wrong'));
    });

    test('Exam should support different statuses', () {
      final pending = Exam(id: 1, examType: 'daily', status: 'pending');
      final active = Exam(id: 2, examType: 'daily', status: 'active');
      final completed = Exam(id: 3, examType: 'daily', status: 'completed');

      expect(pending.status, equals('pending'));
      expect(active.status, equals('active'));
      expect(completed.status, equals('completed'));
    });
  });
}
