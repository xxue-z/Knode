import 'package:workmanager/workmanager.dart';
import '../database/app_database.dart';
import '../database/dao/question_dao.dart';
import '../database/dao/exam_dao.dart';
import '../models/exam.dart';
import '../models/question.dart';
import '../gen/strings.dart';
import 'notification_service.dart';

const _strings = L10nStringsMixin();

/// 后台任务服务，使用 workmanager 注册定时任务。
///
/// 包括每日一测预生成（提醒前 30 分钟）、阶段考试预生成。
class BackgroundService {
  static const _dailyQuizTask = 'knode_daily_quiz';
  static const _periodicExamTask = 'knode_periodic_exam';


  BackgroundService();

  /// 初始化 workmanager。
  Future<void> init() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  /// 注册每日一测预生成任务。
  ///
  /// 在每天指定时间触发，生成题目并发送通知。
  Future<void> registerDailyQuizTask({
    required int hour,
    required int minute,
  }) async {
    final now = DateTime.now();
    var triggerTime = DateTime(now.year, now.month, now.day, hour, minute);
    if (triggerTime.isBefore(now)) {
      triggerTime = triggerTime.add(const Duration(days: 1));
    }

    await Workmanager().registerPeriodicTask(
      _dailyQuizTask,
      _dailyQuizTask,
      frequency: const Duration(days: 1),
      initialDelay: triggerTime.difference(now),
      constraints: Constraints(networkType: NetworkType.notRequired),
    );
  }

  /// 注册阶段考试预生成任务。
  ///
  /// 在指定时间触发，生成考试题目并发送通知。
  Future<void> schedulePeriodicExam({
    required DateTime triggerTime,
    required String examType,
  }) async {
    final delay = triggerTime.difference(DateTime.now());
    if (delay.isNegative) return;

    await Workmanager().registerOneOffTask(
      '${_periodicExamTask}_$examType',
      _periodicExamTask,
      initialDelay: delay,
      inputData: {'examType': examType},
      constraints: Constraints(networkType: NetworkType.notRequired),
    );
  }

  /// 取消所有后台任务。
  Future<void> cancelAll() async => await Workmanager().cancelAll();

  /// 取消每日一测任务。
  Future<void> cancelDailyQuiz() async =>
      await Workmanager().cancelByUniqueName(_dailyQuizTask);
}

/// 后台任务入口点。
///
/// 注意：此函数必须是顶层函数，不能是类方法。
/// workmanager 在独立 isolate 中执行此函数。
/// 由于在独立 isolate 中，不能使用 Riverpod，需直接初始化数据库和 DAO。
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // 初始化数据库
      await AppDatabase.instance.init();

      switch (task) {
        case 'knode_daily_quiz':
          return _handleDailyQuiz();

        case 'knode_periodic_exam':
          final examType = (inputData?['examType'] as String?) ?? 'monthly';
          return _handlePeriodicExam(examType);

        default:
          return true;
      }
    } catch (e) {
      return false;
    }
  });
}

/// 每日一测预生成：从题库随机抽取题目，创建考试记录，发送通知。
Future<bool> _handleDailyQuiz() async {
  final questionDao = QuestionDao();
  final examDao = ExamDao();

  // 从题库随机抽取 10 题
  final questions = await questionDao.getRandom(limit: 10);
  if (questions.isEmpty) return true;

  // 创建考试记录
  final exam = Exam(
    id: 0,
    title: _strings.core_daily_quiz,
    examType: 'daily',
    questionCount: questions.length,
    totalScore: questions.length.toDouble(),
    status: 'pending',
    createdAt: DateTime.now().toIso8601String(),
    updatedAt: DateTime.now().toIso8601String(),
  );
  final examId = await examDao.insert(exam);

  // 发送通知
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.showNotification(
    id: examId,
    title: _strings.core_daily_quiz,
    body: _strings.core_today_quiz_ready,
  );
  return true;
}

/// 阶段考试预生成：按时间范围获取题目，创建考试记录，发送通知。
Future<bool> _handlePeriodicExam(String examType) async {
  final questionDao = QuestionDao();
  final examDao = ExamDao();

  // 根据考试类型确定题目数量和时间范围
  final now = DateTime.now();
  int questionCount;
  DateTime startDate;
  String title;

  switch (examType) {
    case 'monthly':
      questionCount = 50;
      startDate = DateTime(now.year, now.month, 1);
      title = _strings.core_monthly_exam_2;
      break;
    case 'quarterly':
      questionCount = 60;
      final quarter = ((now.month - 1) ~/ 3);
      startDate = DateTime(now.year, quarter * 3 + 1, 1);
      title = _strings.core_quarterly_exam_2;
      break;
    case 'yearly':
      questionCount = 80;
      startDate = DateTime(now.year, 1, 1);
      title = _strings.core_yearly_exam_2;
      break;
    default:
      questionCount = 50;
      startDate = now.subtract(const Duration(days: 30));
      title = _strings.core_monthly_exam_2;
  }

  // 按时间范围获取题目
  final dateRangeQuestions = await questionDao.getByDateRange(startDate, now);

  List<Question> questions;
  if (dateRangeQuestions.length >= questionCount) {
    questions = (dateRangeQuestions..shuffle()).take(questionCount).toList();
  } else {
    // 不足时从全题库补充
    final extra = await questionDao.getRandom(limit: questionCount - dateRangeQuestions.length);
    questions = [...dateRangeQuestions, ...extra];
  }

  if (questions.isEmpty) return true;

  // 创建考试记录
  final exam = Exam(
    id: 0,
    title: title,
    examType: examType,
    questionCount: questions.length,
    totalScore: questions.length.toDouble(),
    timeLimit: questions.length * 60,
    status: 'pending',
    createdAt: now.toIso8601String(),
    updatedAt: now.toIso8601String(),
  );
  final examId = await examDao.insert(exam);

  // 发送通知
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.showNotification(
    id: examId,
    title: title,
    body: _strings.core_tap_to_start_answering,
  );
  return true;
}
