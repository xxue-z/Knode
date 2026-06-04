import 'dart:async';
import 'package:flutter/material.dart';

/// 语音输入面板（长按悬浮球时显示）
class VoicePanel extends StatefulWidget {
  final VoidCallback onSend;
  final VoidCallback onCancel;

  const VoicePanel({
    super.key,
    required this.onSend,
    required this.onCancel,
  });

  @override
  State<VoicePanel> createState() => _VoicePanelState();
}

class _VoicePanelState extends State<VoicePanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _recordingSeconds = 0;
  Timer? _timer;
  bool _isCancelled = false;
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _startRecording();
  }

  void _startRecording() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingSeconds++;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = _recordingSeconds ~/ 60;
    final seconds = _recordingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          setState(() {
            _dragOffset += details.delta.dy;
            if (_dragOffset < -50) {
              _isCancelled = true;
            }
          });
        },
        onVerticalDragEnd: (_) {
          if (_isCancelled) {
            widget.onCancel();
          } else {
            widget.onSend();
          }
        },
        child: Center(
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Icon(
                    Icons.mic,
                    size: 48,
                    color: _isCancelled
                        ? Colors.red
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _formattedTime,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  _isCancelled ? '松手取消' : '上滑取消',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
