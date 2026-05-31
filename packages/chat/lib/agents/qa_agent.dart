import 'package:core/ai/ai_provider.dart';
import 'package:core/ai/prompt_manager.dart';
import 'package:core/services/rag_service.dart';
import 'package:chat/agents/search_agent.dart';

/// 问答 Agent，封装 RAG 问答流程。
///
/// 使用 PromptManager 加载 qa_with_rag.txt 模板，
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
  /// 1. 通过 PromptManager 加载 qa_with_rag 模板
  /// 2. 如果启用联网搜索，先调用 SearchAgent
  /// 3. 通过 RAG 流水线检索知识库并生成回答
  Future<AIResponse> ask({
    required String query,
    required int conversationId,
    bool enableSearch = false,
    List<Map<String, String>> history = const [],
  }) async {
    // 加载问答模板
    final template = await _promptManager.loadTemplate('qa_with_rag');
    final systemPrompt = _promptManager.render(template, {
      'conversation_history': history.map((h) => '${h["role"]}: ${h["content"]}').join('\n'),
    });

    // 联网搜索（如果启用且可用）
    List<String> searchResults = [];
    if (enableSearch && _searchAgent != null && _searchAgent.isAvailable) {
      searchResults = await _searchAgent.search(query);
    }

    // RAG 问答（传递模板化的 systemPrompt）
    final ragResponse = await _ragService.answer(
      query: query,
      conversationId: conversationId,
      history: history,
      systemPrompt: systemPrompt,
    );

    // 如果有联网搜索结果，作为额外上下文与 RAG 结果合并，重新生成回答
    if (searchResults.isNotEmpty) {
      final mergedContext = [
        ...searchResults.map((s) => '[联网搜索] $s'),
      ];
      return _aiProvider.generateAnswer(
        query: query,
        contextDocs: mergedContext,
        history: history,
        systemPrompt: systemPrompt,
      );
    }

    return ragResponse;
  }
}
