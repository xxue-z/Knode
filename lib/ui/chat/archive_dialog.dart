import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/conversation_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/service_providers.dart';
import 'package:core/database/repositories/conversation_repository.dart';
import 'package:core/models/document.dart';

class ArchiveDialog extends ConsumerStatefulWidget {
  const ArchiveDialog({super.key, required this.conversationId, required this.conversationTitle, required this.messages});
  final int conversationId;
  final String? conversationTitle;
  final List<Map<String, String>> messages;

  @override
  ConsumerState<ArchiveDialog> createState() => _ArchiveDialogState();
}

class _ArchiveDialogState extends ConsumerState<ArchiveDialog> {
  int? _selectedCategoryId;
  bool _isArchiving = false;

  Future<void> _archive() async {
    if (_selectedCategoryId == null) return;

    setState(() => _isArchiving = true);

    try {
      // 拼接会话内容为 Markdown
      final buffer = StringBuffer();
      buffer.writeln('# ${widget.conversationTitle ?? "会话归档"}\n');
      for (final msg in widget.messages) {
        final role = msg['role'] == 'user' ? '**用户**' : '**AI**';
        buffer.writeln('$role：${msg['content']}\n');
      }

      // 使用 AI 生成摘要
      String summary = '';
      if (widget.messages.length > 3) {
        try {
          final aiProvider = ref.read(aiProviderRef);
          final conversationText = widget.messages
              .map((m) => '${m['role'] == 'user' ? '用户' : 'AI'}: ${m['content']}')
              .join('\n');
          final response = await aiProvider.summarize(
            content: conversationText,
            maxLength: 200,
            systemPrompt: '请用简洁的中文总结以下对话内容，不超过200字。',
          );
          summary = response;
        } catch (_) {
          summary = '会话共 ${widget.messages.length} 条消息';
        }
      }

      if (mounted) {
        Navigator.of(context).pop({
          'categoryId': _selectedCategoryId,
          'content': buffer.toString(),
          'title': widget.conversationTitle ?? '会话归档',
          'summary': summary,
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isArchiving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('归档失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryListProvider);
    return AlertDialog(
      title: const Text('归档为笔记'),
      content: categories.when(
        data: (state) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('选择目标类目:'),
            const SizedBox(height: 12),
            DropdownButton<int>(
              isExpanded: true,
              value: _selectedCategoryId,
              hint: const Text('选择类目'),
              items: state.allCategories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
              onChanged: (v) => setState(() => _selectedCategoryId = v),
            ),
          ],
        ),
        loading: () => const CircularProgressIndicator(),
        error: (e, _) => Text('加载失败: $e'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
        FilledButton(
          onPressed: _selectedCategoryId != null && !_isArchiving ? _archive : null,
          child: _isArchiving
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('归档'),
        ),
      ],
    );
  }
}
