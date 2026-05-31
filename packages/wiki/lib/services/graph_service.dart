import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:core/models/document.dart';
import 'package:wiki/widgets/graph_edge.dart';

/// 图谱连线计算服务，负责从文档列表生成节点和连线。
class GraphService {
  /// 构建完整图谱状态。
  ///
  /// [documents] 为待展示的文档列表，[forceCluster] 控制是否强制使用聚类模式。
  static GraphResult buildGraph({
    required List<Document> documents,
    bool? forceCluster,
  }) {
    if (documents.isEmpty) {
      return const GraphResult(nodes: [], edges: [], isClusterMode: false);
    }

    final useCluster = forceCluster ?? documents.length > 50;
    final rng = math.Random(42);
    final spread = math.max(200.0, documents.length * 40.0);

    // Build nodes.
    final nodes = <GraphResultNode>[];
    for (final doc in documents) {
      // 降级策略：tags 为空且非手动编辑时，使用分词结果。
      final tags = doc.tags.isNotEmpty
          ? doc.tags
          : (doc.manualTags == 0 ? _fallbackTokenize(doc.contentText ?? '') : <String>[]);

      nodes.add(GraphResultNode(
        id: doc.id.toString(),
        title: doc.title,
        summary: doc.summary,
        categoryId: doc.categoryId,
        position: Offset(
          rng.nextDouble() * spread - spread / 2,
          rng.nextDouble() * spread - spread / 2,
        ),
        tags: tags,
      ));
    }

    // Build edges.
    final edges = <GraphResultEdge>[];

    // 1) Category cluster edges (when node count > 50).
    if (useCluster) {
      edges.addAll(computeCategoryClusterEdges(nodes));
    }

    // 2) Tag similarity edges (Jaccard > 0.3).
    edges.addAll(computeTagSimilarityEdges(documents));

    // 3) Reference edges from document.linksTo field.
    edges.addAll(computeReferenceEdges(documents));

    return GraphResult(
      nodes: nodes,
      edges: edges,
      isClusterMode: useCluster,
    );
  }

  /// 从文档标签计算相似度连线。
  static List<GraphResultEdge> computeTagSimilarityEdges(
    List<Document> documents, {
    double threshold = 0.3,
  }) {
    final edges = <GraphResultEdge>[];
    for (int i = 0; i < documents.length; i++) {
      for (int j = i + 1; j < documents.length; j++) {
        final tagsA = documents[i].tags.toSet();
        final tagsB = documents[j].tags.toSet();
        final similarity = jaccardSimilarity(tagsA, tagsB);
        if (similarity > threshold) {
          edges.add(GraphResultEdge(
            sourceId: documents[i].id.toString(),
            targetId: documents[j].id.toString(),
            type: EdgeType.tagSimilarity,
            similarity: similarity,
          ));
        }
      }
    }
    return edges;
  }

  /// 从 documents.linksTo 字段构建引用关系连线。
  static List<GraphResultEdge> computeReferenceEdges(
    List<Document> documents,
  ) {
    final edges = <GraphResultEdge>[];
    for (final doc in documents) {
      for (final targetId in doc.linksTo) {
        edges.add(GraphResultEdge(
          sourceId: doc.id.toString(),
          targetId: targetId.toString(),
          type: EdgeType.reference,
        ));
      }
    }
    return edges;
  }

  /// 按 category_id 构建同类目聚类连线。
  static List<GraphResultEdge> computeCategoryClusterEdges(
    List<GraphResultNode> nodes,
  ) {
    final edges = <GraphResultEdge>[];
    final categoryGroups = <int, List<GraphResultNode>>{};
    for (final node in nodes) {
      final catId = node.categoryId;
      if (catId != null) {
        categoryGroups.putIfAbsent(catId, () => []).add(node);
      }
    }
    for (final group in categoryGroups.values) {
      for (int i = 0; i < group.length - 1; i++) {
        edges.add(GraphResultEdge(
          sourceId: group[i].id,
          targetId: group[i + 1].id,
          type: EdgeType.categoryCluster,
        ));
      }
    }
    return edges;
  }

  /// Jaccard similarity between two token sets.
  static double jaccardSimilarity(Set<String> a, Set<String> b) {
    if (a.isEmpty || b.isEmpty) return 0.0;
    final intersection = a.intersection(b).length;
    final union = a.union(b).length;
    return union == 0 ? 0.0 : intersection / union;
  }

  /// 降级分词：简单的中文/英文分词。
  static List<String> _fallbackTokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\u4e00-\u9fff]'), ' ')
        .split(RegExp(r'\s+'))
        .where((s) => s.length > 1)
        .toSet()
        .toList()
      ..take(5);
  }

  /// Extract Markdown [link](path) references from text.
  /// 保留作为工具方法供外部使用。
  static List<String> extractMarkdownRefs(String text) {
    final regex = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');
    return regex.allMatches(text).map((m) => m.group(1)!).toList();
  }
}

/// Graph node data produced by [GraphService].
class GraphResultNode {
  const GraphResultNode({
    required this.id,
    required this.title,
    this.summary,
    this.categoryId,
    this.position = Offset.zero,
    this.tags = const [],
  });

  final String id;
  final String title;
  final String? summary;
  final int? categoryId;
  final Offset position;
  final List<String> tags;
}

/// Graph edge data produced by [GraphService].
class GraphResultEdge {
  const GraphResultEdge({
    required this.sourceId,
    required this.targetId,
    required this.type,
    this.similarity,
  });

  final String sourceId;
  final String targetId;
  final EdgeType type;
  final double? similarity;
}

/// Combined result of graph computation.
class GraphResult {
  const GraphResult({
    required this.nodes,
    required this.edges,
    required this.isClusterMode,
  });

  final List<GraphResultNode> nodes;
  final List<GraphResultEdge> edges;
  final bool isClusterMode;
}
