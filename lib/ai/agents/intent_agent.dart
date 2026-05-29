import 'dart:convert';
import '../ai_provider.dart';
import '../prompt_manager.dart';
import '../../data/models/intent_result.dart';

class IntentAgent {
  final AIProvider _ai;
  final PromptManager _prompt;
  IntentAgent({required AIProvider ai, required PromptManager prompt}) : _ai = ai, _prompt = prompt;

  Future<IntentResult> analyze({required String text, List<String> existingFiles = const []}) async {
    final template = await _prompt.loadTemplate('intent_analyzer');
    final systemPrompt = _prompt.render(template, {'existing_files': existingFiles.join(', ')});
    final response = await _ai.generateAnswer(query: text, contextDocs: [], systemPrompt: systemPrompt);
    try {
      final json = jsonDecode(response.answer);
      return IntentResult(
        type: json['type'] as String? ?? 'chat',
        suggestedCategory: json['suggestedCategory'] as String?,
        keywords: List<String>.from(json['keywords'] as List? ?? []),
      );
    } catch (_) {
      return IntentResult(type: 'chat', keywords: [text]);
    }
  }
}