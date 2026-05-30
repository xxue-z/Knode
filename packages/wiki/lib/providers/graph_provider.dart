import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:core/models/document.dart';
import 'package:wiki/widgets/graph_canvas.dart' hide GraphNode, GraphEdge;
import 'package:wiki/widgets/graph_edge.dart';
import 'package:wiki/providers/document_provider.dart';

/// Strongly-typed graph node derived from a [Document].
class GraphNode {
  const GraphNode({
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

/// Strongly-typed graph edge between two nodes.
class GraphEdge {
  const GraphEdge({
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

/// Immutable state for the knowledge graph.
class GraphState {
  const GraphState({
    this.nodes = const [],
    this.edges = const [],
    this.isClusterMode = false,
  });

  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final bool isClusterMode;

  GraphState copyWith({
    List<GraphNode>? nodes,
    List<GraphEdge>? edges,
    bool? isClusterMode,
  }) {
    return GraphState(
      nodes: nodes ?? this.nodes,
      edges: edges ?? this.edges,
      isClusterMode: isClusterMode ?? this.isClusterMode,
    );
  }
}

/// AsyncNotifier that builds and manages the knowledge graph.
class GraphNotifier extends AsyncNotifier<GraphState> {
  String _categoryId = '';

  @override
  Future<GraphState> build() async {
    if (_categoryId.isEmpty) return const GraphState();
    return _loadGraph(_categoryId);
  }

  /// Loads documents for [categoryId] and builds the graph.
  Future<void> buildGraph(String categoryId) async {
    _categoryId = categoryId;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loadGraph(categoryId));
  }

  /// Add a node to the graph.
  void addNode(GraphNode node) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      nodes: [...current.nodes, node],
    ));
    ref.invalidateSelf();
  }

  /// Remove a node and its connected edges from the graph.
  void removeNode(String nodeId) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      nodes: current.nodes.where((n) => n.id != nodeId).toList(),
      edges: current.edges
          .where((e) => e.sourceId != nodeId && e.targetId != nodeId)
          .toList(),
    ));
    ref.invalidateSelf();
  }

  /// Add an edge to the graph.
  void addEdge(GraphEdge edge) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      edges: [...current.edges, edge],
    ));
    ref.invalidateSelf();
  }

  /// Remove a specific edge by source and target IDs.
  void removeEdge(String sourceId, String targetId) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      edges: current.edges
          .where((e) => !(e.sourceId == sourceId && e.targetId == targetId))
          .toList(),
    ));
    ref.invalidateSelf();
  }

  /// Refresh the graph from the data source.
  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<GraphState> _loadGraph(String categoryId) async {
    final docAsync = ref.read(documentListProvider);
    final docState = docAsync.value;
    if (docState == null || docState.documents.isEmpty) {
      return const GraphState();
    }

    final catId = int.tryParse(categoryId);
    final documents = catId != null
        ? docState.documents.where((d) => d.categoryId == catId).toList()
        : docState.documents;

    if (documents.isEmpty) return const GraphState();

    final useCluster = documents.length > 50;
    final rng = math.Random(42);
    final spread = math.max(200.0, documents.length * 40.0);

    // Build nodes.
    final nodes = <GraphNode>[];
    for (final doc in documents) {
      final contentTags = doc.contentText != null
          ? _tokenize(doc.contentText!).toList()
          : <String>[];
      nodes.add(GraphNode(
        id: doc.id.toString(),
        title: doc.title,
        summary: doc.summary,
        categoryId: doc.categoryId,
        position: Offset(
          rng.nextDouble() * spread - spread / 2,
          rng.nextDouble() * spread - spread / 2,
        ),
        tags: contentTags,
      ));
    }

    // Build edges.
    final edges = <GraphEdge>[];

    // 1) Category cluster edges (when node count > 50).
    if (useCluster) {
      final categoryGroups = <int, List<GraphNode>>{};
      for (final node in nodes) {
        final catId = node.categoryId;
        if (catId != null) {
          categoryGroups.putIfAbsent(catId, () => []).add(node);
        }
      }
      for (final group in categoryGroups.values) {
        for (int i = 0; i < group.length - 1; i++) {
          edges.add(GraphEdge(
            sourceId: group[i].id,
            targetId: group[i + 1].id,
            type: EdgeType.categoryCluster,
          ));
        }
      }
    }

    // 2) Tag similarity edges (Jaccard > 0.3).
    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        final similarity = _jaccardSimilarity(
          nodes[i].tags.toSet(),
          nodes[j].tags.toSet(),
        );
        if (similarity > 0.3) {
          edges.add(GraphEdge(
            sourceId: nodes[i].id,
            targetId: nodes[j].id,
            type: EdgeType.tagSimilarity,
            similarity: similarity,
          ));
        }
      }
    }

    // 3) Markdown [link](path) reference edges.
    final titleToNode = <String, GraphNode>{};
    for (final node in nodes) {
      titleToNode[node.title] = node;
    }
    for (int i = 0; i < documents.length; i++) {
      final text = documents[i].contentText ?? '';
      final refs = _extractMarkdownRefs(text);
      for (final refTitle in refs) {
        final target = titleToNode[refTitle];
        if (target != null) {
          edges.add(GraphEdge(
            sourceId: documents[i].id.toString(),
            targetId: target.id,
            type: EdgeType.reference,
          ));
        }
      }
    }

    return GraphState(
      nodes: nodes,
      edges: edges,
      isClusterMode: useCluster,
    );
  }

  /// Jaccard similarity between two token sets.
  static double _jaccardSimilarity(Set<String> a, Set<String> b) {
    if (a.isEmpty || b.isEmpty) return 0.0;
    final intersection = a.intersection(b).length;
    final union = a.union(b).length;
    return union == 0 ? 0.0 : intersection / union;
  }

  /// Tokenize text into a set of lowercase keywords.
  static Set<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\u4e00-\u9fff]'), ' ')
        .split(RegExp(r'\s+'))
        .where((s) => s.length > 1)
        .toSet();
  }

  /// Extract Markdown [link](path) references from text.
  static List<String> _extractMarkdownRefs(String text) {
    final regex = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');
    return regex.allMatches(text).map((m) => m.group(1)!).toList();
  }
}

/// Graph provider that manages the knowledge graph state.
final graphProvider = AsyncNotifierProvider<GraphNotifier, GraphState>(
  GraphNotifier.new,
);
