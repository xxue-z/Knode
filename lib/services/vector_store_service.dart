import 'dart:math';
import 'package:sqflite/sqflite.dart';
import '../data/database/app_database.dart';

class VectorStoreService {
  Database get _db => AppDatabase.instance.db;

  Future<void> createTable() async {
    await _db.execute('CREATE TABLE IF NOT EXISTS doc_vectors (id INTEGER PRIMARY KEY AUTOINCREMENT, doc_id INTEGER NOT NULL, chunk_index INTEGER DEFAULT 0, embedding TEXT NOT NULL)');
    await _db.execute('CREATE INDEX IF NOT EXISTS idx_doc_vectors_doc_id ON doc_vectors(doc_id)');
    await _db.execute('CREATE TABLE IF NOT EXISTS doc_chunks (id INTEGER PRIMARY KEY AUTOINCREMENT, doc_id INTEGER NOT NULL, chunk_index INTEGER NOT NULL, text TEXT NOT NULL, tfidf_json TEXT, UNIQUE(doc_id, chunk_index))');
    await _db.execute('CREATE INDEX IF NOT EXISTS idx_doc_chunks_doc_id ON doc_chunks(doc_id)');
  }

  Future<void> insert(int docId, int chunkIndex, List<double> embedding) async {
    final json = embedding.map((e) => e.toStringAsFixed(8)).join(',');
    await _db.insert('doc_vectors', {'doc_id': docId, 'chunk_index': chunkIndex, 'embedding': json});
  }

  Future<void> deleteByDoc(int docId) async {
    await _db.delete('doc_vectors', where: 'doc_id = ?', whereArgs: [docId]);
  }

  Future<List<VectorSearchResult>> search(List<double> queryEmbedding, {int topK = 5}) async {
    final rows = await _db.query('doc_vectors', orderBy: 'id ASC');
    final scored = <VectorSearchResult>[];
    for (final row in rows) {
      final embStr = row['embedding'] as String;
      final emb = embStr.split(',').map(double.parse).toList();
      final score = _cosineSimilarity(queryEmbedding, emb);
      scored.add(VectorSearchResult(docId: row['doc_id'] as int, chunkIndex: row['chunk_index'] as int, score: score));
    }
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(topK).toList();
  }

  static double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.isEmpty || b.isEmpty || a.length != b.length) return 0.0;
    double dot = 0, normA = 0, normB = 0;
    for (int i = 0; i < a.length; i++) { dot += a[i] * b[i]; normA += a[i] * a[i]; normB += b[i] * b[i]; }
    final denom = normA * normB;
    return denom == 0 ? 0.0 : dot / (sqrt(normA) * sqrt(normB));
  }
}

class VectorSearchResult {
  final int docId;
  final int chunkIndex;
  final double score;
  const VectorSearchResult({required this.docId, required this.chunkIndex, required this.score});
}