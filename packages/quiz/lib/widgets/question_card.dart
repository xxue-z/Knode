import 'package:flutter/material.dart';
import 'package:core/services/app_logger.dart';

import '../gen/strings.dart';

const _strings = L10nStringsMixin();

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
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_strings.quiz_add_note, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: _strings.quiz_note_input_hint,
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(_strings.quiz_skip),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    AppLogger.instance.d('笔记输入完成: ${_noteController.text.length} 字', tag: 'NoteEditor');
                    Navigator.pop(context, _noteController.text);
                  },
                  child: Text(_strings.quiz_save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}