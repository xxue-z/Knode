import 'package:flutter_test/flutter_test.dart';
import 'package:wiki/graph/models/graph_edge.dart';

void main() {
  group('V2GraphEdge', () {
    test('can be created with required params', () {
      final edge = V2GraphEdge(
        sourceId: 'node_1',
        targetId: 'node_2',
        type: V2EdgeType.reference,
      );

      expect(edge.sourceId, 'node_1');
      expect(edge.targetId, 'node_2');
      expect(edge.type, V2EdgeType.reference);
      expect(edge.weight, 1.0);
      expect(edge.opacity, 0.5);
    });
  });

}
