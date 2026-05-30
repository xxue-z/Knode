import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/tokenizer/tokenizer.dart';
import '../core/tokenizer/ngram_tokenizer.dart';
import '../services/vector_store_service.dart';
import '../services/tfidf_service.dart';
import '../services/tfidf_search_service.dart';
import '../services/text_chunker.dart';
import '../services/hybrid_search_service.dart';
import '../services/rag_service.dart';
import '../services/embedding_fallback_service.dart';
import '../ai/ai_provider.dart';

/// Tokenizer 实例。
final tokenizerProvider = Provider<Tokenizer>((ref) {
  return NgramTokenizer();
});

/// VectorStoreService 实例。
final vectorStoreServiceProvider = Provider<VectorStoreService>((ref) {
  return VectorStoreService();
});

/// TfidfService 实例。
final tfidfServiceProvider = Provider<TfidfService>((ref) {
  return TfidfService(ref.read(tokenizerProvider));
});

/// TfidfSearchService 实例。
final tfidfSearchServiceProvider = Provider<TfidfSearchService>((ref) {
  return TfidfSearchService(
    ref.read(tfidfServiceProvider),
    ref.read(tokenizerProvider),
  );
});

/// TextChunker 实例。
final textChunkerProvider = Provider<TextChunker>((ref) {
  return TextChunker();
});

/// 本地 AIProvider 实例（用于 embedding 回退）。
final localAiProviderRef = Provider<AIProvider?>((ref) {
  return null; // main.dart 中覆盖
});

/// EmbeddingFallbackService 实例。
final embeddingFallbackServiceProvider = Provider<EmbeddingFallbackService>((ref) {
  return EmbeddingFallbackService(
    localProvider: ref.read(localAiProviderRef),
    cloudProvider: ref.read(aiProviderRef),
  );
});

/// HybridSearchService 实例。
final hybridSearchServiceProvider = Provider<HybridSearchService>((ref) {
  return HybridSearchService(
    ref.read(vectorStoreServiceProvider),
    ref.read(tfidfSearchServiceProvider),
    ref.read(textChunkerProvider),
    ref.read(embeddingFallbackServiceProvider),
  );
});

/// RagService 实例。
final ragServiceProvider = Provider<RagService>((ref) {
  return RagService(
    aiProvider: ref.read(aiProviderRef),
    searchService: ref.read(hybridSearchServiceProvider),
  );
});

/// AIProvider 实例（需要在 main.dart 中覆盖）。
final aiProviderRef = Provider<AIProvider>((ref) {
  throw UnimplementedError('请在 main.dart 中覆盖 AIProvider');
});
