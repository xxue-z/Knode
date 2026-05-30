import 'package:core/ai/ai_provider.dart';
import 'package:core/ai/cloud_ai_provider.dart';
import 'package:core/ai/prompt_manager.dart';

/// 联网搜索 Agent，仅 CloudAIProvider 可用。
///
/// OpenAI 规范：调用 enable_search 参数（DeepSeek 扩展）
/// Anthropic 规范：通过提示词引导模型使用内置搜索能力
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

      String content;

      if (cloudProvider.apiSpec == ApiSpec.anthropic) {
        // Anthropic：通过普通聊天调用，提示词中引导搜索
        final response = await _aiProvider.generateAnswer(
          query: query,
          contextDocs: [],
          systemPrompt: '$systemPrompt\n\n请尽可能搜索最新信息来回答这个问题。',
        );
        content = response.answer;
      } else {
        // OpenAI/DeepSeek：使用 enable_search 扩展参数
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
        content = resp.data['choices'][0]['message']['content'] as String? ?? '';
      }

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
