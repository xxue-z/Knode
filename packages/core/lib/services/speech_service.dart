import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  void Function(String text, bool isFinal)? onResult;
  void Function(bool isListening)? onStatusChanged;
  void Function(String error)? onError;

  bool get isListening => _isListening;

  Future<bool> init() async {
    if (_isInitialized) return true;
    try {
      _isInitialized = await _speech.initialize(
        onStatus: _onStatus,
        onError: (error) => onError?.call(error.errorMsg),
      );
      return _isInitialized;
    } catch (e) {
      onError?.call('语音初始化失败: $e');
      return false;
    }
  }

  Future<void> startListening() async {
    if (!_isInitialized) { final ok = await init(); if (!ok) return; }
    await _speech.listen(
      onResult: _onResult, localeId: 'zh_CN',
      listenMode: ListenMode.dictation, cancelOnError: false, partialResults: true,
    );
  }

  Future<void> stopListening() async { await _speech.stop(); }

  void _onResult(SpeechRecognitionResult result) => onResult?.call(result.recognizedWords, result.finalResult);
  void _onStatus(String status) { _isListening = status == 'listening'; onStatusChanged?.call(_isListening); }

  Future<void> dispose() async {
    await _speech.stop();
    onResult = null; onStatusChanged = null; onError = null;
  }
}