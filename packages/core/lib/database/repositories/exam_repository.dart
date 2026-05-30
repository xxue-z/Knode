import '../dao/exam_dao.dart';
import '../dao/exam_answer_dao.dart';
import '../dao/question_dao.dart';
import '../dao/wrong_question_dao.dart';
import '../../models/exam.dart';
import '../../models/exam_answer.dart';
import '../../models/question.dart';
import '../../../../lib/ai/agents/grader_agent.dart';

/// 考试业务仓库，编排考试全流程。
class ExamRepository {
  final ExamDao _examDao;
  final ExamAnswerDao _answerDao;
  final QuestionDao _questionDao;
  final WrongQuestionDao _wrongDao;
  final GraderAgent? _graderAgent;

  ExamRepository({
    required ExamDao examDao,
    required ExamAnswerDao answerDao,
    required QuestionDao questionDao,
    required WrongQuestionDao wrongDao,
    GraderAgent? graderAgent,
  })  : _examDao = examDao,
        _answerDao = answerDao,
        _questionDao = questionDao,
        _wrongDao = wrongDao,
        _graderAgent = graderAgent;

  Future<List<Exam>> getAll({String? examType, int limit = 50}) =>
      _examDao.getAll(examType: examType, limit: limit);

  Future<Exam?> getById(int id) => _examDao.getById(id);

  Future<List<ExamAnswer>> getAnswers(int examId) => _answerDao.getByExam(examId);

  /// 创建每日一测。
  Future<Exam> createDailyQuiz({int questionCount = 10}) async {
    final questions = await _questionDao.getRandom(limit: questionCount);
    return _createExamWithQuestions(
      examType: 'daily',
      title: '每日一测',
      questions: questions,
    );
  }

  /// 创建随机速记。
  Future<Exam> createRandomQuiz({int questionCount = 10}) async {
    final questions = await _questionDao.getRandom(limit: questionCount);
    return _createExamWithQuestions(
      examType: 'random',
      title: '随机速记',
      questions: questions,
    );
  }

  /// 创建温故知新（混合错题和新题）。
  Future<Exam> createReviewQuiz({double wrongRatio = 0.5, int questionCount = 10}) async {
    final wrongCount = (questionCount * wrongRatio).round();
    final newCount = questionCount - wrongCount;
    final wrongQuestions = await _questionDao.getWrongQuestions(limit: wrongCount);
    final newQuestions = await _questionDao.getRandom(limit: newCount);
    final allQuestions = [...wrongQuestions, ...newQuestions]..shuffle();
    return _createExamWithQuestions(
      examType: 'review',
      title: '温故知新',
      questions: allQuestions,
    );
  }

  /// 创建月度考试。
  Future<Exam> createMonthlyExam({int questionCount = 50}) async {
    final questions = await _questionDao.getRandom(limit: questionCount);
    return _createExamWithQuestions(
      examType: 'monthly',
      title: '月度考试',
      questions: questions,
      timeLimit: questionCount * 60, // 每题 1 分钟
    );
  }

  /// 创建季度考试。
  Future<Exam> createQuarterlyExam({int questionCount = 60}) async {
    final questions = await _questionDao.getRandom(limit: questionCount);
    return _createExamWithQuestions(
      examType: 'quarterly',
      title: '季度考试',
      questions: questions,
      timeLimit: questionCount * 60,
    );
  }

  /// 创建年度考试。
  Future<Exam> createYearlyExam({int questionCount = 80}) async {
    final questions = await _questionDao.getRandom(limit: questionCount);
    return _createExamWithQuestions(
      examType: 'yearly',
      title: '年度考试',
      questions: questions,
      timeLimit: questionCount * 60,
    );
  }

  /// 提交单题答案。
  Future<void> submitAnswer(int examId, int questionId, String userAnswer) async {
    // 客观题自动判分
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

    // 如果答错，记录到错题本
    if (isCorrect == 0) {
      await _wrongDao.upsert(questionId);
    }
  }

  /// 完成考试，AI 阅卷简答题并返回结果。
  Future<ExamResult> finishExam(int examId) async {
    final exam = await _examDao.getById(examId);
    if (exam == null) throw Exception('考试不存在: $examId');

    final answers = await _answerDao.getByExam(examId);
    double totalScore = 0;
    final gradedAnswers = <ExamAnswer>[];

    for (final answer in answers) {
      if (answer.score != null) {
        // 已评分（客观题）
        totalScore += answer.score!;
        gradedAnswers.add(answer);
      } else if (_graderAgent != null) {
        // 简答题 AI 阅卷
        final question = (await _questionDao.getByIds([answer.questionId])).firstOrNull;
        if (question != null) {
          final gradeResult = await _graderAgent.grade(
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

          // 答错记录到错题本
          if (graded.isCorrect == 0) {
            await _wrongDao.upsert(answer.questionId);
          }
        }
      }
    }

    // 批量更新答案分数
    await _answerDao.batchUpdateScores(examId, gradedAnswers);

    // 更新考试状态
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
