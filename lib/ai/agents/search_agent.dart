import 'dart:convert';
import '../ai_provider.dart';
import '../cloud_ai_provider.dart';

/// 联网搜索 Agent，仅 CloudAIProvider 可用。
///
/// 通过 CloudAIProvider 的 API 调用 enable_search 参数进行联网检索，
/// 将搜索结果合并到 RAG 上下文中。
class SearchAgent {
  final AIProvider _aiProvider;

  SearchAgent({required AIProvider aiProvider}) : _aiProvider = aiProvider;

  /// 当前 Provider 是否支持联网搜索（仅云端可用）。
  bool get isAvailable => _aiProvider is CloudAIProvider;

  /// 执行联网搜索，返回搜索结果文本列表。
  ///
  /// 使用 CloudAIProvider 的 API 并启用 enable_search 参数，
  /// 模型会自动联网搜索并整合结果到回答中。
  Future<List<String>> search(String query, {int topK = 5}) async {
    if (!isAvailable) return [];

    try {
      final cloudProvider = _aiProvider as CloudAIProvider;

      // 通过 Dio 直接调用 API，启用 enable_search
      final resp = await cloudProvider.dio.post(
        '/v1/chat/completions',
        data: {
          'model': cloudProvider.model,
          'messages': [
            {
              'role': 'system',
              'content': '你是一个联网搜索助手。请搜索最新信息并返回结果，每条结果包含标题和摘要。',
            },
            {'role': 'user', 'content': query},
          ],
          'stream': false,
          'enable_search': true,
        },
      );

      final content = resp.data['choices'][0]['message']['content'] as String? ?? '';

      // 解析搜索结果（按段落分割）
      final results = content
          .split(RegExp(r'\n{2,}'))
          .where((s) => s.trim().isNotEmpty)
          .take(topK)
          .toList();

      return results;
    } catch (e) {
      return [];
    }
  }
}
