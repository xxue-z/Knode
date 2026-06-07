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
import 'package:intl/intl.dart';

const _strings = L10nStringsMixin();

class ChatHistoryDrawer extends ConsumerStatefulWidget {
  const ChatHistoryDrawer({super.key, this.onConversationSelected});
  final ValueChanged<Conversation>? onConversationSelected;
  @override
  ConsumerState<ChatHistoryDrawer> createState() => _ChatHistoryDrawerState();
}

class _ChatHistoryDrawerState extends ConsumerState<ChatHistoryDrawer> {
  int _currentTab = 0;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: SafeArea(
        child: Column(children: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Row(children: [
            Text('会话管理', style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
          ])),
          const Divider(height: 1),
          // Tab bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(children: [
              Expanded(child: _TabButton(
                label: '会话管理',
                isSelected: _currentTab == 0,
                onTap: () => setState(() { _currentTab = 0; _searchQuery = ''; }),
              )),
              const SizedBox(width: 8),
              Expanded(child: _TabButton(
                label: '归档列表',
                isSelected: _currentTab == 1,
                onTap: () => setState(() { _currentTab = 1; _searchQuery = ''; }),
              )),
            ]),
          ),
          const Divider(height: 1),
          // Search + New button (only for history tab)
          if (_currentTab == 0)
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Row(children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '搜索历史会话...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    isDense: true,
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _createNewConversation,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('新会话'),
              ),
            ])),
          // Tab content
          Expanded(child: _currentTab == 0
              ? _ConversationHistoryList(
                  searchQuery: _searchQuery,
                  onSelect: _selectConversation,
                  onRename: _renameConversation,
                  onArchive: _archiveConversation,
                  onDelete: _deleteConversation,
                )
              : _ArchivedDocumentList(),
          ),
        ]),
      ),
    );
  }

  void _selectConversation(Conversation conv) {
    Navigator.pop(context);
    widget.onConversationSelected?.call(conv);
  }

  Future<void> _createNewConversation() async {
    final notifier = ref.read(conversationListProvider.notifier);
    final conv = await notifier.create();
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

  Future<void> _deleteConversation(Conversation conv) async {
    final confirmed = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: Text(_strings.chat_delete_conversation),
      content: Text('确认删除会话 ' + (conv.title ?? '') + '？'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(_strings.chat_cancel)),
        TextButton(onPressed: () => Navigator.pop(context, true), child: Text(_strings.chat_confirm)),
      ],
    ));
    if (confirmed == true && mounted) {
      await ref.read(conversationListProvider.notifier).delete(conv.id);
    }
  }
}

// ==================== Tab Button ====================

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _TabButton({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Text(label, style: TextStyle(
          color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ))),
      ),
    );
  }
}

// ==================== History List ====================

class _ConversationHistoryList extends ConsumerWidget {
  final String searchQuery;
  final ValueChanged<Conversation> onSelect;
  final ValueChanged<Conversation> onRename;
  final ValueChanged<Conversation> onArchive;
  final ValueChanged<Conversation> onDelete;

  const _ConversationHistoryList({
    required this.searchQuery,
    required this.onSelect,
    required this.onRename,
    required this.onArchive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convListAsync = ref.watch(conversationListProvider);
    return convListAsync.when(
      data: (conversations) {
        final filtered = searchQuery.isEmpty
            ? conversations
            : conversations.where((c) => (c.title ?? '').toLowerCase().contains(searchQuery.toLowerCase())).toList();
        if (filtered.isEmpty) return Center(child: Text(_strings.chat_no_conversations));
        final grouped = _groupByTime(filtered);
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
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: Text(conv.title ?? _strings.chat_new_conversation, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(conv.updatedAt, style: Theme.of(context).textTheme.bodySmall),
                  onTap: () => onSelect(conv),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                      icon: Icon(conv.wikiFileId != null ? Icons.archive : Icons.archive_outlined, size: 20),
                      tooltip: conv.wikiFileId != null ? '已归档' : _strings.chat_archive,
                      onPressed: conv.wikiFileId != null ? null : () => onArchive(conv),
                    ),
                    IconButton(icon: const Icon(Icons.edit_outlined, size: 20), tooltip: _strings.chat_rename_label, onPressed: () => onRename(conv)),
                    IconButton(icon: const Icon(Icons.delete_outline, size: 20), tooltip: _strings.chat_delete_conversation, onPressed: () => onDelete(conv)),
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
      if (convDate.isAtSameMomentAs(today)) { label = '今天'; }
      else if (convDate.isAtSameMomentAs(yesterday)) { label = '昨天'; }
      else if (convDate.isAfter(weekAgo)) { label = '7天内'; }
      else if (convDate.isAfter(monthAgo)) { label = '30天内'; }
      else { label = DateFormat('yyyy-MM').format(date); }
      groups.putIfAbsent(label, () => []).add(conv);
    }
    final result = <_TimeGroup>[];
    final order = ['今天', '昨天', '7天内', '30天内'];
    for (final label in order) {
      if (groups.containsKey(label)) result.add(_TimeGroup(label: label, conversations: groups[label]!));
    }
    for (final entry in groups.entries) {
      if (!order.contains(entry.key)) result.add(_TimeGroup(label: entry.key, conversations: entry.value));
    }
    return result;
  }
}

// ==================== Archive List ====================

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
                  subtitle: Text(
                    conv.wikiFileId != null ? '关联文档 ID: ' + conv.wikiFileId.toString() : '会话已删除',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
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
      if (convDate.isAtSameMomentAs(today)) { label = '今天'; }
      else if (convDate.isAtSameMomentAs(yesterday)) { label = '昨天'; }
      else if (convDate.isAfter(weekAgo)) { label = '7天内'; }
      else if (convDate.isAfter(monthAgo)) { label = '30天内'; }
      else { label = DateFormat('yyyy-MM').format(date); }
      groups.putIfAbsent(label, () => []).add(conv);
    }
    final result = <_TimeGroup>[];
    final order = ['今天', '昨天', '7天内', '30天内'];
    for (final label in order) {
      if (groups.containsKey(label)) result.add(_TimeGroup(label: label, conversations: groups[label]!));
    }
    for (final entry in groups.entries) {
      if (!order.contains(entry.key)) result.add(_TimeGroup(label: entry.key, conversations: entry.value));
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

// ==================== Shared ====================

class _TimeGroup {
  final String label;
  final List<Conversation> conversations;
  const _TimeGroup({required this.label, required this.conversations});
}
