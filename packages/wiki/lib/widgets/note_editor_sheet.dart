import 'package:flutter/material.dart';
import 'package:core/services/app_logger.dart';

/// 笔记输入底部弹窗。
///
/// 返回用户输入的笔记文本，若用户取消则返回 null。
class NoteEditorSheet extends StatefulWidget {
  final String selectedText;

  const NoteEditorSheet({super.key, required this.selectedText});

  /// 显示笔记输入弹窗，返回笔记文本或 null。
  static Future<String?> show(BuildContext context, String selectedText) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => NoteEditorSheet(selectedText: selectedText),
    );
  }

  @override
  State<NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends State<NoteEditorSheet> {
  final TextEditingController _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Text('添加笔记', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          // 选中文字预览
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.selectedText,
              style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          // 笔记输入框
          TextField(
            controller: _noteController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: '输入笔记内容...',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          // 按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('跳过'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  final note = _noteController.text.trim();
                  AppLogger.instance.d('笔记输入完成: ${note.length} 字', tag: 'NoteEditor');
                  Navigator.pop(context, note.isEmpty ? null : note);
                },
                child: const Text('保存'),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}
