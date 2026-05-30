import 'dart:convert';
import 'package:dio/dio.dart';
import 'ai_provider.dart';
import 'package:core/gen/strings.dart';
import 'package:core/models/intent_result.dart';

const _strings = L10nStringsMixin();

/// API 规范类型。
enum ApiSpec { openai, anthropic }

/// AIProvider 的云端实现，支持 OpenAI 和 Anthropic 两种 API 规范。
///
/// 根据 [apiSpec] 自动切换请求格式、端点和响应解析逻辑。
class CloudAIProvider implements AIProvider {
  final String baseUrl;
  final String apiKey;
  final String model;
  final ApiSpec apiSpec;
  late final Dio dio;

  CloudAIProvider({
    required this.baseUrl,
    required this.apiKey,
    required this.model,
    this.apiSpec = ApiSpec.openai,
  }) {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: _buildHeaders(),
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 180),
    ));
  }

  /// 构建请求头（根据 API 规范不同）。
  Map<String, String> _buildHeaders() {
    switch (apiSpec) {
      case ApiSpec.openai:
        return {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        };
      case ApiSpec.anthropic:
        return {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'Content-Type': 'application/json',
        };
    }
  }

  /// 核心聊天方法，根据 API 规范切换请求/响应格式。
  Future<Map<String, dynamic>> _chat(
    List<Map<String, String>> messages, {
    String? systemPrompt,
    double? temperature,
    int? maxTokens,
  }) async {
    try {
      switch (apiSpec) {
        case ApiSpec.openai:
          return await _chatOpenAI(messages, temperature: temperature, maxTokens: maxTokens);
        case ApiSpec.anthropic:
          return await _chatAnthropic(messages, systemPrompt: systemPrompt, temperature: temperature, maxTokens: maxTokens);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) throw StateError(_strings.core_api_rate_limited);
      if (e.response?.statusCode == 401) throw StateError(_strings.core_invalid_api_id);
      if (e.response?.statusCode == 502 || e.response?.statusCode == 503) {
        throw StateError(_strings.core_service_unavailable);
      }
      throw StateError('${_strings.core_network_request_failed}: ${e.message}');
    }
  }

  /// OpenAI 格式请求。
  Future<Map<String, dynamic>> _chatOpenAI(
    List<Map<String, String>> messages, {
    double? temperature,
    int? maxTokens,
  }) async {
    final body = <String, dynamic>{
      'model': model,
      'messages': messages,
      'stream': false,
    };
    if (temperature != null) body['temperature'] = temperature;
    if (maxTokens != null) body['max_tokens'] = maxTokens;

    final resp = await dio.post('/v1/chat/completions', data: body);
    return Map<String, dynamic>.from(resp.data['choices'][0]['message'] as Map);
  }

  /// Anthropic 格式请求。
  ///
  /// Anthropic API 差异：
  /// - 端点：/v1/messages（非 /v1/chat/completions）
  /// - system prompt：顶层字段，不在 messages 中
  /// - messages：仅 user/assistant，无 system role
  /// - max_tokens：必填
  /// - 响应：content[0].text（非 choices[0].message.content）
  Future<Map<String, dynamic>> _chatAnthropic(
    List<Map<String, String>> messages, {
    String? systemPrompt,
    double? temperature,
    int? maxTokens,
  }) async {
    // 分离 system prompt 和普通消息
    String? extractedSystem = systemPrompt;
    final userMessages = <Map<String, String>>[];

    for (final msg in messages) {
      if (msg['role'] == 'system') {
        extractedSystem ??= msg['content'];
      } else {
        userMessages.add({'role': msg['role']!, 'content': msg['content']!});
      }
    }

    final body = <String, dynamic>{
      'model': model,
      'messages': userMessages,
      'max_tokens': maxTokens ?? 4096,
    };
    if (extractedSystem != null) body['system'] = extractedSystem;
    if (temperature != null) body['temperature'] = temperature;

    final resp = await dio.post('/v1/messages', data: body);

    // Anthropic 响应格式：{content: [{type: "text", text: "..."}], stop_reason, ...}
    final content = resp.data['content'] as List;
    final text = content.isNotEmpty ? content[0]['text'] as String? ?? '' : '';

    // 返回 OpenAI 兼容格式，统一后续处理
    return {'role': 'assistant', 'content': text};
  }

  @override
  Future<AIResponse> generateAnswer({
    required String query,
    required List<String> contextDocs,
    List<Map<String, String>> history = const [],
    String? systemPrompt,
  }) async {
    final contextStr = contextDocs.asMap().entries.map((e) => '[${e.key + 1}] ${e.value}').join('\n\n');
    final defaultPrompt = '你是知识库问答助手。根据以下上下文回答问题，引用时标注[1][2]等角标。\n\n上下文:\n$contextStr';
    final effectiveSystem = systemPrompt ?? defaultPrompt;

    final msgs = <Map<String, String>>[
      // OpenAI: system 在 messages 中；Anthropic: 提取到顶层
      {'role': 'system', 'content': effectiveSystem},
      ...history.map((h) => {'role': h['role'] ?? 'user', 'content': h['content'] ?? ''}),
      {'role': 'user', 'content': query},
    ];
    final result = await _chat(msgs, systemPrompt: effectiveSystem, temperature: 0.3);
    final content = result['content'] as String? ?? '';

    // 解析引用标记
    final citationPattern = RegExp(r'\[(\d+)\]');
    final citations = <CitationRef>[];
    for (final match in citationPattern.allMatches(content)) {
      final idx = int.tryParse(match.group(1) ?? '');
      if (idx != null && idx >= 1 && idx <= contextDocs.length) {
        citations.add(CitationRef(docId: idx - 1, title: contextDocs[idx - 1].split(' ').first, snippet: ''));
      }
    }

    return AIResponse(answer: content, citations: citations);
  }

  @override
  Future<QuizGenerationResult> generateQuiz({
    required String content,
    required int minCount,
    required int maxCount,
    String? systemPrompt,
  }) async {
    final defaultPrompt = '你是出题专家。根据内容生成 $minCount-$maxCount 道题，返回 JSON 数组，每题含 type/stem/options/answer/explanation/difficulty 字段。';
    final effectiveSystem = systemPrompt ?? defaultPrompt;
    final msgs = [
      {'role': 'system', 'content': effectiveSystem},
      {'role': 'user', 'content': content},
    ];
    final result = await _chat(msgs, systemPrompt: effectiveSystem, temperature: 0.3);
    final text = result['content'] as String? ?? '[]';
    try {
      final list = (jsonDecode(text) as List).cast<Map<String, dynamic>>();
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
    final defaultPrompt = '分析用户意图，返回 JSON: {type, suggestedCategory, keywords}。type 为 quiz/search/chat/summarize。已有文件: $filesStr';
    final effectiveSystem = systemPrompt ?? defaultPrompt;
    final msgs = [
      {'role': 'system', 'content': effectiveSystem},
      {'role': 'user', 'content': text},
    ];
    final result = await _chat(msgs, systemPrompt: effectiveSystem, temperature: 0.1);
    final raw = result['content'] as String? ?? '{}';
    try {
      return IntentResult.fromMap(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return IntentResult(type: 'chat', keywords: [text]);
    }
  }

  @override
  Future<String> summarize({
    required String content,
    int maxLength = 200,
    String? systemPrompt,
  }) async {
    final defaultPrompt = '生成摘要，不超过 $maxLength 字，输出要点列表。';
    final effectiveSystem = systemPrompt ?? defaultPrompt;
    final msgs = [
      {'role': 'system', 'content': effectiveSystem},
      {'role': 'user', 'content': content},
    ];
    final result = await _chat(msgs, systemPrompt: effectiveSystem, temperature: 0.3);
    return result['content'] as String? ?? '';
  }

  @override
  Future<GradeResult> gradeAnswer({
    required String question,
    required String referenceAnswer,
    required String userAnswer,
    String? systemPrompt,
  }) async {
    final defaultPrompt = '评分并反馈。返回 JSON: {score, feedback}，score 为 0-100 分。';
    final effectiveSystem = systemPrompt ?? defaultPrompt;
    final msgs = [
      {'role': 'system', 'content': effectiveSystem},
      {'role': 'user', 'content': '题目: $question\n参考答案: $referenceAnswer\n用户回答: $userAnswer'},
    ];
    final result = await _chat(msgs, systemPrompt: effectiveSystem, temperature: 0.1);
    final raw = result['content'] as String? ?? '{}';
    try {
      final m = jsonDecode(raw);
      return GradeResult(score: (m['score'] as num).toDouble(), feedback: m['feedback'] as String? ?? '');
    } catch (_) {
      return GradeResult(score: 0, feedback: _strings.core_grading_failed);
    }
  }

  @override
  Future<List<double>> generateEmbedding({required String text}) async {
    // Anthropic 不提供 Embedding API
    if (apiSpec == ApiSpec.anthropic) {
      throw StateError('Anthropic API 不支持 Embedding，请使用 OpenAI 兼容接口');
    }
    try {
      final resp = await dio.post('/v1/embeddings', data: {'model': model, 'input': text});
      final data = resp.data['data'][0]['embedding'];
      return List<double>.from((data as List).map((e) => (e as num).toDouble()));
    } catch (e) {
      throw StateError('${_strings.core_embedding_generation_failed}: $e');
    }
  }

  @override
  void dispose() => dio.close(force: true);
}
