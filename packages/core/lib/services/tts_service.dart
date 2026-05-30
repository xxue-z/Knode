import 'package:flutter_tts/flutter_tts.dart';

/// TTS 朗读服务，封装 flutter_tts。
///
/// 支持语速调节、暂停、继续。用于沉浸式阅读页的朗读功能。
class TtsService {
  final FlutterTts _tts = FlutterTts();

  bool _isInitialized = false;

  /// 内部朗读状态，通过回调同步跟踪。
  bool _isSpeaking = false;

  /// 缓存当前朗读文本，用于暂停后恢复。
  String _currentText = '';

  /// 朗读状态回调。
  void Function(bool isPlaying)? onPlayStateChanged;

  /// 朗读进度回调（0.0 ~ 1.0）。
  void Function(double progress)? onProgress;

  /// 初始化 TTS 引擎。
  Future<void> init() async {
    if (_isInitialized) return;
    await _tts.setLanguage('zh-CN');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() {
      _isSpeaking = true;
      onPlayStateChanged?.call(true);
    });

    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      _currentText = '';
      onPlayStateChanged?.call(false);
    });

    _tts.setCancelHandler(() {
      _isSpeaking = false;
      _currentText = '';
      onPlayStateChanged?.call(false);
    });

    _tts.setErrorHandler((dynamic message) {
      _isSpeaking = false;
      _currentText = '';
      onPlayStateChanged?.call(false);
    });

    _tts.setProgressHandler((String text, int start, int end, String word) {
      if (end > 0) {
        onProgress?.call(end / text.length);
      }
    });

    _isInitialized = true;
  }

  /// 朗读文本。
  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    _currentText = text;
    await _tts.speak(text);
  }

  /// 暂停朗读。
  Future<void> pause() async {
    await _tts.pause();
  }

  /// 继续朗读。
  ///
  /// 重新朗读缓存的文本（flutter_tts 不支持原生恢复）。
  Future<void> resume() async {
    if (_currentText.isNotEmpty) {
      await _tts.speak(_currentText);
    }
  }

  /// 停止朗读。
  Future<void> stop() async {
    _isSpeaking = false;
    _currentText = '';
    await _tts.stop();
    onPlayStateChanged?.call(false);
  }

  /// 设置语速（0.0 ~ 1.0）。
  Future<void> setSpeechRate(double rate) async {
    await _tts.setSpeechRate(rate.clamp(0.0, 1.0));
  }

  /// 设置语言。
  Future<void> setLanguage(String languageCode) async {
    await _tts.setLanguage(languageCode);
  }

  /// 当前是否正在朗读。
  bool get isSpeaking => _isSpeaking;

  /// 释放资源。
  Future<void> dispose() async {
    _isSpeaking = false;
    _currentText = '';
    await _tts.stop();
    onPlayStateChanged = null;
    onProgress = null;
  }
}
