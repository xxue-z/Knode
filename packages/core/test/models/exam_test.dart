import 'package:test/test.dart';
import 'package:core/models/exam.dart';

void main() {
  group('Exam', () {
    test('fromMap creates correct instance', () {
      final map = {
        'id': 1,
        'examType': 'daily',
        'title': '每日一测',
        'questionCount': 10,
        'totalScore': 100.0,
        'obtainedScore': 85.0,
        'timeLimit': 600,
        'startedAt': '2026-05-30T10:00:00',
        'finishedAt': '2026-05-30T10:08:30',
        'status': 'finished',
        'configJson': '{"scope":"all"}',
        'createdAt': '2026-05-30T09:00:00',
        'updatedAt': '2026-05-30T10:08:30',
      };
      final exam = Exam.fromMap(map);
      expect(exam.id, 1);
      expect(exam.examType, 'daily');
      expect(exam.title, '每日一测');
      expect(exam.questionCount, 10);
      expect(exam.totalScore, 100.0);
      expect(exam.obtainedScore, 85.0);
      expect(exam.status, 'finished');
    });

    test('fromMap handles null optional fields', () {
      final map = {
        'id': 2,
        'examType': 'random',
        'status': 'in_progress',
      };
      final exam = Exam.fromMap(map);
      expect(exam.title, isNull);
      expect(exam.questionCount, isNull);
      expect(exam.totalScore, isNull);
      expect(exam.obtainedScore, isNull);
      expect(exam.timeLimit, isNull);
      expect(exam.configJson, isNull);
    });

    test('toMap returns correct map', () {
      final exam = Exam(
        id: 1,
        examType: 'monthly',
        title: '月度考试',
        questionCount: 50,
        status: 'finished',
      );
      final map = exam.toMap();
      expect(map['id'], 1);
      expect(map['examType'], 'monthly');
      expect(map['title'], '月度考试');
      expect(map['questionCount'], 50);
      expect(map['status'], 'finished');
    });

    test('fromMap → toMap roundtrip', () {
      final original = Exam(
        id: 3,
        examType: 'yearly',
        title: '年度考试',
        totalScore: 100.0,
        obtainedScore: 92.5,
        status: 'finished',
        createdAt: '2026-05-30',
      );
      final map = original.toMap();
      final restored = Exam.fromMap(map);
      expect(restored.id, original.id);
      expect(restored.examType, original.examType);
      expect(restored.title, original.title);
      expect(restored.totalScore, original.totalScore);
      expect(restored.obtainedScore, original.obtainedScore);
    });

    test('copyWith creates new instance with overrides', () {
      final exam = Exam(id: 1, examType: 'daily', status: 'in_progress');
      final finished = exam.copyWith(
        status: 'finished',
        obtainedScore: 88.0,
        finishedAt: '2026-05-30T10:00:00',
      );
      expect(finished.status, 'finished');
      expect(finished.obtainedScore, 88.0);
      expect(finished.finishedAt, '2026-05-30T10:00:00');
      expect(finished.id, exam.id); // unchanged
      expect(finished.examType, exam.examType); // unchanged
    });
  });
}
