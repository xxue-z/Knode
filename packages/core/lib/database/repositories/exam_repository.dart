import 'dart:async';

import '../dao/exam_dao.dart';
import '../dao/exam_answer_dao.dart';
import '../dao/question_dao.dart';
import '../dao/wrong_question_dao.dart';
import '../dao/reading_log_dao.dart';
import '../dao/document_dao.dart';
import '../../models/exam.dart';
import '../../models/exam_answer.dart';
import '../../models/question.dart';
import 'package:core/gen/strings.dart';

const _strings = L10nStringsMixin();

/// 评分结果。
class GradeResult {
  final double score;
  final String feedback;
  const GradeResult({required this.score, required this.feedback});
}

/// 评分函数类型，由外部注入。
typedef GradeFunction = Future<GradeResult> Function({
  required String question,
  required String referenceAnswer,
  required String userAnswer,
});

/// 题目混合函数类型，由外部注入。
typedef MixQuestionsFunction = Future<List<Question>> Function({
  required List<int> docIds,
  required int totalCount,
  double? aiRatio,
  int wrongCount,
  int totalQuestionCount,
  int totalReadingMinutes,
  bool enableVariant,
});

/// 考试业务仓库，编排考试全流程。
class ExamRepository {
  final ExamDao _examDao;
  final ExamAnswerDao _answerDao;
  final QuestionDao _questionDao;
  final WrongQuestionDao _wrongDao;
  final ReadingLogDao _readingLogDao;
  final DocumentDao _documentDao;
  final GradeFunction? _gradeFn;
  final MixQuestionsFunction? _mixFn;

  ExamRepository({
    required ExamDao examDao,
    required ExamAnswerDao answerDao,
    required QuestionDao questionDao,
    required WrongQuestionDao wrongDao,
    required ReadingLogDao readingLogDao,
    required DocumentDao documentDao,
    GradeFunction? gradeFn,
    MixQuestionsFunction? mixFn,
  })  : _examDao = examDao,
        _answerDao = answerDao,
        _questionDao = questionDao,
        _wrongDao = wrongDao,
        _readingLogDao = readingLogDao,
        _documentDao = documentDao,
        _gradeFn = gradeFn,
        _mixFn = mixFn;

  Future<List<Exam>> getAll({String? examType, int limit = 50}) =>
      _examDao.getAll(examType: examType, limit: limit);

  /// 直接插入已有考试对象，返回自增 ID。
  Future<int> createExam(Exam exam) => _examDao.insert(exam);

  Future<Exam?> getById(int id) => _examDao.getById(id);

  Future<List<ExamAnswer>> getAnswers(int examId) => _answerDao.getByExam(examId);

  /// 创建每日一测（根据 daily_task_config 配置范围）。
  Future<Exam> createDailyQuiz({
    int questionCount = 10,
    String scopeType = 'all',
    String? scopeValue,
  }) async {
    final docIds = await _resolveDocIds(scopeType, scopeValue);
    final wrongCount = (await _wrongDao.getAll()).length;
    final totalQuestions = await _questionDao.getRandom(limit: 1);
    final totalQ = totalQuestions.isEmpty ? 0 : 999; // 粗略估计

    final questions = _mixFn != null
        ? await _mixFn!(
            docIds: docIds,
            totalCount: questionCount,
            wrongCount: wrongCount,
            totalQuestionCount: totalQ,
          )
        : await _questionDao.getRandom(limit: questionCount);

    return _createExamWithQuestions(
      examType: 'daily',
      title: _strings.core_daily_quiz,
      questions: questions,
    );
  }

  /// 创建随机速记（从最近 N 天阅读的文件出题）。
  Future<Exam> createRandomQuiz({
    int questionCount = 10,
    int recentDays = 7,
  }) async {
    final docIds = await _readingLogDao.getRecentlyReadDocIds(days: recentDays);
    final wrongCount = (await _wrongDao.getAll()).length;

    final questions = _mixFn != null && docIds.isNotEmpty
        ? await _mixFn!(
            docIds: docIds,
            totalCount: questionCount,
            wrongCount: wrongCount,
            totalQuestionCount: 999,
          )
        : await _questionDao.getRandom(limit: questionCount);

    return _createExamWithQuestions(
      examType: 'random',
      title: _strings.core_random_quick_review,
      questions: questions,
    );
  }

  /// 创建温故知新（混合错题和同知识点新题）。
  Future<Exam> createReviewQuiz({
    double wrongRatio = 0.5,
    int questionCount = 10,
  }) async {
    final wrongCount = (questionCount * wrongRatio).round();
    final newCount = questionCount - wrongCount;
    final wrongQuestions = await _questionDao.getWrongQuestions(limit: wrongCount);

    // 获取错题的标签，用于匹配同知识点新题
    final wrongTags = wrongQuestions
        .where((q) => q.tags != null)
        .expand((q) => q.tags!.split(','))
        .toSet();

    List<Question> newQuestions = [];
    if (wrongTags.isNotEmpty && newCount > 0) {
      for (final tag in wrongTags) {
        final tagQuestions = await _questionDao.getByTag(tag, limit: newCount);
        newQuestions.addAll(tagQuestions);
      }
      newQuestions = newQuestions.toSet().toList()..shuffle();
      newQuestions = newQuestions.take(newCount).toList();
    }
    if (newQuestions.length < newCount) {
      final extra = await _questionDao.getRandom(limit: newCount - newQuestions.length);
      newQuestions = [...newQuestions, ...extra];
    }

    final allQuestions = [...wrongQuestions, ...newQuestions]..shuffle();
    return _createExamWithQuestions(
      examType: 'review',
      title: _strings.core_wrong_question_review,
      questions: allQuestions.take(questionCount).toList(),
    );
  }

  /// 创建月度考试（使用本月更新的文档）。
  Future<Exam> createMonthlyExam({int questionCount = 50}) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    return _createPeriodicExam(
      examType: 'monthly',
      title: _strings.core_monthly_exam_2,
      questionCount: questionCount,
      startDate: start,
      endDate: now,
    );
  }

  /// 创建季度考试（使用本季度活跃文档）。
  Future<Exam> createQuarterlyExam({int questionCount = 60}) async {
    final now = DateTime.now();
    final quarter = ((now.month - 1) ~/ 3);
    final start = DateTime(now.year, quarter * 3 + 1, 1);
    return _createPeriodicExam(
      examType: 'quarterly',
      title: _strings.core_quarterly_exam_2,
      questionCount: questionCount,
      startDate: start,
      endDate: now,
    );
  }

  /// 创建年度考试（使用全年活跃文档）。
  Future<Exam> createYearlyExam({int questionCount = 80}) async {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    return _createPeriodicExam(
      examType: 'yearly',
      title: _strings.core_yearly_exam_2,
      questionCount: questionCount,
      startDate: start,
      endDate: now,
    );
  }

  /// 内部方法：创建阶段性考试。
  Future<Exam> _createPeriodicExam({
    required String examType,
    required String title,
    required int questionCount,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // 获取时间范围内的题目
    final questions = await _questionDao.getByDateRange(startDate, endDate);
    final docIds = questions
        .where((q) => q.sourceFileIds != null)
        .expand((q) => q.sourceFileIds!.split(','))
        .map((s) => int.tryParse(s.trim()))
        .where((id) => id != null)
        .cast<int>()
        .toSet()
        .toList();

    final wrongCount = (await _wrongDao.getAll()).length;

    List<Question> finalQuestions;
    if (_mixFn != null && docIds.isNotEmpty) {
      finalQuestions = await _mixFn!(
        docIds: docIds,
        totalCount: questionCount,
        wrongCount: wrongCount,
        totalQuestionCount: questions.length,
      );
    } else if (questions.length >= questionCount) {
      finalQuestions = (questions..shuffle()).take(questionCount).toList();
    } else {
      final extra = await _questionDao.getRandom(limit: questionCount - questions.length);
      finalQuestions = [...questions, ...extra];
    }

    return _createExamWithQuestions(
      examType: examType,
      title: title,
      questions: finalQuestions,
      timeLimit: questionCount * 60,
    );
  }

  /// 根据 scope_type 和 scope_value 解析文档 ID 列表。
  Future<List<int>> _resolveDocIds(String scopeType, String? scopeValue) async {
    switch (scopeType) {
      case 'category':
        if (scopeValue != null) {
          final catId = int.tryParse(scopeValue);
          if (catId != null) {
            final docs = await _documentDao.getByCategory(catId);
            return docs.map((d) => d.id).toList();
          }
        }
        return [];
      case 'days':
        final days = int.tryParse(scopeValue ?? '7') ?? 7;
        return await _readingLogDao.getRecentlyReadDocIds(days: days);
      case 'all':
      default:
        return [];
    }
  }

  /// 提交单题答案。
  Future<void> submitAnswer(int examId, int questionId, String userAnswer) async {
    final question = (await _questionDao.getByIds([questionId])).firstOrNull;
    int? isCorrect;
    double? score;

    if (question != null && _isObjective(question.type)) {
      isCorrect = question.answer.trim() == userAnswer.trim() ? 1 : 0;
      score = isCorrect == 1 ? 1.0 : 0.0;
    }

    final answer = ExamAnswer(
      id: 0,
      examId: examId,
      questionId: questionId,
      userAnswer: userAnswer,
      isCorrect: isCorrect,
      score: score,
    );
    await _answerDao.insert(answer);

    if (isCorrect == 0) {
      await _wrongDao.upsert(questionId);
    }
  }

  /// 完成考试，AI 阅卷简答题并返回结果。
  Future<ExamResult> finishExam(int examId) async {
    final exam = await _examDao.getById(examId);
    if (exam == null) throw Exception('${_strings.core_exam_not_found}: $examId');

    final answers = await _answerDao.getByExam(examId);
    double totalScore = 0;
    final gradedAnswers = <ExamAnswer>[];

    for (final answer in answers) {
      if (answer.score != null) {
        totalScore += answer.score!;
        gradedAnswers.add(answer);
      } else if (_gradeFn != null) {
        final question = (await _questionDao.getByIds([answer.questionId])).firstOrNull;
        if (question != null) {
          final gradeResult = await _gradeFn(
            question: question.stem,
            referenceAnswer: question.answer,
            userAnswer: answer.userAnswer ?? '',
          );
          final graded = answer.copyWith(
            score: gradeResult.score / 100,
            isCorrect: gradeResult.score >= 60 ? 1 : 0,
            aiFeedback: gradeResult.feedback,
          );
          totalScore += graded.score ?? 0;
          gradedAnswers.add(graded);
          await _answerDao.update(graded);
          if (graded.isCorrect == 0) {
            await _wrongDao.upsert(answer.questionId);
          }
        }
      }
    }

    await _answerDao.batchUpdateScores(examId, gradedAnswers);
    final finalScore = totalScore / answers.length * 100;
    await _examDao.updateScore(examId, finalScore, 'completed');

    return ExamResult(
      examId: examId,
      totalScore: finalScore,
      questionCount: answers.length,
      correctCount: gradedAnswers.where((a) => a.isCorrect == 1).length,
    );
  }

  /// 内部方法：创建考试并关联题目。
  Future<Exam> _createExamWithQuestions({
    required String examType,
    required String title,
    required List<Question> questions,
    int? timeLimit,
  }) async {
    final exam = Exam(
      id: 0,
      title: title,
      examType: examType,
      questionCount: questions.length,
      totalScore: questions.length.toDouble(),
      timeLimit: timeLimit,
      status: 'ongoing',
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    final examId = await _examDao.insert(exam);
    return exam.copyWith(id: examId);
  }

  bool _isObjective(String type) {
    return type == 'single_choice' ||
        type == 'multi_choice' ||
        type == 'true_false' ||
        type == 'fill_blank';
  }
}

/// 考试结果。
class ExamResult {
  final int examId;
  final double totalScore;
  final int questionCount;
  final int correctCount;
  const ExamResult({
    required this.examId,
    required this.totalScore,
    required this.questionCount,
    required this.correctCount,
  });
}
