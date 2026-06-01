import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/ai/prompt_manager.dart';
import 'package:core/providers/service_providers.dart';
import 'package:core/providers/settings_provider.dart';
import 'package:wiki/agents/tag_generator_agent.dart';

/// TagGeneratorAgent 实例。
final tagGeneratorAgentProvider = Provider<TagGeneratorAgent>((ref) {
  return TagGeneratorAgent(
    aiProvider: ref.read(aiProviderRef),
    promptManager: PromptManager(ref.read(settingsDaoProvider)),
  );
});
