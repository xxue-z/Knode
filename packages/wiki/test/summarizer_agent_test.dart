import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:core/ai/ai_provider.dart';
import 'package:core/ai/prompt_manager.dart';
import 'package:wiki/agents/summarizer_agent.dart';

import 'summarizer_agent_test.mocks.dart';

@GenerateMocks([AIProvider, PromptManager])
void main() {
  group('SummarizerAgent Tests', () {
    late MockAIProvider mockAIProvider;
    late MockPromptManager mockPromptManager;
    late SummarizerAgent agent;

    setUp(() {
      mockAIProvider = MockAIProvider();
      mockPromptManager = MockPromptManager();
      agent = SummarizerAgent(
        aiProvider: mockAIProvider,
        promptManager: mockPromptManager,
      );
    });

    test('should summarize content with default max length', () async {
      const content = 'This is a long content that needs to be summarized.';
      const template = 'Summarize the content in {max_length} characters.';
      const systemPrompt = 'Summarize the content in 200 characters.';
      const summary = 'This is a summary.';

      when(mockPromptManager.loadTemplate('summarizer'))
          .thenAnswer((_) async => template);
      when(mockPromptManager.render(template, {'max_length': '200'}))
          .thenReturn(systemPrompt);
      when(mockAIProvider.summarize(
        content: content,
        maxLength: 200,
        systemPrompt: systemPrompt,
      )).thenAnswer((_) async => summary);

      final result = await agent.summarize(content: content);

      expect(result, equals(summary));
      verify(mockPromptManager.loadTemplate('summarizer')).called(1);
      verify(mockPromptManager.render(template, {'max_length': '200'})).called(1);
      verify(mockAIProvider.summarize(
        content: content,
        maxLength: 200,
        systemPrompt: systemPrompt,
      )).called(1);
    });

    test('should summarize content with custom max length', () async {
      const content = 'This is a long content.';
      const template = 'Summarize in {max_length} chars.';
      const systemPrompt = 'Summarize in 100 chars.';
      const summary = 'Short summary.';

      when(mockPromptManager.loadTemplate('summarizer'))
          .thenAnswer((_) async => template);
      when(mockPromptManager.render(template, {'max_length': '100'}))
          .thenReturn(systemPrompt);
      when(mockAIProvider.summarize(
        content: content,
        maxLength: 100,
        systemPrompt: systemPrompt,
      )).thenAnswer((_) async => summary);

      final result = await agent.summarize(content: content, maxLength: 100);

      expect(result, equals(summary));
      verify(mockPromptManager.render(template, {'max_length': '100'})).called(1);
    });

    test('should archive conversation to note', () async {
      const title = 'Conversation Title';
      final messages = [
        {'role': 'user', 'content': 'Hello'},
        {'role': 'assistant', 'content': 'Hi there!'},
      ];
      const template = 'Summarize template';
      const systemPrompt = 'Summarize in 200 chars.';
      const summary = 'A brief conversation.';

      when(mockPromptManager.loadTemplate('summarizer'))
          .thenAnswer((_) async => template);
      when(mockPromptManager.render(template, {'max_length': '200'}))
          .thenReturn(systemPrompt);
      when(mockAIProvider.summarize(
        content: anyNamed('content'),
        maxLength: 200,
        systemPrompt: systemPrompt,
      )).thenAnswer((_) async => summary);

      final result = await agent.archiveToNote(title: title, messages: messages);

      expect(result, contains('# $title'));
      expect(result, contains('## 对话摘要'));
      expect(result, contains(summary));
      expect(result, contains('## 对话记录'));
      expect(result, contains('user: Hello'));
      expect(result, contains('assistant: Hi there!'));
    });

    test('should handle empty content', () async {
      const content = '';
      const template = 'Template';
      const systemPrompt = 'System prompt';
      const summary = '';

      when(mockPromptManager.loadTemplate('summarizer'))
          .thenAnswer((_) async => template);
      when(mockPromptManager.render(template, {'max_length': '200'}))
          .thenReturn(systemPrompt);
      when(mockAIProvider.summarize(
        content: content,
        maxLength: 200,
        systemPrompt: systemPrompt,
      )).thenAnswer((_) async => summary);

      final result = await agent.summarize(content: content);

      expect(result, equals(summary));
    });
  });
}
