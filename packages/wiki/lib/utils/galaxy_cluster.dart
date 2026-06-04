import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Galaxy clustering algorithm for positioning nodes in the knowledge graph.
///
/// Positions category nodes as galaxy centers and article nodes
/// in orbital clusters around their parent category.
class GalaxyCluster {
  GalaxyCluster._();

  /// Compute positions for all nodes in the graph.
  ///
  /// [categoryNodes] are positioned as galaxy centers in a circle.
  /// [articleNodes] are positioned in orbits around their parent category.
  static Map<String, Offset> computePositions({
    required List<GraphNodeData> categoryNodes,
    required List<GraphNodeData> articleNodes,
    double galaxyRadius = 300.0,
    double orbitRadius = 100.0,
  }) {
    final positions = <String, Offset>{};

    // Position category nodes in a circle
    final categoryAngleStep = 2 * math.pi / categoryNodes.length;
    for (int i = 0; i < categoryNodes.length; i++) {
      final angle = i * categoryAngleStep - math.pi / 2; // Start from top
      final x = galaxyRadius * math.cos(angle);
      final y = galaxyRadius * math.sin(angle);
      positions[categoryNodes[i].id] = Offset(x + galaxyRadius, y + galaxyRadius);
    }

    // Position article nodes in orbits around their category
    final articlesByCategory = <int, List<GraphNodeData>>{};
    for (final article in articleNodes) {
      final catId = article.categoryId ?? 0;
      articlesByCategory.putIfAbsent(catId, () => []).add(article);
    }

    for (final entry in articlesByCategory.entries) {
      final catPosition = positions.entries
          .where((e) => e.key == entry.value.first.categoryId.toString())
          .map((e) => e.value)
          .firstOrNull;

      if (catPosition == null) continue;

      final articles = entry.value;
      final orbitAngleStep = 2 * math.pi / articles.length;

      for (int i = 0; i < articles.length; i++) {
        final angle = i * orbitAngleStep;
        final x = orbitRadius * math.cos(angle);
        final y = orbitRadius * math.sin(angle);
        positions[articles[i].id] = Offset(
          catPosition.dx + x,
          catPosition.dy + y,
        );
      }
    }

    return positions;
  }
}

/// Simple node data for clustering computation.
class GraphNodeData {
  const GraphNodeData({
    required this.id,
    this.categoryId,
  });

  final String id;
  final int? categoryId;
}
