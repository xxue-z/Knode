import 'dart:async';
import 'package:flutter/material.dart';

/// 倒计时组件，显示考试剩余时间。时间到自动调用 [onTimeUp]。
class TimerWidget extends StatefulWidget {
  const TimerWidget({
    super.key,
    required this.duration,
    this.onTimeUp,
    this.onTick,
  });

  /// 总时长（秒）。
  final int duration;

  /// 时间到回调。
  final VoidCallback? onTimeUp;

  /// 每秒回调，返回剩余秒数。
  final ValueChanged<int>? onTick;

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late Timer _timer;
  late int _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.duration;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining > 0) {
        setState(() => _remaining--);
        widget.onTick?.call(_remaining);
      }
      if (_remaining <= 0) {
        _timer.cancel();
        widget.onTimeUp?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _formatted {
    final m = (_remaining ~/ 60).toString().padLeft(2, '0');
    final s = (_remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color get _color {
    if (_remaining <= 60) return Colors.red;
    if (_remaining <= 300) return Colors.orange;
    return null ?? Colors.black87;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 18, color: _color),
          const SizedBox(width: 4),
          Text(
            _formatted,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}
