import '../ai/ai_provider.dart';
import 'hybrid_search_service.dart';

class RagService {
  final AIProvider _aiProvider;
  final HybridSearchService _hybridSearch;

  RagService({required AIProvider aiProvider, required HybridSearchService hybridSearch})
      : _aiProvider = aiProvider, _hybridSearch = hybridSearch;

  Future<AIResponse> answer({
    required String query,
    required int conversationId,
    int topK = 5,
    List<Map<String, String>> history = const [],
    String? systemPrompt,
  }) async {
    final results = await _hybridSearch.search(query, topK: topK);
    final contextDocs = results.asMap().entries.map((e) => '[${e.key + 1}] ${e.value.text}').toList();
    return _aiProvider.generateAnswer(query: query, contextDocs: contextDocs, history: history);
  }

  void dispose() {}
}