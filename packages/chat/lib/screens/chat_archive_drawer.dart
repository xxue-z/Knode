import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat/gen/strings.dart';
import 'package:chat/providers/conversation_provider.dart';
import 'package:core/models/conversation.dart';
import 'package:wiki/providers/document_provider.dart';
import 'package:wiki/screens/reader_page.dart';
import 'package:intl/intl.dart';

const _strings = L10nStringsMixin();

class ChatArchiveDrawer extends ConsumerStatefulWidget {
  const ChatArchiveDrawer({super.key});
  @override
  ConsumerState<ChatArchiveDrawer> createState() => _ChatArchiveDrawerState();
}

class _ChatArchiveDrawerState extends ConsumerState<ChatArchiveDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: SafeArea(
        child: Column(children: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Row(children: [
            Text('归档列表', style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
          ])),
          const Divider(height: 1),
          Expanded(child: _ArchivedDocumentList()),
        ]),
      ),
    );
  }
}

class _ArchivedDocumentList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archivedAsync = ref.watch(archivedConversationListProvider);
    return archivedAsync.when(
      data: (archived) {
        if (archived.isEmpty) return const Center(child: Text('暂无归档会话'));
        
        final grouped = _groupByTime(archived);
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: grouped.length,
          itemBuilder: (context, index) {
            final group = grouped[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: Text(group.label, style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  )),
                ),
                ...group.conversations.map((conv) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.archive_outlined),
                  title: Text(conv.title ?? '归档会话', maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(conv.wikiFileId != null ? '关联文档 ID: ' : '会话已删除', 
                    style: Theme.of(context).textTheme.bodySmall),
                  onTap: conv.wikiFileId != null ? () => _openWikiFile(context, conv) : null,
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (conv.wikiFileId == null)
                      Icon(Icons.warning_amber, size: 20, color: Theme.of(context).colorScheme.error),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20), 
                      tooltip: _strings.chat_delete_conversation, 
                      onPressed: () => _deleteArchivedConversation(context, ref, conv),
                    ),
                  ]),
                )),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(_strings.chat_load_failed)),
    );
  }

  List<_TimeGroup> _groupByTime(List<Conversation> conversations) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));
    final monthAgo = today.subtract(const Duration(days: 30));
    
    final groups = <String, List<Conversation>>{};
    
    for (final conv in conversations) {
      final date = DateTime.tryParse(conv.updatedAt) ?? DateTime.now();
      final convDate = DateTime(date.year, date.month, date.day);
      
      String label;
      if (convDate.isAtSameMomentAs(today)) {
        label = '今天';
      } else if (convDate.isAtSameMomentAs(yesterday)) {
        label = '昨天';
      } else if (convDate.isAfter(weekAgo)) {
        label = '7天内';
      } else if (convDate.isAfter(monthAgo)) {
        label = '30天内';
      } else {
        label = DateFormat('yyyy-MM').format(date);
      }
      
      groups.putIfAbsent(label, () => []).add(conv);
    }
    
    final result = <_TimeGroup>[];
    final order = ['今天', '昨天', '7天内', '30天内'];
    for (final label in order) {
      if (groups.containsKey(label)) {
        result.add(_TimeGroup(label: label, conversations: groups[label]!));
      }
    }
    
    for (final entry in groups.entries) {
      if (!order.contains(entry.key)) {
        result.add(_TimeGroup(label: entry.key, conversations: entry.value));
      }
    }
    
    return result;
  }

  void _openWikiFile(BuildContext context, Conversation conv) {
    if (conv.wikiFileId != null) {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => ReaderPage(docId: conv.wikiFileId!, title: conv.title),
      ));
    }
  }

  Future<void> _deleteArchivedConversation(BuildContext context, WidgetRef ref, Conversation conv) async {
    final confirmed = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: Text(_strings.chat_delete_conversation),
      content: Text('确认删除归档会话 ' + (conv.title ?? '') + '？归档生成的文章不会被删除。'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(_strings.chat_cancel)),
        TextButton(onPressed: () => Navigator.pop(context, true), child: Text(_strings.chat_confirm)),
      ],
    ));
    if (confirmed == true) {
      await ref.read(conversationListProvider.notifier).unlinkWikiFile(conv.id);
      await ref.read(conversationListProvider.notifier).delete(conv.id);
    }
  }
}

class _TimeGroup {
  final String label;
  final List<Conversation> conversations;
  const _TimeGroup({required this.label, required this.conversations});
}
