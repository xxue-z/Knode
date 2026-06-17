import 'package:flutter_test/flutter_test.dart';
import 'package:wiki/graph/models/graph_view_state.dart';
import 'package:wiki/graph/services/lod_service.dart';

void main() {
  group('LODService', () {
    group('computeLodLevel', () {
      test('scale 0.1 returns stars', () {
        expect(LODService.computeLodLevel(0.1), LodLevel.stars);
      });

      test('scale 0.5 returns nodes', () {
        expect(LODService.computeLodLevel(0.5), LodLevel.nodes);
      });

      test('scale 2.0 returns detail', () {
        expect(LODService.computeLodLevel(2.0), LodLevel.detail);
      });

      test('scale exactly 0.3 returns nodes (boundary)', () {
        expect(LODService.computeLodLevel(0.3), LodLevel.nodes);
      });

      test('scale exactly 1.0 returns detail (boundary)', () {
        expect(LODService.computeLodLevel(1.0), LodLevel.detail);
      });
    });

    group('shouldShowEdges', () {
      test('returns false for stars', () {
        expect(LODService.shouldShowEdges(LodLevel.stars), false);
      });

      test('returns true for nodes', () {
        expect(LODService.shouldShowEdges(LodLevel.nodes), true);
      });

      test('returns true for detail', () {
        expect(LODService.shouldShowEdges(LodLevel.detail), true);
      });
    });

    group('shouldShowLabels', () {
      test('returns false for stars', () {
        expect(LODService.shouldShowLabels(LodLevel.stars), false);
      });

      test('returns false for nodes', () {
        expect(LODService.shouldShowLabels(LodLevel.nodes), false);
      });

      test('returns true for detail', () {
        expect(LODService.shouldShowLabels(LodLevel.detail), true);
      });
    });
  });
}
