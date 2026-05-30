import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../data/models/local_model.dart';

/// 远程模型仓库 JSON 拉取与本地缓存服务。
///
/// 从远程 URL 获取模型列表，缓存到本地文件。
/// 网络请求自动重试 3 次（指数退避 2/4/8 秒）。
class ModelRepoService {
  final Dio _dio;

  ModelRepoService() : _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  /// 从远程 URL 拉取模型列表 JSON。
  ///
  /// 成功后覆盖本地缓存；失败时尝试读取缓存，缓存也为空则抛异常。
  Future<List<LocalModel>> fetchModels(String url) async {
    try {
      final json = await _fetchWithRetry(url);
      final models = _parseModels(json);
      await _saveCache(json);
      return models;
    } catch (e) {
      // 网络失败，尝试读取缓存
      final cached = await getCachedModels();
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  /// 读取本地缓存的模型列表。
  Future<List<LocalModel>> getCachedModels() async {
    try {
      final file = await _cacheFile();
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      if (content.isEmpty) return [];
      final json = jsonDecode(content) as Map<String, dynamic>;
      return _parseModels(json);
    } catch (_) {
      return [];
    }
  }

  /// 带重试的 HTTP GET 请求（最多 3 次，指数退避）。
  Future<Map<String, dynamic>> _fetchWithRetry(String url) async {
    Exception? lastError;
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        final resp = await _dio.get(url);
        if (resp.statusCode == 200) {
          if (resp.data is String) {
            return jsonDecode(resp.data as String) as Map<String, dynamic>;
          }
          return resp.data as Map<String, dynamic>;
        }
        throw StateError('HTTP ${resp.statusCode}');
      } on DioException catch (e) {
        if (e.type == DioExceptionType.cancel) rethrow;
        lastError = StateError('请求失败: ${e.message}');
        if (attempt < 2) {
          await Future.delayed(Duration(seconds: (1 << (attempt + 1)))); // 2, 4
        }
      } catch (e) {
        lastError = StateError('请求失败: $e');
        if (attempt < 2) {
          await Future.delayed(Duration(seconds: (1 << (attempt + 1))));
        }
      }
    }
    throw lastError ?? StateError('请求失败');
  }

  /// 解析 JSON 为 LocalModel 列表。
  List<LocalModel> _parseModels(Map<String, dynamic> json) {
    final modelsJson = json['models'] as List? ?? [];
    return modelsJson
        .map((e) => LocalModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 保存 JSON 到本地缓存文件。
  Future<void> _saveCache(Map<String, dynamic> json) async {
    final file = await _cacheFile();
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(json));
  }

  /// 缓存文件路径：{appDocDir}/models_cache.json。
  Future<File> _cacheFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, 'models_cache.json'));
  }

  void dispose() {
    _dio.close(force: true);
  }
}
