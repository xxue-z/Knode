import 'package:sqflite/sqflite.dart';
import '../app_database.dart';
import '../tables/exam_answer_table.dart';
import '../../models/exam_answer.dart';

class ExamAnswerDao {
  Database get _db => AppDatabase.instance.db;

  static ExamAnswer _fromRow(Map<String, dynamic> r) => ExamAnswer(
    id: r['id'] as int, examId: r['exam_id'] as int, questionId: r['question_id'] as int,
    userAnswer: r['user_answer'] as String?, isCorrect: r['is_correct'] as int,
    score: r['score'] as double?, feedback: r['feedback'] as String?,
    createdAt: r['created_at'] as String,
  );

  static Map<String, dynamic> _toRow(ExamAnswer a) => {
    'exam_id': a.examId, 'question_id': a.questionId, 'user_answer': a.userAnswer,
    'is_correct': a.isCorrect, 'score': a.score, 'feedback': a.feedback, 'created_at': a.createdAt,
  };

  Future<List<ExamAnswer>> getByExam(int examId) async {
    final rows = await _db.query(ExamAnswerTable.tableName, where: 'exam_id = ?', whereArgs: [examId]);
    return rows.map(_fromRow).toList();
  }

  Future<int> insert(ExamAnswer answer) async => await _db.insert(ExamAnswerTable.tableName, _toRow(answer));

  Future<void> update(ExamAnswer answer) async {
    await _db.update(ExamAnswerTable.tableName, _toRow(answer), where: 'id = ?', whereArgs: [answer.id]);
  }

  Future<void> batchUpdateScores(int examId, List<ExamAnswer> answers) async {
    await _db.transaction((txn) async {
      for (final a in answers) {
        await txn.update(ExamAnswerTable.tableName, _toRow(a), where: 'id = ?', whereArgs: [a.id]);
      }
    });
  }
}