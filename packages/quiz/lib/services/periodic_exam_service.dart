import 'package:quiz/agents/quiz_agent.dart';
import 'package:quiz/gen/strings.dart';
import 'package:core/database/repositories/exam_repository.dart';
import 'package:core/database/repositories/question_repository.dart';

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
  final NotificationService _notificationService;
  final BackgroundService _backgroundService;

  PeriodicExamService({
    required QuizAgent quizAgent,
    required ExamRepository examRepo,
    required QuestionRepository questionRepo,
    required NotificationService notificationService,
    required BackgroundService backgroundService,
  })  : _quizAgent = quizAgent,
        _examRepo = examRepo,
        _questionRepo = questionRepo,
        _notificationService = notificationService,
        _backgroundService = backgroundService;

  /// 创建阶段考试。
  ///
  /// [minQuestions] 和 [maxQuestions] 控制题目数量范围，
  /// 实际数量由题库大小决定。
  Future<Exam> createExam({
    required String examType,
    required String title,
    int minQuestions = 50,
    int maxQuestions = 80,
  }) async {
    // 获取题目（不超过题库总量）
    final questions = await _questionRepo.getRandom(limit: maxQuestions);
    final actualCount = questions.length.clamp(minQuestions, maxQuestions);

    final exam = Exam(
      id: 0,
      title: title,
      examType: examType,
      questionCount: actualCount,
      totalScore: actualCount.toDouble(),
      timeLimit: actualCount * 60, // 每题 1 分钟
      status: 'pending',
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    final examId = await _examRepo.createExam(exam);

    await _notificationService.showNotification(
      title: _strings.quiz_exam_generated,
      body: '$title ${_strings.quiz_ready_with_n_questions(count: actualCount.toString())}',
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

  void dispose() {}
}
