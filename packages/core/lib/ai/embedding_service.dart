import 'ai_provider.dart';

class EmbeddingService {
  final AIProvider _provider;
  EmbeddingService(this._provider);

  Future<List<double>> embedText(String text) async {
    if (text.trim().isEmpty) return [];
    return _provider.generateEmbedding(text: text);
  }

  Future<List<List<double>>> embedBatch(List<String> texts) async {
    final results = <List<double>>[];
    for (final text in texts) {
      results.add(await embedText(text));
    }
    return results;
  }

  static const int chunkSize = 500;

  List<String> chunkText(String text) {
    if (text.length <= chunkSize) return [text];
    final chunks = <String>[];
    final paragraphs = text.split('\n\n');
    var buffer = '';
    for (final para in paragraphs) {
      if (buffer.length + para.length > chunkSize && buffer.isNotEmpty) {
        chunks.add(buffer.trim());
        buffer = '';
      }
      buffer += '$para\n\n';
    }
    if (buffer.trim().isNotEmpty) chunks.add(buffer.trim());
    return chunks;
  }
}