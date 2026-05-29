import 'dart:convert';
import 'package:dio/dio.dart';
import 'ai_provider.dart';
import '../data/models/intent_result.dart';

class CloudAIProvider implements AIProvider {
  final String baseUrl;
  final String apiKey;
  final String model;
  late final Dio dio;

  CloudAIProvider({required this.baseUrl, required this.apiKey, required this.model}) {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {'Authorization': 'Bearer $apiKey', 'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 120),
    ));
  }

  Future<Map<String, dynamic>> _chat(List<Map<String, String>> messages) async {
    try {
      final resp = await dio.post('/v1/chat/completions', data: {
        'model': model, 'messages': messages, 'stream': false,
      });
      return resp.data['choices'][0]['message'];
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) throw StateError('API 限流，请稍后重试');
      if (e.response?.statusCode == 401) throw StateError('API Key 无效');
      throw StateError('网络请求失败: ${e.message}');
    }
  }

  @override
  Future<AIResponse> generateAnswer({required String query, required List<String> contextDocs, List<Map<String, String>> history = const []}) async {
    final contextStr = contextDocs.asMap().entries.map((e) => '[${e.key + 1}] ${e.value}').join('\n\n');
    final msgs = <Map<String, String>>[
      {'role': 'system', 'content': '你是知识库问答助手。根据以下上下文回答问题，引用时标注[1][2]等角标。\n\n上下文:\n$contextStr'},
      ...history.map((h) => {'role': h['role'] ?? 'user', 'content': h['content'] ?? ''}),
      {'role': 'user', 'content': query},
    ];
    final result = await _chat(msgs);
    final content = result['content'] as String? ?? '';

    // 解析引用标记 [1][2] 等，提取引用的文档索引
    final citationPattern = RegExp(r'\[(\d+)\]');
    final citationMatches = citationPattern.allMatches(content);
    final citationIndices = <int>{};
    for (final match in citationMatches) {
      final idx = int.tryParse(match.group(1) ?? '');
      if (idx != null && idx >= 1 && idx <= contextDocs.length) {
        citationIndices.add(idx - 1);
      }
    }

    // 构建引用列表
    final citations = <CitationRef>[];
    for (final idx in citationIndices) {
      final docTitle = contextDocs[idx].split(' ').first;
      citations.add(CitationRef(docId: idx, title: docTitle, snippet: ''));
    }

    return AIResponse(answer: content, citations: citations);
  }

  @override
  Future<QuizGenerationResult> generateQuiz({required String content, required int minCount, required int maxCount}) async {
    final msgs = [
      {'role': 'system', 'content': '你是出题专家。根据内容生成 $minCount-$maxCount 道题，返回 JSON 数组，每题含 type/stem/options/answer/explanation/difficulty 字段。'},
      {'role': 'user', 'content': content},
    ];
    final result = await _chat(msgs);
    final text = result['content'] as String? ?? '[]';
    try {
      final list = (jsonDecode(text) as List).cast<Map<String, dynamic>>();
      return QuizGenerationResult(questions: list.map(QuizItem.fromMap).toList());
    } catch (_) {
      return const QuizGenerationResult(questions: []);
    }
  }

  @override
  Future<IntentResult> analyzeIntent({required String text, List<String> existingFiles = const []}) async {
    final filesStr = existingFiles.join(', ');
    final msgs = [
      {'role': 'system', 'content': '分析用户意图，返回 JSON: {type, suggestedCategory, keywords}。type 为 quiz/search/chat/summarize。已有文件: $filesStr'},
      {'role': 'user', 'content': text},
    ];
    final result = await _chat(msgs);
    final raw = result['content'] as String? ?? '{}';
    try {
      return IntentResult.fromMap(jsonDecode(raw));
    } catch (_) {
      return IntentResult(type: 'chat', keywords: [text]);
    }
  }

  @override
  Future<String> summarize({required String content, int maxLength = 200}) async {
    final msgs = [
      {'role': 'system', 'content': '生成摘要，不超过 $maxLength 字，输出要点列表。'},
      {'role': 'user', 'content': content},
    ];
    final result = await _chat(msgs);
    return result['content'] as String? ?? '';
  }

  @override
  Future<GradeResult> gradeAnswer({required String question, required String referenceAnswer, required String userAnswer}) async {
    final msgs = [
      {'role': 'system', 'content': '评分并反馈。返回 JSON: {score, feedback}，score 为 0-100 分。'},
      {'role': 'user', 'content': '题目: $question\n参考答案: $referenceAnswer\n用户回答: $userAnswer'},
    ];
    final result = await _chat(msgs);
    final raw = result['content'] as String? ?? '{}';
    try {
      final m = jsonDecode(raw);
      return GradeResult(score: (m['score'] as num).toDouble(), feedback: m['feedback'] as String? ?? '');
    } catch (_) {
      return const GradeResult(score: 0, feedback: '评分失败');
    }
  }

  @override
  Future<List<double>> generateEmbedding({required String text}) async {
    try {
      final resp = await dio.post('/v1/embeddings', data: {'model': model, 'input': text});
      final data = resp.data['data'][0]['embedding'];
      return List<double>.from((data as List).map((e) => (e as num).toDouble()));
    } catch (e) {
      throw StateError('Embedding 生成失败: $e');
    }
  }

  @override
  void dispose() => dio.close(force: true);
}