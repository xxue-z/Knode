import '../core/tokenizer/tokenizer.dart';
import 'tfidf_service.dart';

class SearchResult {
  final int docId;
  final int chunkIndex;
  final double score;
  final String text;
  const SearchResult({required this.docId, required this.chunkIndex, required this.score, this.text = ''});
}

class TfidfSearchService {
  final TfidfService _tfidfService;
  final Tokenizer _tokenizer;

  TfidfSearchService(this._tfidfService, this._tokenizer);

  Future<List<SearchResult>> search(String query, {int topK = 10}) async {
    final tokens = _tokenizer.tokenize(query);
    if (tokens.isEmpty) return [];
    final results = await _tfidfService.search(tokens, topK: topK);
    final maxScore = results.isEmpty ? 1.0 : results.first.score;
    return results.map((r) => SearchResult(
      docId: r.docId, chunkIndex: 0,
      score: maxScore > 0 ? r.score / maxScore : 0.0,
    )).toList();
  }

  Future<void> indexDocument(int docId, String text) async {
    await _tfidfService.indexDocument(docId, text);
  }

  Future<void> deleteByDoc(int docId) async {
    await _tfidfService.deleteByDoc(docId);
  }
}