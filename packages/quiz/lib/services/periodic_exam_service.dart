import 'package:quiz/agents/quiz_agent.dart';
import 'package:quiz/services/question_mixer.dart';
import 'package:quiz/gen/strings.dart';
import 'package:core/database/repositories/exam_repository.dart';
import 'package:core/database/repositories/question_repository.dart';
import 'package:core/database/dao/question_dao.dart';
import 'package:core/database/dao/reading_log_dao.dart';
import 'package:core/database/dao/wrong_question_dao.dart';
import 'package:core/models/exam.dart';
import 'package:core/services/notification_service.dart';
import 'package:core/services/background_service.dart';

const _strings = L10nStringsMixin();

/// 阶段考试预生成服务。
///
/// 使用 workmanager 在月考/季考/年考前一天晚间触发，
/// 生成 50-80 题并发送通知。
class PeriodicExamService {
  final QuizAgent _quizAgent;
  final ExamRepository _examRepo;
  final QuestionRepository _questionRepo;
  final QuestionDao _questionDao;
  final ReadingLogDao _readingLogDao;
  final WrongQuestionDao _wrongDao;
  final NotificationService _notificationService;
  final BackgroundService _backgroundService;
  final QuestionMixer? _mixer;

  PeriodicExamService({
    required QuizAgent quizAgent,
    required ExamRepository examRepo,
    required QuestionRepository questionRepo,
    required QuestionDao questionDao,
    required ReadingLogDao readingLogDao,
    required WrongQuestionDao wrongDao,
    required NotificationService notificationService,
    required BackgroundService backgroundService,
    QuestionMixer? mixer,
  })  : _quizAgent = quizAgent,
        _examRepo = examRepo,
        _questionRepo = questionRepo,
        _questionDao = questionDao,
        _readingLogDao = readingLogDao,
        _wrongDao = wrongDao,
        _notificationService = notificationService,
        _backgroundService = backgroundService,
        _mixer = mixer;

  /// 创建阶段考试。
  ///
  /// 根据考试类型确定出题范围和数量。
  Future<Exam> createExam({
    required String examType,
    required String title,
    int minQuestions = 50,
    int maxQuestions = 80,
  }) async {
    // 根据考试类型确定时间范围
    final now = DateTime.now();
    DateTime startDate;
    switch (examType) {
      case 'monthly':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'quarterly':
        final quarter = ((now.month - 1) ~/ 3);
        startDate = DateTime(now.year, quarter * 3 + 1, 1);
        break;
      case 'yearly':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = now.subtract(const Duration(days: 30));
    }

    // 获取时间范围内的题目
    final questions = await _questionDao.getByDateRange(startDate, now);
    final actualCount = questions.length.clamp(minQuestions, maxQuestions);

    final selectedQuestions = questions.length > actualCount
        ? (questions..shuffle()).take(actualCount).toList()
        : questions;

    final exam = Exam(
      id: 0,
      title: title,
      examType: examType,
      questionCount: selectedQuestions.length,
      totalScore: selectedQuestions.length.toDouble(),
      timeLimit: selectedQuestions.length * 60,
      status: 'pending',
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    final examId = await _examRepo.createExam(exam);

    await _notificationService.showNotification(
      title: _strings.quiz_exam_generated,
      body: '$title ${_strings.quiz_ready_with_n_questions(count: selectedQuestions.length.toString())}',
      id: examId,
    );

    return exam.copyWith(id: examId);
  }

  /// 创建月度考试。
  Future<Exam> createMonthlyExam() =>
      createExam(examType: 'monthly', title: _strings.quiz_monthly_exam_2);

  /// 创建季度考试。
  Future<Exam> createQuarterlyExam() =>
      createExam(examType: 'quarterly', title: _strings.quiz_quarterly_exam_2);

  /// 创建年度考试。
  Future<Exam> createYearlyExam() =>
      createExam(examType: 'yearly', title: _strings.quiz_yearly_exam_2);

  /// 注册阶段考试的定时任务。
  ///
  /// 在考前一天晚间（默认 21:00）触发预生成。
  Future<void> scheduleExamReminder({
    required String examType,
    required DateTime examDate,
    int hour = 21,
    int minute = 0,
  }) async {
    final triggerTime = DateTime(
      examDate.year,
      examDate.month,
      examDate.day - 1,
      hour,
      minute,
    );

    await _backgroundService.schedulePeriodicExam(
      triggerTime: triggerTime,
      examType: examType,
    );
  }

  /// 检查是否有未完成的阶段考试（用于补考入口）。
  Future<Exam?> getLatestPendingExam(String examType) async {
    final exams = await _examRepo.getAll(examType: examType, limit: 5);
    for (final exam in exams) {
      if (exam.status == 'pending') return exam;
    }
    return null;
  }

  /// 获取阶段考试历史。
  Future<List<Exam>> getExamHistory(String examType, {int limit = 20}) async {
    return await _examRepo.getAll(examType: examType, limit: limit);
  }

  void dispose() {}
}
