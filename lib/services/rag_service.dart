import '../ai/ai_provider.dart';
import '../ai/embedding_service.dart';
import 'vector_store_service.dart';
import '../data/dao/document_dao.dart';

/// RAG 流水线服务：向量化 → 检索 → 组装 Prompt → 生成回答 → 解析引用。
class RagService {
  final AIProvider _aiProvider;
  final EmbeddingService _embeddingService;
  final VectorStoreService _vectorStore;
  final DocumentDao _documentDao;

  RagService({
    required AIProvider aiProvider,
    required EmbeddingService embeddingService,
    required VectorStoreService vectorStore,
    required DocumentDao documentDao,
  })  : _aiProvider = aiProvider,
        _embeddingService = embeddingService,
        _vectorStore = vectorStore,
        _documentDao = documentDao;

  /// 基于 RAG 回答用户问题。
  ///
  /// 1. 向量化查询文本
  /// 2. 从向量库检索 Top K 相关文档
  /// 3. 组装上下文文档（带引用编号）
  /// 4. 调用 AIProvider 生成回答（含对话历史）
  /// 5. 返回带引用的 AIResponse
  Future<AIResponse> answer({
    required String query,
    required int conversationId,
    int topK = 5,
    List<Map<String, String>> history = const [],
  }) async {
    // 1. 向量化查询
    final queryEmb = await _embeddingService.embedText(query);
    if (queryEmb.isEmpty) {
      return _aiProvider.generateAnswer(
        query: query,
        contextDocs: [],
        history: history,
      );
    }

    // 2. 检索相关文档
    final results = await _vectorStore.search(queryEmb, topK: topK);
    final contextDocs = <String>[];
    final seenDocIds = <int>{};
    for (final r in results) {
      if (seenDocIds.contains(r.docId)) continue;
      seenDocIds.add(r.docId);
      final doc = await _documentDao.getById(r.docId);
      if (doc != null && doc.contentText != null) {
        // 带引用编号的上下文格式
        contextDocs.add('[${contextDocs.length + 1}] ${doc.title}\n${doc.contentText}');
      }
    }

    // 3. 调用 AI 生成回答（含对话历史）
    return _aiProvider.generateAnswer(
      query: query,
      contextDocs: contextDocs,
      history: history,
    );
  }

  void dispose() {}
}
