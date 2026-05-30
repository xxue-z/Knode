import 'package:workmanager/workmanager.dart';
import 'notification_service.dart';

/// 后台任务服务，使用 workmanager 注册定时任务。
///
/// 包括每日一测预生成（提醒前 30 分钟）、阶段考试预生成。
class BackgroundService {
  static const _dailyQuizTask = 'knode_daily_quiz';
  static const _periodicExamTask = 'knode_periodic_exam';

  final NotificationService _notificationService;

  BackgroundService({required NotificationService notificationService})
      : _notificationService = notificationService;

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
      constraints: Constraints(networkType: NetworkType.not_required),
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
      constraints: Constraints(networkType: NetworkType.not_required),
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
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      switch (task) {
        case 'knode_daily_quiz':
          // 每日一测预生成：发送通知提醒用户
          final notificationService = NotificationService();
          await notificationService.init();
          await notificationService.showNotification(
            title: '每日一测',
            body: '今日测验已准备好，点击开始答题',
          );
          return true;

        case 'knode_periodic_exam':
          // 阶段考试预生成：发送通知
          final examType = inputData?['examType'] ?? 'monthly';
          final notificationService = NotificationService();
          await notificationService.init();
          await notificationService.showNotification(
            title: '${examType}考试预生成完成',
            body: '点击开始答题',
          );
          return true;

        default:
          return true;
      }
    } catch (e) {
      return false;
    }
  });
}
