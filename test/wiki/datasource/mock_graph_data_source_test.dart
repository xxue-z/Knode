import 'package:flutter_test/flutter_test.dart';
import 'package:wiki/graph/datasource/mock_graph_data_source.dart';
import 'package:wiki/graph/models/graph_node.dart';
import 'package:wiki/graph/models/graph_edge.dart';

void main() {
  late MockGraphDataSource dataSource;

  setUp(() {
    dataSource = MockGraphDataSource();
  });

  group('MockGraphDataSource', () {
    test('getNodes returns 36 nodes (6 galaxy + 30 article)', () async {
      final nodes = await dataSource.getNodes();
      expect(nodes.length, 36);

      final galaxyNodes = nodes.where((n) => n.type == V2NodeType.galaxy);
      final articleNodes = nodes.where((n) => n.type == V2NodeType.article);
      expect(galaxyNodes.length, 6);
      expect(articleNodes.length, 30);
    });

    test('getEdges returns edges with expected types', () async {
      final edges = await dataSource.getEdges();
      expect(edges, isNotEmpty);

      final similarity = edges.where((e) => e.type == V2EdgeType.similarity);
      final reference = edges.where((e) => e.type == V2EdgeType.reference);
      expect(similarity.isNotEmpty, true);
      expect(reference.isNotEmpty, true);
    });

    test('getClusters returns 6 clusters', () async {
      final clusters = await dataSource.getClusters();
      expect(clusters.length, 6);
    });

    test('getNodeById returns correct node', () async {
      final node = await dataSource.getNodeById('galaxy_0');
      expect(node, isNotNull);
      expect(node!.id, 'galaxy_0');
      expect(node.label, '笔记');
    });

    test('getNodeById returns null for unknown id', () async {
      final node = await dataSource.getNodeById('nonexistent');
      expect(node, isNull);
    });

    test('searchNodes filters by label', () async {
      final results = await dataSource.searchNodes('笔记');
      expect(results, isNotEmpty);
      expect(results.every((n) => n.label.contains('笔记')), true);
    });
  });
}
