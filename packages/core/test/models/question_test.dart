import 'package:test/test.dart';
import 'package:core/models/question.dart';

void main() {
  group('Question', () {
    final now = DateTime(2026, 5, 30).toIso8601String();
    final question = Question(
      id: 1,
      type: 'single_choice',
      stem: 'Flutter 使用什么语言？',
      options: '["Dart","Kotlin","Swift","Java"]',
      answer: 'Dart',
      explanation: 'Flutter 使用 Dart 语言开发',
      sourceFileIds: '[1,2]',
      difficulty: 2,
      tags: '["flutter","dart"]',
      createdAt: now,
      contentHash: 'abc123',
    );

    test('fromMap creates correct instance', () {
      final map = {
        'id': 1,
        'type': 'single_choice',
        'stem': 'Flutter 使用什么语言？',
        'options': '["Dart","Kotlin","Swift","Java"]',
        'answer': 'Dart',
        'explanation': 'Flutter 使用 Dart 语言开发',
        'sourceFileIds': '[1,2]',
        'difficulty': 2,
        'tags': '["flutter","dart"]',
        'createdAt': now,
        'contentHash': 'abc123',
      };
      final result = Question.fromMap(map);
      expect(result.id, 1);
      expect(result.type, 'single_choice');
      expect(result.stem, 'Flutter 使用什么语言？');
      expect(result.options, isNotNull);
      expect(result.difficulty, 2);
    });

    test('fromMap handles null optional fields', () {
      final map = {
        'id': 2,
        'type': 'fill_in_blank',
        'stem': '填空题',
        'answer': '答案',
        'difficulty': 1,
        'createdAt': now,
      };
      final result = Question.fromMap(map);
      expect(result.options, isNull);
      expect(result.explanation, isNull);
      expect(result.sourceFileIds, isNull);
      expect(result.tags, isNull);
      expect(result.contentHash, isNull);
    });

    test('toMap returns correct map', () {
      final map = question.toMap();
      expect(map['id'], 1);
      expect(map['type'], 'single_choice');
      expect(map['stem'], 'Flutter 使用什么语言？');
      expect(map['options'], '["Dart","Kotlin","Swift","Java"]');
      expect(map['answer'], 'Dart');
    });

    test('fromMap → toMap roundtrip', () {
      final map = question.toMap();
      final restored = Question.fromMap(map);
      expect(restored.id, question.id);
      expect(restored.type, question.type);
      expect(restored.stem, question.stem);
      expect(restored.options, question.options);
      expect(restored.answer, question.answer);
      expect(restored.difficulty, question.difficulty);
    });

    test('copyWith creates new instance with overrides', () {
      final modified = question.copyWith(
        stem: '修改后的题干',
        difficulty: 3,
      );
      expect(modified.stem, '修改后的题干');
      expect(modified.difficulty, 3);
      expect(modified.id, question.id); // unchanged
      expect(modified.answer, question.answer); // unchanged
    });
  });
}
