import 'dart:convert';
import '../ai_provider.dart';
import '../prompt_manager.dart';

class GraderResult {
  final double score;
  final String feedback;
  final String? explanation;
  const GraderResult({required this.score, required this.feedback, this.explanation});
}

class GraderAgent {
  final AIProvider _ai;
  final PromptManager _prompt;
  GraderAgent({required AIProvider ai, required PromptManager prompt}) : _ai = ai, _prompt = prompt;

  Future<GraderResult> grade({required String question, required String referenceAnswer, required String userAnswer}) async {
    final template = await _prompt.loadTemplate('grader');
    final systemPrompt = _prompt.render(template, {});
    final userQuery = '题目: $question\n参考答案: $referenceAnswer\n用户回答: $userAnswer';
    final response = await _ai.generateAnswer(query: userQuery, contextDocs: [], systemPrompt: systemPrompt);
    try {
      final json = jsonDecode(response.answer);
      return GraderResult(
        score: (json['score'] as num?)?.toDouble() ?? 0,
        feedback: json['feedback'] as String? ?? '',
        explanation: json['explanation'] as String?,
      );
    } catch (_) {
      return GraderResult(score: 0, feedback: response.answer);
    }
  }
}