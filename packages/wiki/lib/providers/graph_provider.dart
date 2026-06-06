import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/extensions/riverpod_compat.dart';

import 'package:core/models/document.dart';
import 'package:wiki/widgets/graph_canvas.dart' hide GraphNode, GraphEdge;
import 'package:wiki/widgets/graph_edge.dart';
import 'package:wiki/services/graph_service.dart';
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

  /// Build graph from a pre-loaded document list (avoids stale provider reads).
  void buildGraphFromDocs(List<Document> documents) {
    if (documents.isEmpty) {
      state = const AsyncData(GraphState());
      return;
    }
    final result = GraphService.buildGraph(documents: documents);
    state = AsyncData(GraphState(
      nodes: result.nodes
          .map((n) => GraphNode(
                id: n.id,
                title: n.title,
                summary: n.summary,
                categoryId: n.categoryId,
                position: n.position,
                tags: n.tags,
              ))
          .toList(),
      edges: result.edges
          .map((e) => GraphEdge(
                sourceId: e.sourceId,
                targetId: e.targetId,
                type: e.type,
                similarity: e.similarity,
              ))
          .toList(),
      isClusterMode: result.isClusterMode,
    ));
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

    final result = GraphService.buildGraph(documents: documents);

    return GraphState(
      nodes: result.nodes
          .map((n) => GraphNode(
                id: n.id,
                title: n.title,
                summary: n.summary,
                categoryId: n.categoryId,
                position: n.position,
                tags: n.tags,
              ))
          .toList(),
      edges: result.edges
          .map((e) => GraphEdge(
                sourceId: e.sourceId,
                targetId: e.targetId,
                type: e.type,
                similarity: e.similarity,
              ))
          .toList(),
      isClusterMode: result.isClusterMode,
    );
  }
}

/// Graph provider that manages the knowledge graph state.
final graphProvider = AsyncNotifierProvider<GraphNotifier, GraphState>(
  GraphNotifier.new,
);
