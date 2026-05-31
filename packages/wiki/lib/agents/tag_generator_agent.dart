import 'package:core/ai/ai_provider.dart';
import 'package:core/ai/prompt_manager.dart';

/// 标签生成 Agent，通过 AI 分析文档内容生成结构化标签。
class TagGeneratorAgent {
  final AIProvider _aiProvider;
  final PromptManager _promptManager;

  TagGeneratorAgent({
    required AIProvider aiProvider,
    required PromptManager promptManager,
  })  : _aiProvider = aiProvider,
        _promptManager = promptManager;

  /// 分析文档内容，生成 3~5 个标签。
  ///
  /// [content] 为文档正文（截取前 2000 字）。
  /// 返回去重后的标签列表。
  Future<List<String>> generateTags({required String content}) async {
    final truncated =
        content.length > 2000 ? content.substring(0, 2000) : content;

    final template = await _promptManager.loadTemplate('tag_generator');
    final prompt =
        _promptManager.render(template, {'document_text': truncated});

    final response = await _aiProvider.summarize(
      content: truncated,
      maxLength: 50,
      systemPrompt: prompt,
    );

    return response
        .split(RegExp(r'[,，]'))
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toSet()
        .toList();
  }
}
