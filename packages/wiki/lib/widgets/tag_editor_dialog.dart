import 'package:flutter/material.dart';
import 'package:wiki/gen/strings.dart';

const _strings = L10nStringsMixin();

/// 标签编辑对话框。
///
/// 弹出 showModalBottomSheet，包含当前标签列表（可滑动删除）、
/// 输入新标签的 TextField 和添加按钮。
/// 返回更新后的标签列表，或 null（取消）。
class TagEditorDialog extends StatefulWidget {
  const TagEditorDialog({
    super.key,
    required this.tags,
  });

  final List<String> tags;

  static Future<List<String>?> show(
    BuildContext context, {
    required List<String> tags,
  }) {
    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: TagEditorDialog(tags: tags),
      ),
    );
  }

  @override
  State<TagEditorDialog> createState() => _TagEditorDialogState();
}

class _TagEditorDialogState extends State<TagEditorDialog> {
  late List<String> _tags;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tags = List<String>.from(widget.tags);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTag() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (_tags.contains(text)) {
      _controller.clear();
      return;
    }
    setState(() {
      _tags.add(text);
    });
    _controller.clear();
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text(
            _strings.wiki_edit_tags,
            style: theme.textTheme.titleMedium,
          ),

          const SizedBox(height: 12),

          // Current tags
          if (_tags.isNotEmpty)
            Wrap(
              spacing: 6.0,
              runSpacing: 4.0,
              children: [
                for (final tag in _tags)
                  Chip(
                    label: Text(tag, style: const TextStyle(fontSize: 13)),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => _removeTag(tag),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                _strings.wiki_no_tags,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),

          const SizedBox(height: 12),

          // Add tag input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: _strings.wiki_add_tag,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onSubmitted: (_) => _addTag(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add_circle, size: 28),
                onPressed: _addTag,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(_strings.wiki_cancel),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(_tags),
                child: Text(_strings.wiki_save),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
