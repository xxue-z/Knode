import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/conversation_provider.dart';
import '../../data/models/conversation.dart';

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
            label: const Text('新建会话'),
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
                    title: Text(conv.title ?? '新对话', maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(conv.updatedAt, style: Theme.of(context).textTheme.bodySmall),
                    onTap: () => onConversationSelected?.call(conv),
                    trailing: PopupMenuButton<String>(
                      onSelected: (action) {
                        if (action == 'rename') _showRenameDialog(context, ref, conv);
                        if (action == 'delete') ref.read(conversationListProvider.notifier).delete(conv.id);
                        if (action == 'archive') _archiveConversation(context, ref, conv);
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'rename', child: Text('重命名')),
                        PopupMenuItem(value: 'archive', child: Text('归档为笔记')),
                        PopupMenuItem(value: 'delete', child: Text('删除')),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(onPressed: () {
            final name = controller.text.trim();
            if (name.isNotEmpty) ref.read(conversationListProvider.notifier).rename(conv.id, name);
            Navigator.pop(context);
          }, child: const Text('确定')),
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