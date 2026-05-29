import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'ai_provider.dart';
import '../data/models/intent_result.dart';

class LocalAIProvider implements AIProvider {
  LlamaContext? _context;
  String? _modelPath;
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  Future<void> loadModel(String path) async {
    _modelPath = path;
    try {
      _context = LlamaContext(modelPath: path);
      _isLoaded = true;
    } catch (e) {
      _isLoaded = false;
      throw StateError('本地模型加载失败: $e');
    }
  }

  void _ensureLoaded() {
    if (!_isLoaded || _context == null) {
      throw StateError('本地模型未加载');
    }
  }

  Future<String> _prompt(String systemPrompt, String userPrompt) async {
    _ensureLoaded();
    final messages = [
      {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': userPrompt},
    ];
    return await _context!.prompt(messages);
  }

  @override
  Future<AIResponse> generateAnswer({required String query, required List<String> contextDocs, List<Map<String, String>> history = const []}) async {
    final contextStr = contextDocs.asMap().entries.map((e) => '[${e.key + 1}] ${e.value}').join('\n\n');
    final answer = await _prompt(
      '你是知识库问答助手。根据上下文回答问题，引用标注[1][2]。上下文:\n$contextStr',
      query,
    );
    return AIResponse(answer: answer);
  }

  @override
  Future<QuizGenerationResult> generateQuiz({required String content, required int minCount, required int maxCount}) async {
    final answer = await _prompt(
      '你是出题专家。生成 $minCount-$maxCount 道题，返回 JSON 数组。',
      content,
    );
    return const QuizGenerationResult(questions: []);
  }

  @override
  Future<IntentResult> analyzeIntent({required String text, List<String> existingFiles = const []}) async {
    final answer = await _prompt(
      '分析用户意图，返回 JSON: {type, suggestedCategory, keywords}',
      text,
    );
    return IntentResult(type: 'chat', keywords: [text]);
  }

  @override
  Future<String> summarize({required String content, int maxLength = 200}) async {
    return await _prompt('生成摘要，不超过 $maxLength 字。', content);
  }

  @override
  Future<GradeResult> gradeAnswer({required String question, required String referenceAnswer, required String userAnswer}) async {
    final answer = await _prompt(
      '评分并反馈。返回 JSON: {score, feedback}，score 为 0-100。',
      '题目: $question\n参考答案: $referenceAnswer\n用户回答: $userAnswer',
    );
    return const GradeResult(score: 0, feedback: '本地评分暂不支持');
  }

  @override
  Future<List<double>> generateEmbedding({required String text}) async {
    return [];
  }

  @override
  void dispose() {
    _context?.dispose();
    _context = null;
    _isLoaded = false;
  }
}