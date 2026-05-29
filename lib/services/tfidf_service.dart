import 'dart:math' as math;
import 'package:sqflite/sqflite.dart';
import '../data/database/app_database.dart';
import '../core/tokenizer/tokenizer.dart';

/// TF-IDF 计算与 doc_chunks 表存储服务。
///
/// 索引时：对文档分块 → 分词 → 计算 TF → 存入 doc_chunks 表。
/// 查询时：对查询分词 → 加载全局 IDF → 计算 TF-IDF 余弦相似度。
class TfidfService {
  final Tokenizer _tokenizer;
  Map<String, double>? _idfCache;

  TfidfService(this._tokenizer);

  Database get _db => AppDatabase.instance.db;

  /// 创建 doc_chunks 表和 idf_stats 表。
  Future<void> createTable() async {
    await _db.execute('''
      CREATE TABLE IF NOT EXISTS doc_chunks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        doc_id INTEGER NOT NULL,
        chunk_index INTEGER NOT NULL,
        text TEXT NOT NULL,
        tfidf_json TEXT,
        UNIQUE(doc_id, chunk_index)
      )
    ''');
    await _db.execute(
      'CREATE INDEX IF NOT EXISTS idx_doc_chunks_doc_id ON doc_chunks(doc_id)',
    );
    await _db.execute('''
      CREATE TABLE IF NOT EXISTS idf_stats (
        term TEXT PRIMARY KEY,
        doc_count INTEGER NOT NULL
      )
    ''');
  }

  /// 索引文档：分块 → 分词 → 计算 TF → 存入 doc_chunks → 更新全局 IDF。
  Future<void> indexDocument(int docId, String text) async {
    // 先删除旧数据
    await _db.delete('doc_chunks', where: 'doc_id = ?', whereArgs: [docId]);

    final chunks = _splitIntoChunks(text);
    for (int i = 0; i < chunks.length; i++) {
      final chunkText = chunks[i];
      final tokens = _tokenizer.tokenize(chunkText);
      final termFreq = <String, int>{};
      for (final t in tokens) {
        termFreq[t] = (termFreq[t] ?? 0) + 1;
      }
      final tfJson = termFreq.entries.map((e) => '${e.key}:${e.value}').join(',');
      await _db.insert('doc_chunks', {
        'doc_id': docId,
        'chunk_index': i,
        'text': chunkText,
        'tfidf_json': tfJson,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // 更新全局 IDF 统计
    await _updateIdfCache();
    _idfCache = null; // 清除缓存，下次查询时重新加载
  }

  /// 删除文档的所有块并更新 IDF。
  Future<void> deleteByDoc(int docId) async {
    await _db.delete('doc_chunks', where: 'doc_id = ?', whereArgs: [docId]);
    await _updateIdfCache();
    _idfCache = null;
  }

  /// TF-IDF 检索，返回 Top K 结果。
  Future<List<TfidfResult>> search(List<String> queryTokens, {int topK = 10}) async {
    if (queryTokens.isEmpty) return [];

    // 加载 IDF 缓存
    final idf = await _getIdfCache();
    final totalDocs = await _getTotalDocs();
    if (totalDocs == 0) return [];

    // 加载所有块的 TF 数据
    final rows = await _db.query('doc_chunks', columns: ['doc_id', 'chunk_index', 'text', 'tfidf_json']);
    final scored = <TfidfResult>[];

    for (final row in rows) {
      final docId = row['doc_id'] as int;
      final chunkIndex = row['chunk_index'] as int;
      final text = row['text'] as String;
      final tfidfJson = row['tfidf_json'] as String? ?? '';

      // 解析 TF
      final termMap = <String, int>{};
      for (final part in tfidfJson.split(',')) {
        if (part.contains(':')) {
          final kv = part.split(':');
          termMap[kv[0]] = int.tryParse(kv[1]) ?? 0;
        }
      }

      // 计算查询与该块的 TF-IDF 余弦相似度
      double dot = 0, normQ = 0, normD = 0;
      for (final token in queryTokens) {
        final qTf = 1.0; // 查询中每个词出现 1 次
        final dTf = (termMap[token] ?? 0).toDouble();
        final idfVal = idf[token] ?? 0.0;

        final qScore = qTf * idfVal;
        final dScore = dTf > 0 ? (1 + math.log(dTf)) * idfVal : 0.0; // 对数 TF

        dot += qScore * dScore;
        normQ += qScore * qScore;
        normD += dScore * dScore;
      }

      final denom = math.sqrt(normQ) * math.sqrt(normD);
      final score = denom > 0 ? dot / denom : 0.0;

      if (score > 0) {
        scored.add(TfidfResult(docId: docId, chunkIndex: chunkIndex, score: score, text: text));
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(topK).toList();
  }

  /// 获取文档的所有块。
  Future<List<ChunkData>> getChunks(int docId) async {
    final rows = await _db.query('doc_chunks',
        where: 'doc_id = ?', whereArgs: [docId], orderBy: 'chunk_index ASC');
    return rows.map((r) => ChunkData(
      docId: r['doc_id'] as int,
      chunkIndex: r['chunk_index'] as int,
      text: r['text'] as String,
    )).toList();
  }

  // ── 内部方法 ──────────────────────────────────────────────────────

  /// 将文本按段落拆分为块（每块不超过 500 字）。
  List<String> _splitIntoChunks(String text, {int maxChars = 500}) {
    final paragraphs = text.split(RegExp(r'\n{2,}'));
    final chunks = <String>[];
    final buffer = StringBuffer();

    for (final p in paragraphs) {
      final trimmed = p.trim();
      if (trimmed.isEmpty) continue;

      if (buffer.length + trimmed.length > maxChars && buffer.isNotEmpty) {
        chunks.add(buffer.toString().trim());
        buffer.clear();
      }
      buffer.writeln(trimmed);
    }
    if (buffer.isNotEmpty) {
      chunks.add(buffer.toString().trim());
    }

    return chunks.isEmpty ? [text.trim()] : chunks;
  }

  /// 从 idf_stats 表加载 IDF 缓存。
  Future<Map<String, double>> _getIdfCache() async {
    if (_idfCache != null) return _idfCache!;

    final totalDocs = await _getTotalDocs();
    final rows = await _db.query('idf_stats');
    final idf = <String, double>{};
    for (final row in rows) {
      final term = row['term'] as String;
      final docCount = row['doc_count'] as int;
      idf[term] = math.log((totalDocs + 1) / (docCount + 1)) + 1.0;
    }
    _idfCache = idf;
    return idf;
  }

  /// 获取总文档块数。
  Future<int> _getTotalDocs() async {
    final result = await _db.rawQuery('SELECT COUNT(*) as cnt FROM doc_chunks');
    return (result.first['cnt'] as int?) ?? 0;
  }

  /// 从 doc_chunks 表重建 idf_stats。
  Future<void> _updateIdfCache() async {
    await _db.delete('idf_stats');

    final rows = await _db.query('doc_chunks', columns: ['tfidf_json']);
    final termDocCount = <String, int>{};
    for (final row in rows) {
      final tfidfJson = row['tfidf_json'] as String? ?? '';
      final terms = <String>{};
      for (final part in tfidfJson.split(',')) {
        if (part.contains(':')) {
          terms.add(part.split(':')[0]);
        }
      }
      for (final t in terms) {
        termDocCount[t] = (termDocCount[t] ?? 0) + 1;
      }
    }

    final batch = _db.batch();
    for (final entry in termDocCount.entries) {
      batch.insert('idf_stats', {'term': entry.key, 'doc_count': entry.value});
    }
    await batch.commit(noResult: true);
  }

}

/// TF-IDF 检索结果。
class TfidfResult {
  final int docId;
  final int chunkIndex;
  final double score;
  final String text;
  const TfidfResult({required this.docId, required this.chunkIndex, required this.score, required this.text});
}

/// 文档块数据。
class ChunkData {
  final int docId;
  final int chunkIndex;
  final String text;
  const ChunkData({required this.docId, required this.chunkIndex, required this.text});
}
