/// 知维 Chat 模块 - AI 对话、RAG 检索
///
/// 此文件作为 barrel export，导出 chat 包的所有公共 API。
library chat;

// ── Screens ──
export 'screens/chat_page.dart';
export 'screens/message_input.dart';
export 'screens/message_bubble.dart';
export 'screens/citation_widget.dart';
export 'screens/conversation_list.dart';
export 'screens/archive_dialog.dart';

// ── Providers ──
export 'providers/chat_provider.dart';
export 'providers/conversation_provider.dart';

// ── Agents ──
export 'agents/qa_agent.dart';
export 'agents/intent_agent.dart';
export 'agents/search_agent.dart';
