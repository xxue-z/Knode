import '../core/tokenizer/tokenizer.dart';
import 'tfidf_service.dart' show TfidfService, ChunkData;

/// TF-IDF 检索结果（与 HybridSearchService.SearchResult 兼容）。
class TfidfSearchResult {
  final int docId;
  final int chunkIndex;
  final double score;
  final String text;
  const TfidfSearchResult({required this.docId, required this.chunkIndex, required this.score, this.text = ''});
}

class TfidfSearchService {
  final TfidfService _tfidfService;
  final Tokenizer _tokenizer;

  TfidfSearchService(this._tfidfService, this._tokenizer);

  Future<List<TfidfSearchResult>> search(String query, {int topK = 10}) async {
    final tokens = _tokenizer.tokenize(query);
    if (tokens.isEmpty) return [];
    final results = await _tfidfService.search(tokens, topK: topK);
    // 归一化分数到 [0, 1]
    final maxScore = results.isEmpty ? 1.0 : results.first.score;
    return results.map((r) => TfidfSearchResult(
      docId: r.docId,
      chunkIndex: r.chunkIndex,
      score: maxScore > 0 ? r.score / maxScore : 0.0,
      text: r.text,
    )).toList();
  }

  Future<void> indexDocument(int docId, String text) async {
    await _tfidfService.indexDocument(docId, text);
  }

  Future<void> deleteByDoc(int docId) async {
    await _tfidfService.deleteByDoc(docId);
  }

  /// 获取文档的所有块。
  Future<List<ChunkData>> getChunks(int docId) async {
    return _tfidfService.getChunks(docId);
  }
}