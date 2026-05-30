import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat/gen/strings.dart';
import 'package:core/models/category.dart';
import 'package:core/providers/service_providers.dart';

const _strings = L10nStringsMixin();

class ArchiveDialog extends ConsumerStatefulWidget {
  const ArchiveDialog({
    super.key,
    required this.conversationId,
    required this.conversationTitle,
    required this.messages,
    required this.categories,
  });

  final int conversationId;
  final String? conversationTitle;
  final List<Map<String, String>> messages;
  final List<Category> categories;

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
              .map((m) =>
                  '${m['role'] == 'user' ? '用户' : 'AI'}: ${m['content']}')
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
    return AlertDialog(
      title: Text(_strings.chat_archive),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('选择目标类目:'),
          const SizedBox(height: 12),
          DropdownButton<int>(
            isExpanded: true,
            value: _selectedCategoryId,
            hint: const Text('选择类目'),
            items: widget.categories
                .map((c) =>
                    DropdownMenuItem(value: c.id, child: Text(c.name)))
                .toList(),
            onChanged: (v) => setState(() => _selectedCategoryId = v),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_strings.chat_cancel)),
        FilledButton(
          onPressed:
              _selectedCategoryId != null && !_isArchiving ? _archive : null,
          child: _isArchiving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(_strings.chat_archive),
        ),
      ],
    );
  }
}