import 'dart:convert';
import 'package:dio/dio.dart';

/// 第三方搜索 API 服务。
///
/// 支持 SerpAPI 和 Tavily 两种搜索服务商。
class SearchApiService {
  final Dio _dio;
  final String? _serpApiKey;
  final String? _tavilyApiKey;

  SearchApiService({
    Dio? dio,
    String? serpApiKey,
    String? tavilyApiKey,
  })  : _dio = dio ?? Dio(),
        _serpApiKey = serpApiKey,
        _tavilyApiKey = tavilyApiKey;

  /// 当前可用的搜索服务商。
  String? get activeProvider {
    if (_tavilyApiKey != null && _tavilyApiKey!.isNotEmpty) return 'tavily';
    if (_serpApiKey != null && _serpApiKey!.isNotEmpty) return 'serpapi';
    return null;
  }

  /// 执行搜索，返回搜索结果文本列表。
  Future<List<String>> search(String query, {int topK = 5}) async {
    if (activeProvider == null) return [];

    try {
      if (activeProvider == 'tavily') {
        return await _searchTavily(query, topK: topK);
      } else {
        return await _searchSerpApi(query, topK: topK);
      }
    } catch (e) {
      return [];
    }
  }

  /// Tavily 搜索 API。
  Future<List<String>> _searchTavily(String query, {int topK = 5}) async {
    final response = await _dio.post(
      'https://api.tavily.com/search',
      data: {
        'api_key': _tavilyApiKey,
        'query': query,
        'max_results': topK,
        'search_depth': 'basic',
      },
      options: Options(
        sendTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    final results = response.data['results'] as List? ?? [];
    return results.map<String>((r) {
      final title = r['title'] as String? ?? '';
      final content = r['content'] as String? ?? '';
      final url = r['url'] as String? ?? '';
      return '[$title] $content\n来源: $url';
    }).toList();
  }

  /// SerpAPI 搜索。
  Future<List<String>> _searchSerpApi(String query, {int topK = 5}) async {
    final response = await _dio.get(
      'https://serpapi.com/search.json',
      queryParameters: {
        'q': query,
        'api_key': _serpApiKey,
        'num': topK,
      },
      options: Options(
        sendTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    final results = response.data['organic_results'] as List? ?? [];
    return results.map<String>((r) {
      final title = r['title'] as String? ?? '';
      final snippet = r['snippet'] as String? ?? '';
      final link = r['link'] as String? ?? '';
      return '[$title] $snippet\n来源: $link';
    }).toList();
  }

  /// 测试连接：用简单查询验证 API Key 是否有效。
  Future<bool> testConnection() async {
    if (activeProvider == null) return false;
    try {
      final results = await search('test', topK: 1);
      return results.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
