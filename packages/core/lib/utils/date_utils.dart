import 'package:intl/intl.dart';

/// 日期格式化工具类。
class DateUtils {
  DateUtils._();

  static final DateFormat _fullFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeFormat = DateFormat('HH:mm:ss');
  static final DateFormat _monthFormat = DateFormat('yyyy-MM');
  static final DateFormat _friendlyFormat = DateFormat('MM月dd日 HH:mm');

  /// 格式化为完整日期时间字符串：2026-05-30 14:30:00
  static String formatFull(DateTime dateTime) {
    return _fullFormat.format(dateTime);
  }

  /// 格式化为日期字符串：2026-05-30
  static String formatDate(DateTime dateTime) {
    return _dateFormat.format(dateTime);
  }

  /// 格式化为时间字符串：14:30:00
  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  /// 格式化为月份字符串：2026-05
  static String formatMonth(DateTime dateTime) {
    return _monthFormat.format(dateTime);
  }

  /// 格式化为友好格式：05月30日 14:30
  static String formatFriendly(DateTime dateTime) {
    return _friendlyFormat.format(dateTime);
  }

  /// 格式化为相对时间描述。
  ///
  /// - 今天：今天 HH:mm
  /// - 昨天：昨天 HH:mm
  /// - 今年：MM月dd日 HH:mm
  /// - 其他：yyyy年MM月dd日
  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (date == today) {
      return '今天 ${DateFormat('HH:mm').format(dateTime)}';
    } else if (date == today.subtract(const Duration(days: 1))) {
      return '昨天 ${DateFormat('HH:mm').format(dateTime)}';
    } else if (dateTime.year == now.year) {
      return DateFormat('MM月dd日 HH:mm').format(dateTime);
    } else {
      return DateFormat('yyyy年MM月dd日').format(dateTime);
    }
  }

  /// 格式化时长（秒）为可读字符串。
  ///
  /// - < 60秒：X秒
  /// - < 60分钟：X分Y秒
  /// - >= 60分钟：X小时Y分
  static String formatDuration(int seconds) {
    if (seconds < 60) {
      return '$seconds秒';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      final secs = seconds % 60;
      return '$minutes分$secs秒';
    } else {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return '$hours小时$minutes分';
    }
  }
}
