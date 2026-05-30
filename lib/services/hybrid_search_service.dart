import 'dart:math' as math;
import 'vector_store_service.dart';
import 'tfidf_search_service.dart';
import 'text_chunker.dart';
import 'embedding_fallback_service.dart';

/// 混合检索服务：并行召回 + 归一化加权融合 + Top K。
///
/// 同时从 doc_vectors（语义）和 doc_chunks（TF-IDF）召回候选块，
/// 归一化后加权融合，取 Top K 作为最终上下文。
class HybridSearchService {
  final VectorStoreService _vectorStore;
  final TfidfSearchService _tfidfSearch;
  final TextChunker _chunker;
  final EmbeddingFallbackService? _embeddingService;

  HybridSearchService(this._vectorStore, this._tfidfSearch, this._chunker, [this._embeddingService]);

  /// 混合检索。
  ///
  /// [queryEmbedding] 为空时自动尝试生成（如果 EmbeddingFallbackService 可用）。
  /// [alpha] 语义权重，默认 0.7。Embedding 不可用时自动设为 0。
  Future<List<SearchResult>> search(
    String query, {
    List<double>? queryEmbedding,
    int topK = 5,
    double alpha = 0.7,
  }) async {
    final m = topK * 2;

    // 如果未提供 embedding，尝试自动生成
    List<double>? effectiveEmbedding = queryEmbedding;
    if (effectiveEmbedding == null && _embeddingService != null) {
      effectiveEmbedding = await _embeddingService.generateEmbedding(query);
    }

    // 判断 Embedding 是否可用
    final hasEmbedding = effectiveEmbedding != null && effectiveEmbedding.isNotEmpty;
    if (!hasEmbedding) alpha = 0.0;

    // 并行召回
    final semanticFuture = hasEmbedding
        ? _vectorStore.search(effectiveEmbedding, topK: m).catchError((_) => <VectorSearchResult>[])
        : Future.value(<VectorSearchResult>[]);
    final tfidfFuture = _tfidfSearch.search(query, topK: m).catchError((_) => <TfidfSearchResult>[]);

    final results = await Future.wait([semanticFuture, tfidfFuture]);
    final semanticResults = results[0] as List<VectorSearchResult>;
    final tfidfResults = results[1] as List<TfidfSearchResult>;

    // 归一化各自分数到 [0, 1]
    final normSemantic = _normalize(semanticResults.map((r) => r.score).toList());
    final normTfidf = _normalize(tfidfResults.map((r) => r.score).toList());

    // 合并去重，加权求和
    final merged = <String, SearchResult>{};

    for (int i = 0; i < semanticResults.length; i++) {
      final r = semanticResults[i];
      final key = '${r.docId}_${r.chunkIndex}';
      final text = await _getChunkText(r.docId, r.chunkIndex);
      merged[key] = SearchResult(
        docId: r.docId,
        chunkIndex: r.chunkIndex,
        score: normSemantic[i] * alpha,
        text: text,
      );
    }

    for (int i = 0; i < tfidfResults.length; i++) {
      final r = tfidfResults[i];
      final key = '${r.docId}_${r.chunkIndex}';
      if (merged.containsKey(key)) {
        merged[key] = SearchResult(
          docId: r.docId,
          chunkIndex: r.chunkIndex,
          score: merged[key]!.score + normTfidf[i] * (1 - alpha),
          text: merged[key]!.text,
        );
      } else {
        merged[key] = SearchResult(
          docId: r.docId,
          chunkIndex: r.chunkIndex,
          score: normTfidf[i] * (1 - alpha),
          text: r.text,
        );
      }
    }

    final sorted = merged.values.toList()..sort((a, b) => b.score.compareTo(a.score));
    return sorted.take(topK).toList();
  }

  /// 索引文档：分块 → 写入 doc_chunks + doc_vectors。
  ///
  /// 如果未提供 embedding 且 EmbeddingFallbackService 可用，会自动生成。
  Future<void> indexDocument(int docId, String text, {List<double>? embedding}) async {
    final chunks = _chunker.chunk(text);
    for (final chunk in chunks) {
      await _tfidfSearch.indexDocument(docId, chunk.text);

      // 尝试为每个 chunk 生成 embedding
      List<double>? chunkEmbedding = embedding;
      if (chunkEmbedding == null && _embeddingService != null) {
        chunkEmbedding = await _embeddingService.generateEmbedding(chunk.text);
      }

      if (chunkEmbedding != null && chunkEmbedding.isNotEmpty) {
        await _vectorStore.insert(docId, chunk.index, chunkEmbedding);
      }
    }
  }

  /// 删除文档索引（同时清理两个表）。
  Future<void> deleteByDoc(int docId) async {
    await _vectorStore.deleteByDoc(docId);
    await _tfidfSearch.deleteByDoc(docId);
  }

  // ── 内部方法 ──────────────────────────────────────────────────────

  /// 归一化分数列表到 [0, 1]。
  List<double> _normalize(List<double> scores) {
    if (scores.isEmpty) return [];
    final maxVal = scores.reduce(math.max);
    if (maxVal <= 0) return scores.map((_) => 0.0).toList();
    return scores.map((s) => s / maxVal).toList();
  }

  /// 从 doc_chunks 读取指定块的原文。
  Future<String> _getChunkText(int docId, int chunkIndex) async {
    final chunks = await _tfidfSearch.getChunks(docId);
    for (final c in chunks) {
      if (c.chunkIndex == chunkIndex) return c.text;
    }
    return '';
  }
}

/// 混合检索结果。
class SearchResult {
  final int docId;
  final int chunkIndex;
  final double score;
  final String text;
  const SearchResult({required this.docId, required this.chunkIndex, required this.score, this.text = ''});
}
