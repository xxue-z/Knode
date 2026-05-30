import 'dart:convert';
import 'package:shelf/shelf.dart' as shelf;
import 'package:core/database/repositories/question_repository.dart';
import 'package:core/database/repositories/exam_repository.dart';

/// 答题 API Handler，提供在线答题和提交答案接口。
class QuizHandler {
  final QuestionRepository _questionRepo;
  final ExamRepository _examRepo;

  QuizHandler({
    required QuestionRepository questionRepository,
    required ExamRepository examRepository,
  })  : _questionRepo = questionRepository,
        _examRepo = examRepository;

  /// 获取题目列表（随机抽取）。
  Future<Map<String, dynamic>> getQuestions(shelf.Request req) async {
    try {
      final url = req.requestedUri;
      final limit = int.tryParse(url.queryParameters['limit'] ?? '') ?? 10;

      final questions = await _questionRepo.getRandom(limit: limit);
      return {
        'questions': questions.map((q) => {
              'id': q.id,
              'type': q.type,
              'stem': q.stem,
              'options': q.options,
              'difficulty': q.difficulty,
            }).toList(),
      };
    } catch (e) {
      return {'error': '获取题目失败: $e', 'questions': []};
    }
  }

  /// 提交答案，支持 5 种题型的判分。
  ///
  /// 请求体：{ questionId: int, answer: string, examId?: int }
  /// 返回：{ isCorrect, correctAnswer, explanation, score }
  Future<Map<String, dynamic>> submitAnswer(shelf.Request req) async {
    try {
      final body = await req.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final questionId = data['questionId'] as int?;
      final userAnswer = data['answer'] as String? ?? '';
      final examId = data['examId'] as int?;

      if (questionId == null) {
        return {'error': '缺少 questionId'};
      }

      final questions = await _questionRepo.getByIds([questionId]);
      if (questions.isEmpty) return {'error': '题目不存在'};

      final q = questions.first;
      final result = _grade(q, userAnswer);

      // 如果有 examId，记录到考试答案
      if (examId != null) {
        await _examRepo.submitAnswer(examId, questionId, userAnswer);
      }

      return {
        'questionId': questionId,
        'isCorrect': result['isCorrect'],
        'correctAnswer': q.answer,
        'explanation': q.explanation,
        'score': result['score'],
      };
    } catch (e) {
      return {'error': '提交答案失败: $e'};
    }
  }

  /// 根据题型判分。
  Map<String, dynamic> _grade(dynamic question, String userAnswer) {
    final type = question.type as String;
    final correctAnswer = question.answer as String;

    switch (type) {
      case 'single_choice':
      case 'fill_blank':
        // 精确匹配（忽略大小写和首尾空格）
        final isCorrect = correctAnswer.trim().toLowerCase() == userAnswer.trim().toLowerCase();
        return {'isCorrect': isCorrect, 'score': isCorrect ? 1.0 : 0.0};

      case 'multi_choice':
        // 多选：答案排序后比较
        final correctSet = correctAnswer.split(',').map((s) => s.trim())..toList();
        final userSet = userAnswer.split(',').map((s) => s.trim())..toList();
        final correctSorted = correctSet.toList()..sort();
        final userSorted = userSet.toList()..sort();
        final isCorrect = correctSorted.join(',') == userSorted.join(',');
        return {'isCorrect': isCorrect, 'score': isCorrect ? 1.0 : 0.0};

      case 'true_false':
        // 判断题：T/F 或 正确/错误
        final normalizedCorrect = _normalizeBool(correctAnswer);
        final normalizedUser = _normalizeBool(userAnswer);
        final isCorrect = normalizedCorrect == normalizedUser;
        return {'isCorrect': isCorrect, 'score': isCorrect ? 1.0 : 0.0};

      case 'short_answer':
        // 简答题：返回 null 表示需要 AI 阅卷
        return {'isCorrect': null, 'score': null};

      default:
        return {'isCorrect': false, 'score': 0.0};
    }
  }

  String _normalizeBool(String value) {
    final v = value.trim().toLowerCase();
    if (v == 't' || v == 'true' || v == '正确' || v == '对') return 'true';
    if (v == 'f' || v == 'false' || v == '错误' || v == '错') return 'false';
    return v;
  }
}
