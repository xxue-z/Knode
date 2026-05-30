import 'dart:async';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:core/ai/ai_provider.dart';
import 'package:core/database/app_database.dart';
import 'package:sqflite/sqflite.dart';

/// Embedding 回退服务：本地模型 → 云端 API → 仅 TF-IDF。
///
/// 提供多级回退机制，确保 RAG 流水线在任何情况下都能运行。
/// 支持 embedding 缓存，避免重复计算。
class EmbeddingFallbackService {
  final AIProvider? _localProvider;
  final AIProvider? _cloudProvider;

  Database get _db => AppDatabase.instance.db;

  EmbeddingFallbackService({
    required AIProvider? localProvider,
    required AIProvider? cloudProvider,
  })  : _localProvider = localProvider,
        _cloudProvider = cloudProvider;

  /// 生成 embedding，自动回退。
  ///
  /// 返回 null 表示所有 embedding 源都不可用，应降级为纯 TF-IDF。
  Future<List<double>?> generateEmbedding(String text) async {
    if (text.trim().isEmpty) return null;

    // 1. 检查缓存
    final cached = await _getCachedEmbedding(text);
    if (cached != null && cached.isNotEmpty) return cached;

    // 2. 尝试本地模型
    final localProvider = _localProvider;
    if (localProvider != null) {
      try {
        final embedding = await localProvider.generateEmbedding(text: text);
        if (embedding.isNotEmpty) {
          await _cacheEmbedding(text, embedding);
          return embedding;
        }
      } catch (e) {
        // 本地模型失败，继续尝试云端
      }
    }

    // 3. 尝试云端 API（带重试）
    final cloudProvider = _cloudProvider;
    if (cloudProvider != null) {
      try {
        final embedding = await _generateWithRetry(cloudProvider, text);
        if (embedding.isNotEmpty) {
          await _cacheEmbedding(text, embedding);
          return embedding;
        }
      } catch (e) {
        // 云端也失败
      }
    }

    // 4. 所有源都不可用
    return null;
  }

  /// 批量生成 embedding。
  ///
  /// 返回与 texts 等长的列表，null 表示该文本的 embedding 不可用。
  Future<List<List<double>?>> generateEmbeddingBatch(List<String> texts) async {
    final results = <List<double>?>[];
    for (final text in texts) {
      results.add(await generateEmbedding(text));
    }
    return results;
  }

  /// 带重试的云端 embedding 生成。
  ///
  /// 最多重试 3 次，指数退避（2/4/8 秒）。
  Future<List<double>> _generateWithRetry(AIProvider provider, String text) async {
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        final embedding = await provider.generateEmbedding(text: text);
        if (embedding.isNotEmpty) return embedding;
      } catch (e) {
        if (attempt < 2) {
          await Future.delayed(Duration(seconds: 2 * (1 << attempt)));
        }
      }
    }
    return [];
  }

  /// 从缓存获取 embedding。
  Future<List<double>?> _getCachedEmbedding(String text) async {
    try {
      final hash = _hashText(text);
      final rows = await _db.query(
        'embedding_cache',
        where: 'text_hash = ?',
        whereArgs: [hash],
        limit: 1,
      );
      if (rows.isNotEmpty) {
        final embeddingStr = rows.first['embedding'] as String;
        return embeddingStr.split(',').map(double.parse).toList();
      }
    } catch (_) {
      // 表可能不存在
    }
    return null;
  }

  /// 缓存 embedding。
  Future<void> _cacheEmbedding(String text, List<double> embedding) async {
    try {
      final hash = _hashText(text);
      final embeddingStr = embedding.map((e) => e.toStringAsFixed(8)).join(',');
      await _db.insert(
        'embedding_cache',
        {
          'text_hash': hash,
          'embedding': embeddingStr,
          'created_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {
      // 缓存失败不影响主流程
    }
  }

  /// 计算文本的 SHA256 哈希。
  String _hashText(String text) {
    final bytes = utf8.encode(text);
    return sha256.convert(bytes).toString();
  }

  /// 初始化缓存表。
  Future<void> initCacheTable() async {
    await _db.execute('''
      CREATE TABLE IF NOT EXISTS embedding_cache (
        text_hash TEXT PRIMARY KEY,
        embedding TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
  }

  /// 清理过期缓存（超过 30 天）。
  Future<int> cleanExpiredCache() async {
    final expireTime = DateTime.now().millisecondsSinceEpoch - 30 * 24 * 60 * 60 * 1000;
    return _db.delete(
      'embedding_cache',
      where: 'created_at < ?',
      whereArgs: [expireTime],
    );
  }
}
