import 'package:flutter_test/flutter_test.dart';
import 'package:wiki/graph/services/similarity_service.dart';

void main() {
  group('SimilarityService', () {
    test('jaccardSimilarity returns 1.0 for identical sets', () {
      final a = {'a', 'b', 'c'};
      expect(SimilarityService.jaccardSimilarity(a, a), 1.0);
    });

    test('jaccardSimilarity returns 0.0 for disjoint sets', () {
      final a = {'a', 'b', 'c'};
      final b = {'d', 'e', 'f'};
      expect(SimilarityService.jaccardSimilarity(a, b), 0.0);
    });

    test('jaccardSimilarity computes correct overlap', () {
      final a = {'a', 'b', 'c'};
      final b = {'b', 'c', 'd'};
      // intersection = {b, c} = 2, union = {a, b, c, d} = 4 => 2/4 = 0.5
      expect(SimilarityService.jaccardSimilarity(a, b), 0.5);
    });

    test('jaccardSimilarity returns 0.0 for empty sets', () {
      expect(SimilarityService.jaccardSimilarity({}, {'a', 'b'}), 0.0);
      expect(SimilarityService.jaccardSimilarity({'a', 'b'}, {}), 0.0);
      expect(SimilarityService.jaccardSimilarity({}, {}), 0.0);
    });
  });
}
