import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:core/models/local_model.dart';
import 'package:core/utils/device_utils.dart';

class DownloadProgress {
  final double percent;
  final int receivedBytes;
  final int totalBytes;
  const DownloadProgress({required this.percent, required this.receivedBytes, required this.totalBytes});
}

/// 模型下载服务，支持断点续传、多镜像下载、SHA256 校验、导入本地模型。
class ModelDownloadService {
  final Dio _dio = Dio();
  final String _modelsDir;

  /// 模型存储目录路径。
  String get modelsDir => _modelsDir;
  CancelToken? _currentCancelToken;
  StreamController<DownloadProgress>? _progressController;

  ModelDownloadService(this._modelsDir);

  Stream<DownloadProgress> get downloadProgress => _progressController?.stream ?? const Stream.empty();

  /// 按镜像下载模型，使用 .download 临时文件，下载完成后 SHA256 校验。
  Future<void> downloadWithMirror(LocalModel model, String mirrorKey) async {
    final url = model.downloadUrls[mirrorKey];
    if (url == null || url.isEmpty) {
      throw StateError('镜像 "$mirrorKey" 不存在');
    }

    final dir = Directory(_modelsDir);
    if (!await dir.exists()) await dir.create(recursive: true);

    final tempPath = p.join(_modelsDir, '${model.id}.gguf.download');
    final finalPath = p.join(_modelsDir, '${model.id}.gguf');
    final tempFile = File(tempPath);

    // 断点续传：检测临时文件
    int startByte = 0;
    if (await tempFile.exists()) {
      startByte = await tempFile.length();
    }

    _currentCancelToken = CancelToken();
    _progressController = StreamController<DownloadProgress>.broadcast();

    try {
      await _dio.download(
        url,
        tempPath,
        cancelToken: _currentCancelToken,
        options: Options(headers: {'Range': 'bytes=$startByte-'}),
        onReceiveProgress: (received, total) {
          final totalSize = startByte + total;
          final percent = totalSize > 0 ? (startByte + received) / totalSize : 0.0;
          _progressController?.add(DownloadProgress(
            percent: percent,
            receivedBytes: startByte + received,
            totalBytes: totalSize,
          ));
        },
      );

      // SHA256 校验
      if (model.sha256.isNotEmpty) {
        final valid = await verifySha256(tempPath, model.sha256);
        if (!valid) {
          await tempFile.delete();
          throw StateError('文件校验失败，请重新下载');
        }
      }

      // 校验通过，重命名为正式文件
      final finalFile = File(finalPath);
      if (await finalFile.exists()) await finalFile.delete();
      await tempFile.rename(finalPath);
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        return;
      }
      rethrow;
    } finally {
      _currentCancelToken = null;
      await _progressController?.close();
    }
  }

  /// 计算文件 SHA256 并与期望值比对。
  Future<bool> verifySha256(String filePath, String expectedHash) async {
    if (expectedHash.isEmpty) return true; // 无 hash 跳过校验
    final file = File(filePath);
    if (!await file.exists()) return false;
    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes);
    return digest.toString() == expectedHash.toLowerCase();
  }

  /// 导入本地 .gguf 文件到 models 目录。
  ///
  /// 返回导入后的文件名（不含扩展名）。
  Future<String> importLocalModel(String sourcePath) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw StateError('源文件不存在: $sourcePath');
    }
    if (!sourcePath.toLowerCase().endsWith('.gguf')) {
      throw StateError('仅支持 .gguf 格式文件');
    }

    final dir = Directory(_modelsDir);
    if (!await dir.exists()) await dir.create(recursive: true);

    final fileName = p.basename(sourcePath);
    final targetPath = p.join(_modelsDir, fileName);
    final targetFile = File(targetPath);

    if (await targetFile.exists()) {
      await targetFile.delete();
    }

    await sourceFile.copy(targetPath);
    return p.basenameWithoutExtension(fileName);
  }

  void cancelDownload() {
    _currentCancelToken?.cancel();
  }

  Future<void> deleteModel(String id) async {
    final file = File(p.join(_modelsDir, '$id.gguf'));
    if (await file.exists()) await file.delete();
    // 同时清理可能残留的临时文件
    final tempFile = File(p.join(_modelsDir, '$id.gguf.download'));
    if (await tempFile.exists()) await tempFile.delete();
  }

  Future<List<String>> getDownloadedModels() async {
    final dir = Directory(_modelsDir);
    if (!await dir.exists()) return [];
    return dir.listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.gguf') && !f.path.endsWith('.download'))
        .map((f) => p.basenameWithoutExtension(f.path))
        .toList();
  }

  /// 根据设备内存过滤模型列表。
  ///
  /// 规则：模型的 minRam 不超过设备总内存的 80%。
  /// 返回过滤后的列表；如果 [skipCheck] 为 true，直接返回原始列表。
  ///
  /// [models] 原始模型列表
  /// [totalMemoryGB] 设备总内存（GB）
  /// [skipCheck] 是否跳过检查
  static List<LocalModel> filterModelsByRam({
    required List<LocalModel> models,
    required double totalMemoryGB,
    bool skipCheck = false,
  }) {
    if (skipCheck || totalMemoryGB <= 0) return models;

    return models.where((model) {
      final requiredGB = DeviceUtils.parseRamString(model.minRam);
      if (requiredGB <= 0) return true;
      return requiredGB <= totalMemoryGB * 0.8;
    }).toList();
  }

  void dispose() {
    _currentCancelToken?.cancel();
    _dio.close(force: true);
  }
}
