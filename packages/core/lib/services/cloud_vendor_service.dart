import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:core/utils/json_utils.dart';
import 'package:core/models/cloud_vendor.dart';

/// 云端厂商 JSON 拉取与本地缓存服务。
///
/// 从远程 URL 获取云端服务商配置，缓存到本地文件。
/// 网络请求自动重试 3 次（指数退避 2/4/8 秒）。
class CloudVendorService {
  final Dio _dio;

  CloudVendorService() : _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  /// 从远程 URL 拉取云端厂商列表 JSON。
  ///
  /// 成功后覆盖本地缓存；失败时尝试读取缓存，缓存也为空则抛异常。
  Future<List<CloudVendor>> fetchVendors(String url) async {
    try {
      final json = await _fetchWithRetry(url);
      final vendors = _parseVendors(json);
      await _saveCache(json);
      return vendors;
    } catch (e) {
      final cached = await getCachedVendors();
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  /// 读取本地缓存的云端厂商列表。
  Future<List<CloudVendor>> getCachedVendors() async {
    try {
      final file = await _cacheFile();
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      if (content.isEmpty) return [];
      final json = JsonUtils.tryDecodeMap(content);
      if (json == null) return [];
      return _parseVendors(json);
    } catch (_) {
      return [];
    }
  }

  /// 带重试的 HTTP GET 请求（最多 3 次，指数退避）。
  Future<Map<String, dynamic>> _fetchWithRetry(String url) async {
    Object? lastError;
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        final resp = await _dio.get(url);
        if (resp.statusCode == 200) {
          if (resp.data is String) {
            final json = JsonUtils.tryDecodeMap(resp.data as String);
            if (json == null) throw StateError('JSON 解析失败');
            return json;
          }
          return resp.data as Map<String, dynamic>;
        }
        throw StateError('HTTP ${resp.statusCode}');
      } on DioException catch (e) {
        if (e.type == DioExceptionType.cancel) rethrow;
        lastError = StateError('请求失败: ${e.message}');
        if (attempt < 2) {
          await Future.delayed(Duration(seconds: (1 << (attempt + 1))));
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

  /// 解析 JSON 为 CloudVendor 列表。
  List<CloudVendor> _parseVendors(Map<String, dynamic> json) {
    final vendorsJson = json['vendors'] as List? ?? [];
    return vendorsJson
        .map((e) => CloudVendor.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 保存 JSON 到本地缓存文件。
  Future<void> _saveCache(Map<String, dynamic> json) async {
    final file = await _cacheFile();
    await file.writeAsString(JsonUtils.encodePretty(json));
  }

  /// 缓存文件路径：{appDocDir}/cloud_models_cache.json。
  Future<File> _cacheFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, 'cloud_models_cache.json'));
  }

  void dispose() {
    _dio.close(force: true);
  }
}
