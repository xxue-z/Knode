import '../ai_provider.dart';
import '../prompt_manager.dart';

class SummarizerAgent {
  final AIProvider _aiProvider;
  final PromptManager _promptManager;

  SummarizerAgent({required AIProvider aiProvider, required PromptManager promptManager})
      : _aiProvider = aiProvider, _promptManager = promptManager;

  Future<String> summarize({required String content, int maxLength = 200}) async {
    final template = await _promptManager.loadTemplate('summarizer');
    final prompt = _promptManager.render(template, {'content': content, 'max_length': maxLength.toString()});
    return _aiProvider.summarize(content: prompt, maxLength: maxLength);
  }

  Future<String> archiveToNote({required String title, required List<Map<String, String>> messages}) async {
    final conversationText = messages.map((m) => '${m['role']}: ${m['content']}').join('\n\n');
    final summary = await summarize(content: conversationText);
    return '# $title\n\n## 对话摘要\n\n$summary\n\n## 对话记录\n\n$conversationText';
  }
}