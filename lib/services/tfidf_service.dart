import 'package:sqflite/sqflite.dart';
import '../data/database/app_database.dart';
import '../core/tokenizer/tokenizer.dart';

class TfidfService {
  final Tokenizer _tokenizer;
  final Map<String, Map<int, int>> _globalTermFreq = {};
  int _totalDocs = 0;

  TfidfService(this._tokenizer);

  Database get _db => AppDatabase.instance.db;

  Future<void> indexDocument(int docId, String text) async {
    final tokens = _tokenizer.tokenize(text);
    final termFreq = <String, int>{};
    for (final t in tokens) {
      termFreq[t] = (termFreq[t] ?? 0) + 1;
    }
    for (final entry in termFreq.entries) {
      _globalTermFreq.putIfAbsent(entry.key, () => {})[docId] = entry.value;
    }
    _totalDocs++;
    final json = termFreq.entries.map((e) => '${e.key}:${e.value}').join(',');
    await _db.insert('doc_chunks', {'doc_id': docId, 'chunk_index': 0, 'text': text, 'tfidf_json': json},
      conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteByDoc(int docId) async {
    await _db.delete('doc_chunks', where: 'doc_id = ?', whereArgs: [docId]);
    for (final termMap in _globalTermFreq.values) {
      termMap.remove(docId);
    }
  }

  Future<List<TfidfResult>> search(List<String> tokens, {int topK = 10}) async {
    final scores = <int, double>{};
    final docTermCounts = <int, Map<String, int>>{};
    final rows = await _db.query('doc_chunks');
    for (final row in rows) {
      final docId = row['doc_id'] as int;
      final tfidfJson = row['tfidf_json'] as String? ?? '';
      final termMap = <String, int>{};
      for (final part in tfidfJson.split(',')) {
        if (part.contains(':')) {
          final kv = part.split(':');
          termMap[kv[0]] = int.tryParse(kv[1]) ?? 0;
        }
      }
      docTermCounts[docId] = termMap;
    }
    for (final docEntry in docTermCounts.entries) {
      double score = 0;
      for (final token in tokens) {
        final tf = docEntry.value[token] ?? 0;
        if (tf == 0) continue;
        final df = _globalTermFreq[token]?.length ?? 0;
        final idf = _totalDocs > 0 ? (_totalDocs / (1 + df)) : 1.0;
        score += (tf / (tf + 1.0)) * idf;
      }
      if (score > 0) scores[docEntry.key] = score;
    }
    final sorted = scores.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(topK).map((e) => TfidfResult(docId: e.key, score: e.value)).toList();
  }
}

class TfidfResult {
  final int docId;
  final double score;
  const TfidfResult({required this.docId, required this.score});
}