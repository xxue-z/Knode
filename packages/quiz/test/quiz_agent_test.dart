import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:core/ai/ai_provider.dart';
import 'package:core/ai/prompt_manager.dart';
import 'package:core/models/question.dart';
import 'package:quiz/agents/quiz_agent.dart';

import 'quiz_agent_test.mocks.dart';

@GenerateMocks([AIProvider, PromptManager])
void main() {
  group('QuizAgent Tests', () {
    late MockAIProvider mockAIProvider;
    late MockPromptManager mockPromptManager;
    late QuizAgent agent;

    setUp(() {
      mockAIProvider = MockAIProvider();
      mockPromptManager = MockPromptManager();
      agent = QuizAgent(
        ai: mockAIProvider,
        prompt: mockPromptManager,
      );
    });

    test('should generate quiz questions from content', () async {
      const content = 'Flutter is a UI toolkit for building beautiful applications.';
      const template = 'Generate {min} to {max} questions.';
      const systemPrompt = 'Generate 3 to 5 questions.';
      const aiResponse = '''
{
  "questions": [
    {
      "type": "single_choice",
      "stem": "What is Flutter?",
      "options": ["A UI toolkit", "A database", "A programming language"],
      "answer": "A UI toolkit",
      "explanation": "Flutter is a UI toolkit for building applications.",
      "difficulty": 1
    }
  ]
}
''';

      when(mockPromptManager.loadTemplate('quiz_generator'))
          .thenAnswer((_) async => template);
      when(mockPromptManager.render(template, {'min': '3', 'max': '5'}))
          .thenReturn(systemPrompt);
      when(mockAIProvider.generateAnswer(
        query: content,
        contextDocs: [],
        systemPrompt: systemPrompt,
      )).thenAnswer((_) async => AIResponse(answer: aiResponse));

      final result = await agent.generateQuiz(
        content: content,
        minCount: 3,
        maxCount: 5,
      );

      expect(result.length, equals(1));
      expect(result[0].stem, equals('What is Flutter?'));
      expect(result[0].type, equals('single_choice'));
      expect(result[0].answer, equals('A UI toolkit'));
    });

    test('should handle empty AI response', () async {
      const content = 'Test content';
      const template = 'Template';
      const systemPrompt = 'System prompt';
      const aiResponse = '';

      when(mockPromptManager.loadTemplate('quiz_generator'))
          .thenAnswer((_) async => template);
      when(mockPromptManager.render(template, {'min': '1', 'max': '3'}))
          .thenReturn(systemPrompt);
      when(mockAIProvider.generateAnswer(
        query: content,
        contextDocs: [],
        systemPrompt: systemPrompt,
      )).thenAnswer((_) async => AIResponse(answer: aiResponse));

      final result = await agent.generateQuiz(
        content: content,
        minCount: 1,
        maxCount: 3,
      );

      expect(result, isEmpty);
    });

    test('should handle invalid JSON response', () async {
      const content = 'Test content';
      const template = 'Template';
      const systemPrompt = 'System prompt';
      const aiResponse = 'This is not valid JSON';

      when(mockPromptManager.loadTemplate('quiz_generator'))
          .thenAnswer((_) async => template);
      when(mockPromptManager.render(template, {'min': '1', 'max': '3'}))
          .thenReturn(systemPrompt);
      when(mockAIProvider.generateAnswer(
        query: content,
        contextDocs: [],
        systemPrompt: systemPrompt,
      )).thenAnswer((_) async => AIResponse(answer: aiResponse));

      final result = await agent.generateQuiz(
        content: content,
        minCount: 1,
        maxCount: 3,
      );

      expect(result, isEmpty);
    });

    test('should generate variant questions', () async {
      final originals = [
        Question(
          id: 1,
          type: 'single_choice',
          stem: 'What is Flutter?',
          answer: 'A UI toolkit',
          difficulty: 1,
          createdAt: DateTime.now().toIso8601String(),
        ),
      ];
      const template = 'Generate variants of {original_questions}';
      const systemPrompt = 'Generate variants';
      const aiResponse = '''
{
  "questions": [
    {
      "type": "single_choice",
      "stem": "What framework is Flutter?",
      "answer": "A UI toolkit",
      "difficulty": 1
    }
  ]
}
''';

      when(mockPromptManager.loadTemplate('question_variant'))
          .thenAnswer((_) async => template);
      when(mockPromptManager.render(template, {'original_questions': 'What is Flutter?'})).thenReturn(systemPrompt);
      when(mockAIProvider.generateAnswer(
        query: 'Generate variant questions based on the original ones',
        contextDocs: [],
        systemPrompt: systemPrompt,
      )).thenAnswer((_) async => AIResponse(answer: aiResponse));

      final result = await agent.generateVariant(originals: originals);

      expect(result.length, equals(1));
      expect(result[0].stem, equals('What framework is Flutter?'));
    });

    test('should deduplicate questions by stem hash', () async {
      const content = 'Test content';
      const template = 'Template';
      const systemPrompt = 'System prompt';
      const aiResponse = '''
{
  "questions": [
    {
      "type": "single_choice",
      "stem": "What is Flutter?",
      "answer": "A UI toolkit",
      "difficulty": 1
    },
    {
      "type": "single_choice",
      "stem": "What is Flutter?",
      "answer": "A UI toolkit",
      "difficulty": 1
    }
  ]
}
''';

      when(mockPromptManager.loadTemplate('quiz_generator'))
          .thenAnswer((_) async => template);
      when(mockPromptManager.render(template, {'min': '1', 'max': '3'}))
          .thenReturn(systemPrompt);
      when(mockAIProvider.generateAnswer(
        query: content,
        contextDocs: [],
        systemPrompt: systemPrompt,
      )).thenAnswer((_) async => AIResponse(answer: aiResponse));

      final result = await agent.generateQuiz(
        content: content,
        minCount: 1,
        maxCount: 3,
      );

      expect(result.length, equals(1));
    });
  });
}
