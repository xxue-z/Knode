import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat/gen/strings.dart';
import 'package:chat/providers/conversation_provider.dart';
import 'package:core/models/conversation.dart';
import 'package:wiki/providers/category_provider.dart';
import 'package:wiki/providers/document_provider.dart';
import 'package:wiki/screens/reader_page.dart';
import 'package:chat/screens/archive_dialog.dart';

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
            Text(_strings.chat_current_session, style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
          ])),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(children: [
              Expanded(child: _TabButton(
                label: _strings.chat_current_session,
                isSelected: _currentTab == 0,
                onTap: () => setState(() { _currentTab = 0; _searchQuery = ''; }),
              )),
              const SizedBox(width: 8),
              Expanded(child: _TabButton(
                label: _strings.chat_archive,
                isSelected: _currentTab == 1,
                onTap: () => setState(() { _currentTab = 1; _searchQuery = ''; }),
              )),
            ]),
          ),
          const Divider(height: 1),
          if (_currentTab == 0)
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Row(children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: _strings.chat_search,
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
                label: Text(_strings.chat_new_conversation),
              ),
            ])),
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
    final controller = TextEditingController();
    final wikiFileId = await showDialog<int>(context: context, builder: (_) => ArchiveDialog(
      conversationTitle: conv.title ?? ''
      controller: controller,
    ));
    if (wikiFileId != null) {
      await ref.read(conversationListProvider.notifier).archive(conv.id, wikiFileId);
    }
  }

  Future<void> _deleteConversation(Conversation conv) async {
    final confirmed = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: Text(_strings.chat_delete_conversation),
      content: Text('\u786e\u8ba4\u5220\u9664\u5bf9\u8bdd ' + (conv.title ?? '') + '\uff1f'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(_strings.chat_cancel)),
        TextButton(onPressed: () => Navigator.pop(context, true), child: Text(_strings.chat_confirm)),
      ],
    ));
    if (confirmed == true) {
      await ref.read(conversationListProvider.notifier).delete(conv.id);
    }
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _TabButton({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(
          color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        )),
      ),
    );
  }
}

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
    final asyncConversations = ref.watch(conversationListProvider);
    return asyncConversations.when(
      data: (conversations) {
        final filtered = searchQuery.isEmpty
            ? conversations
            : conversations.where((c) => (c.title ?? '').toLowerCase().contains(searchQuery.toLowerCase())).toList();
        if (filtered.isEmpty) return Center(child: Text(_strings.chat_no_conversations_yet));
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
                  leading: const Icon(Icons.chat_outlined),
                  title: Text(conv.title ?? _strings.chat_no_conversations, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(_formatDate(conv.updatedAt), style: Theme.of(context).textTheme.bodySmall),
                  onTap: () => onSelect(conv),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'rename') onRename(conv);
                      else if (value == 'archive') onArchive(conv);
                      else if (value == 'delete') onDelete(conv);
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'rename', child: Text(_strings.chat_rename_conversation)),
                      PopupMenuItem(value: 'archive', child: Text(_strings.chat_archive)),
                      PopupMenuItem(value: 'delete', child: Text(_strings.chat_delete_conversation)),
                    ],
                  ),
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

  String _formatDate(String? dt) {
    if (dt == null) return '';
    final d = DateTime.tryParse(dt);
    if (d == null) return '';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
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
      if (convDate.isAtSameMomentAs(today)) { label = '\u4eca\u5929'; }
      else if (convDate.isAtSameMomentAs(yesterday)) { label = '\u6628\u5929'; }
      else if (convDate.isAfter(weekAgo)) { label = '7\u5929\u5185'; }
      else if (convDate.isAfter(monthAgo)) { label = '30\u5929\u5185'; }
      else { label = '${date.year}-${date.month.toString().padLeft(2, '0')}'; }
      groups.putIfAbsent(label, () => []).add(conv);
    }
    final result = <_TimeGroup>[];
    final order = ['\u4eca\u5929', '\u6628\u5929', '7\u5929\u5185', '30\u5929\u5185'];
    for (final label in order) {
      if (groups.containsKey(label)) result.add(_TimeGroup(label: label, conversations: groups[label]!));
    }
    for (final entry in groups.entries) {
      if (!order.contains(entry.key)) result.add(_TimeGroup(label: entry.key, conversations: entry.value));
    }
    return result;
  }
}

class _ArchivedDocumentList extends ConsumerWidget {
  const _ArchivedDocumentList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archivedAsync = ref.watch(archivedConversationListProvider);
    return archivedAsync.when(
      data: (archived) {
        if (archived.isEmpty) return Center(child: Text(_strings.chat_no_conversations));
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
                  title: Text(conv.title ?? '\u5f52\u6863\u4f1a\u8bdd', maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    conv.wikiFileId != null ? '\u5173\u8054\u6587\u6863 ID: ' + conv.wikiFileId.toString() : '\u4f1a\u8bdd\u5df2\u5220\u9664',
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
      if (convDate.isAtSameMomentAs(today)) { label = '\u4eca\u5929'; }
      else if (convDate.isAtSameMomentAs(yesterday)) { label = '\u6628\u5929'; }
      else if (convDate.isAfter(weekAgo)) { label = '7\u5929\u5185'; }
      else if (convDate.isAfter(monthAgo)) { label = '30\u5929\u5185'; }
      else { label = '${date.year}-${date.month.toString().padLeft(2, '0')}'; }
      groups.putIfAbsent(label, () => []).add(conv);
    }
    final result = <_TimeGroup>[];
    final order = ['\u4eca\u5929', '\u6628\u5929', '7\u5929\u5185', '30\u5929\u5185'];
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
      content: Text('\u786e\u8ba4\u5220\u9664\u5f52\u6863\u4f1a\u8bdd ' + (conv.title ?? '') + '\uff1f'),
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
