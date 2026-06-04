import 'package:flutter_test/flutter_test.dart';
import 'package:wiki/utils/galaxy_cluster.dart';

void main() {
  group('GalaxyCluster', () {
    test('computePositions returns positions for all nodes', () {
      final categories = [
        GraphNodeData(id: '1'),
        GraphNodeData(id: '2'),
      ];
      final articles = [
        GraphNodeData(id: 'a1', categoryId: 1),
        GraphNodeData(id: 'a2', categoryId: 1),
        GraphNodeData(id: 'a3', categoryId: 2),
      ];

      final positions = GalaxyCluster.computePositions(
        categoryNodes: categories,
        articleNodes: articles,
      );

      expect(positions.length, equals(5));
      expect(positions.containsKey('1'), isTrue);
      expect(positions.containsKey('2'), isTrue);
      expect(positions.containsKey('a1'), isTrue);
      expect(positions.containsKey('a2'), isTrue);
      expect(positions.containsKey('a3'), isTrue);
    });

    test('category nodes are positioned in a circle', () {
      final categories = [
        GraphNodeData(id: '1'),
        GraphNodeData(id: '2'),
        GraphNodeData(id: '3'),
      ];

      final positions = GalaxyCluster.computePositions(
        categoryNodes: categories,
        articleNodes: [],
      );

      final center = Offset(300, 300);
      for (final pos in positions.values) {
        final distance = (pos - center).distance;
        expect(distance, closeTo(300, 1));
      }
    });

    test('article nodes are positioned near their category', () {
      final categories = [GraphNodeData(id: '1')];
      final articles = [GraphNodeData(id: 'a1', categoryId: 1)];

      final positions = GalaxyCluster.computePositions(
        categoryNodes: categories,
        articleNodes: articles,
      );

      final catPos = positions['1']!;
      final artPos = positions['a1']!;
      final distance = (catPos - artPos).distance;

      expect(distance, lessThanOrEqualTo(100));
    });
  });
}
