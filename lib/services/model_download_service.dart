import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

class ModelInfo {
  final String name;
  final String url;
  final int sizeMB;
  final String description;
  const ModelInfo({required this.name, required this.url, required this.sizeMB, required this.description});
}

class DownloadProgress {
  final double percent;
  final int receivedBytes;
  final int totalBytes;
  const DownloadProgress({required this.percent, required this.receivedBytes, required this.totalBytes});
}

class ModelDownloadService {
  final Dio _dio = Dio();
  final String _modelsDir;
  CancelToken? _currentCancelToken;
  StreamController<DownloadProgress>? _progressController;

  static const List<ModelInfo> availableModels = [
    ModelInfo(name: 'qwen2-1.5b', url: 'https://example.com/qwen2-1.5b-q4.gguf', sizeMB: 900, description: 'Qwen2 1.5B 轻量模型'),
    ModelInfo(name: 'qwen2-3b', url: 'https://example.com/qwen2-3b-q4.gguf', sizeMB: 1800, description: 'Qwen2 3B 平衡模型'),
    ModelInfo(name: 'qwen2-7b', url: 'https://example.com/qwen2-7b-q4.gguf', sizeMB: 4000, description: 'Qwen2 7B 高性能模型'),
  ];

  ModelDownloadService(this._modelsDir);

  Stream<DownloadProgress> get downloadProgress => _progressController?.stream ?? const Stream.empty();

  Future<void> downloadModel(String url, String name) async {
    final dir = Directory(_modelsDir);
    if (!await dir.exists()) await dir.create(recursive: true);
    final filePath = p.join(_modelsDir, '$name.gguf');
    final file = File(filePath);
    int startByte = 0;
    if (await file.exists()) {
      startByte = await file.length();
    }
    _currentCancelToken = CancelToken();
    _progressController = StreamController<DownloadProgress>.broadcast();
    try {
      final resp = await _dio.download(url, filePath,
        cancelToken: _currentCancelToken,
        options: Options(headers: {'Range': 'bytes=$startByte-'}),
        onReceiveProgress: (received, total) {
          final totalSize = startByte + total;
          final percent = totalSize > 0 ? (startByte + received) / totalSize : 0.0;
          _progressController?.add(DownloadProgress(percent: percent, receivedBytes: startByte + received, totalBytes: totalSize));
        },
      );
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        return;
      }
      throw StateError('模型下载失败: $e');
    } finally {
      _currentCancelToken = null;
      await _progressController?.close();
    }
  }

  void cancelDownload() {
    _currentCancelToken?.cancel();
  }

  Future<void> deleteModel(String name) async {
    final file = File(p.join(_modelsDir, '$name.gguf'));
    if (await file.exists()) await file.delete();
  }

  Future<List<String>> getDownloadedModels() async {
    final dir = Directory(_modelsDir);
    if (!await dir.exists()) return [];
    return dir.listSync().whereType<File>().where((f) => f.path.endsWith('.gguf')).map((f) => p.basenameWithoutExtension(f.path)).toList();
  }

  void dispose() {
    _currentCancelToken?.cancel();
    _dio.close(force: true);
  }
}