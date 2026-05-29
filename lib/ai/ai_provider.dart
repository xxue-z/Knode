import '../data/models/intent_result.dart';

/// AI 回答结果。
class AIResponse {
  final String answer;
  final List<CitationRef> citations;
  const AIResponse({required this.answer, this.citations = const []});
}

/// 引用片段。
class CitationRef {
  final int docId;
  final String title;
  final String snippet;
  const CitationRef({required this.docId, required this.title, required this.snippet});
}

/// 生成题目结果。
class QuizGenerationResult {
  final List<QuizItem> questions;
  const QuizGenerationResult({required this.questions});
}

/// 单道题目。
class QuizItem {
  final String type;
  final String stem;
  final List<String>? options;
  final String answer;
  final String? explanation;
  final int difficulty;
  const QuizItem({required this.type, required this.stem, this.options, required this.answer, this.explanation, this.difficulty = 1});
  factory QuizItem.fromMap(Map<String, dynamic> map) {
    return QuizItem(
      type: map['type'] as String? ?? 'single',
      stem: map['stem'] as String,
      options: map['options'] != null ? List<String>.from(map['options'] as List) : null,
      answer: map['answer'] as String,
      explanation: map['explanation'] as String?,
      difficulty: map['difficulty'] as int? ?? 1,
    );
  }
}

/// 评分结果。
class GradeResult {
  final double score;
  final String feedback;
  const GradeResult({required this.score, required this.feedback});
}

/// AIProvider 抽象接口。所有 AI 调用通过此接口。
abstract class AIProvider {
  Future<AIResponse> generateAnswer({required String query, required List<String> contextDocs, List<Map<String, String>> history = const []});
  Future<QuizGenerationResult> generateQuiz({required String content, required int minCount, required int maxCount});
  Future<IntentResult> analyzeIntent({required String text, List<String> existingFiles = const []});
  Future<String> summarize({required String content, int maxLength = 200});
  Future<GradeResult> gradeAnswer({required String question, required String referenceAnswer, required String userAnswer});
  Future<List<double>> generateEmbedding({required String text});
  void dispose();
}
