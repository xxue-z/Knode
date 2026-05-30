import 'package:sqflite/sqflite.dart';
import '../app_database.dart';
import '../tables/exam_table.dart';
import '../../models/exam.dart';

class ExamDao {
  Database get _db => AppDatabase.instance.db;

  static Exam _fromRow(Map<String, dynamic> r) => Exam(
    id: r['id'] as int, title: r['title'] as String?,
    examType: r['exam_type'] as String, questionCount: r['question_count'] as int,
    obtainedScore: r['obtained_score'] as double?, status: r['status'] as String,
    createdAt: r['created_at'] as String, updatedAt: r['updated_at'] as String,
  );

  static Map<String, dynamic> _toRow(Exam e) => {
    'title': e.title, 'exam_type': e.examType, 'question_count': e.questionCount,
    'obtained_score': e.obtainedScore, 'status': e.status,
    'created_at': e.createdAt, 'updated_at': e.updatedAt,
  };

  Future<List<Exam>> getAll({String? examType, int limit = 50}) async {
    final where = examType != null ? 'exam_type = ?' : null;
    final args = examType != null ? [examType] : null;
    final rows = await _db.query(ExamTable.tableName, where: where, whereArgs: args, orderBy: 'created_at DESC', limit: limit);
    return rows.map(_fromRow).toList();
  }

  Future<Exam?> getById(int id) async {
    final rows = await _db.query(ExamTable.tableName, where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : _fromRow(rows.first);
  }

  Future<int> insert(Exam exam) async => await _db.insert(ExamTable.tableName, _toRow(exam));

  Future<void> update(Exam exam) async {
    await _db.update(ExamTable.tableName, _toRow(exam), where: 'id = ?', whereArgs: [exam.id]);
  }

  Future<void> updateScore(int examId, double obtainedScore, String status) async {
    await _db.update(ExamTable.tableName, {
      'obtained_score': obtainedScore, 'status': status, 'updated_at': DateTime.now().toIso8601String(),
    }, where: 'id = ?', whereArgs: [examId]);
  }
}