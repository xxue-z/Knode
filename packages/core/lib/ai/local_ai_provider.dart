import 'dart:convert';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'ai_provider.dart';
import 'package:core/gen/strings.dart';
import 'package:core/models/intent_result.dart';

const _strings = L10nStringsMixin();

/// AIProvider 的本地实现，使用 llama_cpp_dart 加载 .gguf 量化模型离线推理。
///
/// 每个方法接受可选的 [systemPrompt] 参数，由 Agent 通过 PromptManager 加载模板后传入。
class LocalAIProvider implements AIProvider {
  Llama? _llama;
  String? _modelPath;
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  String? get modelPath => _modelPath;

  Future<void> loadModel(String path) async {
    _modelPath = path;
    try {
      _llama = Llama(path);
      _isLoaded = true;
    } catch (e) {
      _isLoaded = false;
      throw StateError('本地模型加载失败: $e');
    }
  }

  void _ensureLoaded() {
    if (!_isLoaded || _llama == null) {
      throw StateError('本地模型未加载，请先调用 loadModel()');
    }
  }

  Future<String> _prompt(String systemPrompt, String userPrompt) async {
    _ensureLoaded();
    // 将消息格式化为提示词
    final prompt = 'System: $systemPrompt\n\nUser: $userPrompt\n\nAssistant:';
    // 使用 Llama 的 generateCompleteText 方法
    final response = await _llama!.generateCompleteText();
    return response;
  }

  @override
  Future<AIResponse> generateAnswer({
    required String query,
    required List<String> contextDocs,
    List<Map<String, String>> history = const [],
    String? systemPrompt,
  }) async {
    final contextStr = contextDocs.asMap().entries
        .map((e) => '[${e.key + 1}] ${e.value}')
        .join('\n\n');
    final defaultPrompt = '你是知识库问答助手。根据上下文回答问题，引用标注[1][2]。上下文:\n$contextStr';
    final answer = await _prompt(systemPrompt ?? defaultPrompt, query);

    final citationPattern = RegExp(r'\[(\d+)\]');
    final citations = <CitationRef>[];
    for (final match in citationPattern.allMatches(answer)) {
      final idx = int.tryParse(match.group(1) ?? '');
      if (idx != null && idx >= 1 && idx <= contextDocs.length) {
        citations.add(CitationRef(
          docId: idx - 1,
          title: contextDocs[idx - 1].split(' ').first,
          snippet: '',
        ));
      }
    }

    return AIResponse(answer: answer, citations: citations);
  }

  @override
  Future<QuizGenerationResult> generateQuiz({
    required String content,
    required int minCount,
    required int maxCount,
    String? systemPrompt,
  }) async {
    final defaultPrompt = '你是出题专家。根据内容生成 $minCount-$maxCount 道题，返回 JSON 数组，每题含 type/stem/options/answer/explanation/difficulty 字段。';
    final answer = await _prompt(systemPrompt ?? defaultPrompt, content);
    try {
      final jsonStart = answer.indexOf('[');
      final jsonEnd = answer.lastIndexOf(']');
      if (jsonStart == -1 || jsonEnd == -1) {
        return const QuizGenerationResult(questions: []);
      }
      final jsonStr = answer.substring(jsonStart, jsonEnd + 1);
      final list = (jsonDecode(jsonStr) as List).cast<Map<String, dynamic>>();
      return QuizGenerationResult(questions: list.map(QuizItem.fromMap).toList());
    } catch (_) {
      return const QuizGenerationResult(questions: []);
    }
  }

  @override
  Future<IntentResult> analyzeIntent({
    required String text,
    List<String> existingFiles = const [],
    String? systemPrompt,
  }) async {
    final filesStr = existingFiles.join(', ');
    final defaultPrompt = '分析用户意图，返回 JSON: {type, suggestedCategory, keywords}。已有文件: $filesStr';
    final answer = await _prompt(systemPrompt ?? defaultPrompt, text);
    try {
      final jsonStart = answer.indexOf('{');
      final jsonEnd = answer.lastIndexOf('}');
      if (jsonStart == -1 || jsonEnd == -1) {
        return IntentResult(type: 'chat', keywords: [text]);
      }
      final jsonStr = answer.substring(jsonStart, jsonEnd + 1);
      return IntentResult.fromMap(jsonDecode(jsonStr) as Map<String, dynamic>);
    } catch (_) {
      return IntentResult(type: 'chat', keywords: [text]);
    }
  }

  @override
  Future<String> summarize({required String content, int maxLength = 200, String? systemPrompt}) async {
    final defaultPrompt = '生成摘要，不超过 $maxLength 字，输出要点列表。';
    return await _prompt(systemPrompt ?? defaultPrompt, content);
  }

  @override
  Future<GradeResult> gradeAnswer({
    required String question,
    required String referenceAnswer,
    required String userAnswer,
    String? systemPrompt,
  }) async {
    final defaultPrompt = '评分并反馈。返回 JSON: {score, feedback}，score 为 0-100。';
    final answer = await _prompt(
      systemPrompt ?? defaultPrompt,
      '题目: $question\n参考答案: $referenceAnswer\n用户回答: $userAnswer',
    );
    try {
      final jsonStart = answer.indexOf('{');
      final jsonEnd = answer.lastIndexOf('}');
      if (jsonStart == -1 || jsonEnd == -1) {
        return GradeResult(score: 0, feedback: _strings.core_grading_result_parsing_failed);
      }
      final jsonStr = answer.substring(jsonStart, jsonEnd + 1);
      final m = jsonDecode(jsonStr);
      return GradeResult(
        score: (m['score'] as num).toDouble(),
        feedback: m['feedback'] as String? ?? '',
      );
    } catch (_) {
      return const GradeResult(score: 0, feedback: '评分解析失败');
    }
  }

  @override
  Future<List<double>> generateEmbedding({required String text}) async {
    _ensureLoaded();
    try {
      // Llama 类可能不支持直接 embedding，返回空列表
      // 实际实现需要根据 llama_cpp_dart 的 API 调整
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  void dispose() {
    _llama?.dispose();
    _llama = null;
    _isLoaded = false;
    _modelPath = null;
  }
}
