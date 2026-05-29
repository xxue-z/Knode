import '../ai_provider.dart';
import '../prompt_manager.dart';
import '../../services/rag_service.dart';
import 'search_agent.dart';

/// 问答 Agent，封装 RAG 问答流程。
///
/// 当用户启用联网搜索且当前 Provider 为 CloudAIProvider 时，
/// 先调用 SearchAgent 检索网络结果，再合并到 RAG 上下文中。
class QaAgent {
  final AIProvider _aiProvider;
  final RagService _ragService;
  final PromptManager _promptManager;
  final SearchAgent? _searchAgent;

  QaAgent({
    required AIProvider aiProvider,
    required RagService ragService,
    required PromptManager promptManager,
    SearchAgent? searchAgent,
  })  : _aiProvider = aiProvider,
        _ragService = ragService,
        _promptManager = promptManager,
        _searchAgent = searchAgent;

  /// 回答用户问题。
  ///
  /// [enableSearch] 为 true 且 SearchAgent 可用时，先联网搜索再结合 RAG 结果。
  Future<AIResponse> ask({
    required String query,
    required int conversationId,
    bool enableSearch = false,
    List<Map<String, String>> history = const [],
  }) async {
    // 联网搜索（如果启用且可用）
    List<String> searchResults = [];
    if (enableSearch && _searchAgent != null && _searchAgent.isAvailable) {
      searchResults = await _searchAgent.search(query);
    }

    // RAG 问答
    final ragResponse = await _ragService.answer(
      query: query,
      conversationId: conversationId,
      history: history,
    );

    // 如果有联网搜索结果，合并到上下文中重新生成
    if (searchResults.isNotEmpty) {
      final mergedContext = [
        ...searchResults.map((s) => '[联网搜索] $s'),
        ragResponse.answer,
      ];
      return _aiProvider.generateAnswer(
        query: query,
        contextDocs: mergedContext,
        history: history,
      );
    }

    return ragResponse;
  }
}
