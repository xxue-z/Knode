import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat/gen/strings.dart';
import '../../providers/conversation_provider.dart';
import 'package:core/models/conversation.dart';

const _strings = L10nStringsMixin();

class ConversationList extends ConsumerWidget {
  const ConversationList({super.key, this.onConversationSelected});
  final ValueChanged<Conversation>? onConversationSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convListAsync = ref.watch(conversationListProvider);
    return Column(
      children: [
        // 新建会话按钮
        Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: () async {
              final notifier = ref.read(conversationListProvider.notifier);
              final conv = await notifier.create();
              if (conv != null) onConversationSelected?.call(conv);
            },
            icon: const Icon(Icons.add),
            label: Text(_strings.chat_new_conversation),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: convListAsync.when(
            data: (conversations) {
              if (conversations.isEmpty) {
                return const Center(child: Text('暂无对话，开始新对话吧'));
              }
              return ListView.separated(
                itemCount: conversations.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final conv = conversations[index];
                  return ListTile(
                    leading: const Icon(Icons.chat_bubble_outline),
                    title: Text(conv.title ?? _strings.chat_new_conversation, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(conv.updatedAt, style: Theme.of(context).textTheme.bodySmall),
                    onTap: () => onConversationSelected?.call(conv),
                    trailing: PopupMenuButton<String>(
                      onSelected: (action) {
                        if (action == 'rename') _showRenameDialog(context, ref, conv);
                        if (action == 'delete') ref.read(conversationListProvider.notifier).delete(conv.id);
                        if (action == 'archive') _archiveConversation(context, ref, conv);
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(value: 'rename', child: const Text('重命名')),
                        PopupMenuItem(value: 'archive', child: Text(_strings.chat_archive)),
                        PopupMenuItem(value: 'delete', child: Text(_strings.chat_delete_conversation)),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('加载失败: $e')),
          ),
        ),
      ],
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, Conversation conv) {
    final controller = TextEditingController(text: conv.title);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('重命名对话'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(_strings.chat_cancel)),
          TextButton(onPressed: () {
            final name = controller.text.trim();
            if (name.isNotEmpty) ref.read(conversationListProvider.notifier).rename(conv.id, name);
            Navigator.pop(context);
          }, child: Text(_strings.chat_confirm)),
        ],
      ),
    );
  }

  void _archiveConversation(BuildContext context, WidgetRef ref, Conversation conv) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('归档功能需在会话详情页中使用')),
    );
  }
}