import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat/gen/strings.dart';
import 'package:chat/providers/conversation_provider.dart';
import 'package:chat/providers/chat_provider.dart';
import 'package:core/models/conversation.dart';
import 'package:wiki/providers/category_provider.dart';
import 'package:wiki/providers/document_provider.dart';
import 'package:wiki/screens/reader_page.dart';
import 'package:chat/screens/archive_dialog.dart';

const _strings = L10nStringsMixin();

class ChatDrawer extends ConsumerStatefulWidget {
  const ChatDrawer({super.key, this.onConversationSelected});
  final ValueChanged<Conversation>? onConversationSelected;
  @override
  ConsumerState<ChatDrawer> createState() => _ChatDrawerState();
}

class _ChatDrawerState extends ConsumerState<ChatDrawer> {
  bool _showArchived = false;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: SafeArea(
        child: Column(children: [
          Padding(padding: const EdgeInsets.all(16), child: Row(children: [
            Text(_strings.chat_ai_assistant, style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
          ])),
          const Divider(height: 1),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Row(children: [
            Expanded(child: _TabButton(label: _strings.chat_history_sessions, isSelected: !_showArchived, onTap: () => setState(() => _showArchived = false))),
            const SizedBox(width: 8),
            Expanded(child: _TabButton(label: _strings.chat_archive, isSelected: _showArchived, onTap: () => setState(() => _showArchived = true))),
          ])),
          Expanded(child: _showArchived
              ? _ArchivedConversationList(onOpenFile: _openWikiFile, onDelete: _deleteArchivedConversation)
              : _ActiveConversationList(onSelect: _selectConversation, onRename: _renameConversation, onArchive: _archiveConversation)),
        ]),
      ),
    );
  }

  void _selectConversation(Conversation conv) {
    Navigator.pop(context);
    widget.onConversationSelected?.call(conv);
  }

  void _renameConversation(Conversation conv) {
    final controller = TextEditingController(text: conv.title);
    showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: Text(_strings.chat_rename_conversation),
      content: TextField(controller: controller, autofocus: true),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(_strings.chat_cancel)),
        TextButton(onPressed: () {
          final name = controller.text.trim();
          if (name.isNotEmpty) ref.read(conversationListProvider.notifier).rename(conv.id, name);
          Navigator.pop(context);
        }, child: Text(_strings.chat_confirm)),
      ],
    ));
  }

  Future<void> _archiveConversation(Conversation conv) async {
    final convRepo = ref.read(conversationRepositoryProvider);
    final messages = await convRepo.getMessages(conv.id);
    final messageMaps = messages.map((m) => {'role': m.role, 'content': m.content}).toList();
    final categoriesAsync = ref.read(categoryListProvider);
    if (!mounted) return;
    final result = await showDialog<Map<String, dynamic>>(context: context, builder: (_) => ArchiveDialog(
      conversationId: conv.id, conversationTitle: conv.title, messages: messageMaps, categories: categoriesAsync.value?.allCategories ?? [],
    ));
    if (result != null && mounted) {
      try {
        final docRepo = ref.read(documentRepositoryProvider);
        final doc = await docRepo.createDocument(
          categoryId: result['categoryId'] as int,
          title: result['title'] as String,
          initialContent: result['content'] as String,
        );
        await ref.read(conversationListProvider.notifier).archive(conv.id, doc.id);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_strings.chat_archive + ': ' + (conv.title ?? ''))));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_strings.chat_archive_failed + ': ' + e.toString())));
      }
    }
  }

  Future<void> _deleteArchivedConversation(Conversation conv) async {
    final confirmed = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: Text(_strings.chat_delete_conversation),
      content: Text('确认删除归档会话 ' + (conv.title ?? '') + '？归档生成的文章不会被删除。'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(_strings.chat_cancel)),
        TextButton(onPressed: () => Navigator.pop(context, true), child: Text(_strings.chat_confirm)),
      ],
    ));
    if (confirmed == true && mounted) {
      await ref.read(conversationListProvider.notifier).unlinkWikiFile(conv.id);
      await ref.read(conversationListProvider.notifier).delete(conv.id);
    }
  }

  void _openWikiFile(Conversation conv) {
    if (conv.wikiFileId != null) {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => ReaderPage(docId: conv.wikiFileId!, title: conv.title),
      ));
    }
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.label, required this.isSelected, required this.onTap});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: Text(label, style: TextStyle(
        color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ))),
    ));
  }
}

class _ActiveConversationList extends ConsumerWidget {
  const _ActiveConversationList({required this.onSelect, required this.onRename, required this.onArchive});
  final ValueChanged<Conversation> onSelect;
  final ValueChanged<Conversation> onRename;
  final ValueChanged<Conversation> onArchive;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convListAsync = ref.watch(conversationListProvider);
    return convListAsync.when(
      data: (conversations) {
        if (conversations.isEmpty) return Center(child: Text(_strings.chat_no_conversations));
        return ListView.separated(itemCount: conversations.length, separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final conv = conversations[index];
            return ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: Text(conv.title ?? _strings.chat_new_conversation, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(conv.updatedAt, style: Theme.of(context).textTheme.bodySmall),
              onTap: () => onSelect(conv),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.archive_outlined, size: 20), tooltip: _strings.chat_archive, onPressed: () => onArchive(conv)),
                IconButton(icon: const Icon(Icons.edit_outlined, size: 20), tooltip: _strings.chat_rename_label, onPressed: () => onRename(conv)),
              ]),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(_strings.chat_load_failed)),
    );
  }
}

class _ArchivedConversationList extends ConsumerWidget {
  const _ArchivedConversationList({required this.onOpenFile, required this.onDelete});
  final ValueChanged<Conversation> onOpenFile;
  final ValueChanged<Conversation> onDelete;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archivedAsync = ref.watch(archivedConversationListProvider);
    return archivedAsync.when(
      data: (archived) {
        if (archived.isEmpty) return const Center(child: Text('暂无归档会话'));
        return ListView.separated(itemCount: archived.length, separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final conv = archived[index];
            return ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: Text(conv.title ?? '归档会话', maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: conv.wikiFileId != null
                  ? Text('关联文档 ID: ' + conv.wikiFileId.toString(), style: Theme.of(context).textTheme.bodySmall)
                  : null,
              onTap: () => onOpenFile(conv),
              trailing: IconButton(icon: const Icon(Icons.delete_outline, size: 20), tooltip: _strings.chat_delete_conversation, onPressed: () => onDelete(conv)),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(_strings.chat_load_failed)),
    );
  }
}
