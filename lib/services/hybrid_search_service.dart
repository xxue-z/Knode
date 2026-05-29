import 'dart:math';
import 'vector_store_service.dart';
import 'tfidf_search_service.dart';
import 'text_chunker.dart';

class HybridSearchService {
  final VectorStoreService _vectorStore;
  final TfidfSearchService _tfidfSearch;
  final TextChunker _chunker;

  HybridSearchService(this._vectorStore, this._tfidfSearch, this._chunker);

  Future<List<SearchResult>> search(String query, {int topK = 5, double alpha = 0.7}) async {
    final m = topK * 2;
    final semanticFuture = _vectorStore.search([], topK: m).catchError((_) => <VectorSearchResult>[]);
    final tfidfFuture = _tfidfSearch.search(query, topK: m).catchError((_) => <SearchResult>[]);
    final results = await Future.wait([semanticFuture, tfidfFuture]);
    final semanticResults = results[0] as List<VectorSearchResult>;
    final tfidfResults = results[1] as List<SearchResult>;
    final merged = <String, SearchResult>{};
    for (final r in semanticResults) {
      final key = '${r.docId}_${r.chunkIndex}';
      merged[key] = SearchResult(docId: r.docId, chunkIndex: r.chunkIndex, score: r.score * alpha);
    }
    for (final r in tfidfResults) {
      final key = '${r.docId}_${r.chunkIndex}';
      if (merged.containsKey(key)) {
        merged[key] = SearchResult(docId: r.docId, chunkIndex: r.chunkIndex, score: merged[key]!.score + r.score * (1 - alpha));
      } else {
        merged[key] = SearchResult(docId: r.docId, chunkIndex: r.chunkIndex, score: r.score * (1 - alpha));
      }
    }
    final sorted = merged.values.toList()..sort((a, b) => b.score.compareTo(a.score));
    return sorted.take(topK).toList();
  }

  Future<void> indexDocument(int docId, String text, {List<double>? embedding}) async {
    final chunks = _chunker.chunk(text);
    for (final chunk in chunks) {
      await _tfidfSearch.indexDocument(docId, chunk.text);
      if (embedding != null) {
        await _vectorStore.insert(docId, chunk.index, embedding);
      }
    }
  }

  Future<void> deleteByDoc(int docId) async {
    await _vectorStore.deleteByDoc(docId);
    await _tfidfSearch.deleteByDoc(docId);
  }
}