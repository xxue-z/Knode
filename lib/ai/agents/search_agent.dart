import '../ai_provider.dart';
import '../cloud_ai_provider.dart';
import '../prompt_manager.dart';

/// 联网搜索 Agent，仅 CloudAIProvider 可用。
///
/// 通过 CloudAIProvider 的 API 调用 enable_search 参数进行联网检索，
/// 将搜索结果合并到 RAG 上下文中。
class SearchAgent {
  final AIProvider _aiProvider;
  final PromptManager _promptManager;

  SearchAgent({
    required AIProvider aiProvider,
    required PromptManager promptManager,
  })  : _aiProvider = aiProvider,
        _promptManager = promptManager;

  /// 当前 Provider 是否支持联网搜索（仅云端可用）。
  bool get isAvailable => _aiProvider is CloudAIProvider;

  /// 执行联网搜索，返回搜索结果文本列表。
  Future<List<String>> search(String query, {int topK = 5}) async {
    if (!isAvailable) return [];

    try {
      final cloudProvider = _aiProvider as CloudAIProvider;
      final template = await _promptManager.loadTemplate('search_agent');
      final systemPrompt = _promptManager.render(template, {});

      final resp = await cloudProvider.dio.post(
        '/v1/chat/completions',
        data: {
          'model': cloudProvider.model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': query},
          ],
          'stream': false,
          'enable_search': true,
        },
      );

      final content = resp.data['choices'][0]['message']['content'] as String? ?? '';
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
