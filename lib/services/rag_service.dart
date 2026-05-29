import '../ai/ai_provider.dart';
import 'hybrid_search_service.dart';

/// RAG 流水线服务：混合检索 → 组装 Prompt → 生成回答 → 解析引用。
///
/// 使用 HybridSearchService 进行混合检索（语义 + TF-IDF），
/// Embedding 不可用时自动降级为纯 TF-IDF。
class RagService {
  final AIProvider _aiProvider;
  final HybridSearchService _searchService;

  RagService({
    required AIProvider aiProvider,
    required HybridSearchService searchService,
  })  : _aiProvider = aiProvider,
        _searchService = searchService;

  /// 基于 RAG 回答用户问题。
  ///
  /// 1. 混合检索相关文档块（语义 + TF-IDF）
  /// 2. 组装上下文文档（带引用编号）
  /// 3. 调用 AIProvider 生成回答（含对话历史和 systemPrompt）
  Future<AIResponse> answer({
    required String query,
    required int conversationId,
    int topK = 5,
    List<Map<String, String>> history = const [],
    String? systemPrompt,
  }) async {
    // 1. 混合检索
    final searchResults = await _searchService.search(query, topK: topK);

    // 2. 组装上下文（带引用编号）
    final contextDocs = <String>[];
    for (final r in searchResults) {
      if (r.text.isNotEmpty) {
        contextDocs.add('[${contextDocs.length + 1}] ${r.text}');
      }
    }

    // 3. 调用 AI 生成回答（透传 systemPrompt）
    return _aiProvider.generateAnswer(
      query: query,
      contextDocs: contextDocs,
      history: history,
      systemPrompt: systemPrompt,
    );
  }

  void dispose() {}
}
