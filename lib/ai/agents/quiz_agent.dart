import 'dart:convert';
import '../ai_provider.dart';
import '../prompt_manager.dart';
import '../../core/utils/hash_utils.dart';
import '../../data/models/question.dart';

class QuizAgent {
  final AIProvider _ai;
  final PromptManager _prompt;
  QuizAgent({required AIProvider ai, required PromptManager prompt}) : _ai = ai, _prompt = prompt;

  Future<List<Question>> generateQuiz({required String content, required int minCount, required int maxCount}) async {
    final template = await _prompt.loadTemplate('quiz_generator');
    final rendered = _prompt.render(template, {'content': content, 'min': minCount.toString(), 'max': maxCount.toString()});
    final response = await _ai.generateAnswer(query: rendered, contextDocs: []);
    try {
      final json = jsonDecode(response.answer);
      final questions = (json['questions'] as List?) ?? [];
      final seen = <String>{};
      final result = <Question>[];
      for (final q in questions) {
        final hash = HashUtils.md5(q['stem'] as String? ?? '');
        if (seen.contains(hash)) continue;
        seen.add(hash);
        result.add(Question(
          id: 0, type: q['type'] as String? ?? 'single_choice',
          stem: q['stem'] as String? ?? '', options: q['options'] != null ? jsonEncode(q['options']) : null,
          answer: q['answer'] as String? ?? '', explanation: q['explanation'] as String?,
          difficulty: q['difficulty'] as int? ?? 1, createdAt: DateTime.now().toIso8601String(),
        ));
      }
      return result;
    } catch (_) {
      return [];
    }
  }
}