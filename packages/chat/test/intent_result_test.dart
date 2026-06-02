import 'package:flutter_test/flutter_test.dart';
import 'package:core/models/intent_result.dart';

void main() {
  group('IntentResult Model Tests', () {
    test('IntentResult should be created with required fields', () {
      final result = IntentResult(
        type: 'qa',
        keywords: ['flutter', 'dart'],
      );

      expect(result.type, equals('qa'));
      expect(result.keywords, equals(['flutter', 'dart']));
      expect(result.suggestedCategory, isNull);
    });

    test('IntentResult should handle optional category', () {
      final result = IntentResult(
        type: 'search',
        suggestedCategory: 'programming',
        keywords: ['tutorial'],
      );

      expect(result.type, equals('search'));
      expect(result.suggestedCategory, equals('programming'));
      expect(result.keywords, equals(['tutorial']));
    });

    test('IntentResult should convert to Map correctly', () {
      final result = IntentResult(
        type: 'qa',
        suggestedCategory: 'tech',
        keywords: ['flutter'],
      );

      final map = result.toMap();

      expect(map['type'], equals('qa'));
      expect(map['suggestedCategory'], equals('tech'));
      expect(map['keywords'], equals(['flutter']));
    });

    test('IntentResult should be created from Map correctly', () {
      final map = {
        'type': 'quiz',
        'suggestedCategory': null,
        'keywords': ['test', 'exam'],
      };

      final result = IntentResult.fromMap(map);

      expect(result.type, equals('quiz'));
      expect(result.suggestedCategory, isNull);
      expect(result.keywords, equals(['test', 'exam']));
    });

    test('IntentResult copyWith should update specified fields only', () {
      final original = IntentResult(
        type: 'qa',
        keywords: ['flutter'],
      );

      final updated = original.copyWith(
        type: 'search',
        keywords: ['dart', 'flutter'],
      );

      expect(updated.type, equals('search'));
      expect(updated.keywords, equals(['dart', 'flutter']));
      expect(updated.suggestedCategory, isNull);
    });

    test('IntentResult should support different intent types', () {
      final qa = IntentResult(type: 'qa', keywords: []);
      final search = IntentResult(type: 'search', keywords: []);
      final quiz = IntentResult(type: 'quiz', keywords: []);

      expect(qa.type, equals('qa'));
      expect(search.type, equals('search'));
      expect(quiz.type, equals('quiz'));
    });

    test('IntentResult should handle empty keywords', () {
      final result = IntentResult(
        type: 'qa',
        keywords: [],
      );

      expect(result.keywords, isEmpty);
    });
  });
}
