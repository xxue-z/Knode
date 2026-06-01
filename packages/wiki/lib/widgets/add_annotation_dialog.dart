
import 'package:flutter/material.dart';
import 'package:core/models/highlight_style.dart';
import 'package:core/core.dart' as core;
import 'package:wiki/widgets/highlight_style_picker.dart';

enum AnnotationType { highlight, bookmark }

class AddAnnotationDialog extends StatefulWidget {
  final AnnotationType type;
  final String selectedText;
  final HighlightStyle? initialStyle;
  final String? initialLabel;

  const AddAnnotationDialog({
    super.key,
    required this.type,
    required this.selectedText,
    this.initialStyle,
    this.initialLabel,
  });

  /// 显示对话框并返回结果
  static Future&lt;AddAnnotationResult?&gt; show({
    required BuildContext context,
    required AnnotationType type,
    required String selectedText,
    HighlightStyle? initialStyle,
    String? initialLabel,
  }) {
    return showDialog&lt;AddAnnotationResult&gt;(
      context: context,
      builder: (context) =&gt; AddAnnotationDialog(
        type: type,
        selectedText: selectedText,
        initialStyle: initialStyle,
        initialLabel: initialLabel,
      ),
    );
  }

  @override
  State&lt;AddAnnotationDialog&gt; createState() =&gt; _AddAnnotationDialogState();
}

class AddAnnotationResult {
  final HighlightStyle? style;
  final String? label;
  final String? note;

  AddAnnotationResult({
    this.style,
    this.label,
    this.note,
  });
}

class _AddAnnotationDialogState extends State&lt;AddAnnotationDialog&gt; {
  late HighlightStyle _style;
  final _noteController = TextEditingController();
  final _labelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _style = widget.initialStyle ?? HighlightStyle(type: HighlightType.background, colorHex: '#FFF176');
    _noteController.text = '';
    _labelController.text = widget.initialLabel ?? '';
  }

  @override
  void dispose() {
    _noteController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = core.CoreLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.type == AnnotationType.highlight ? l10n.addHighlight : l10n.addBookmark),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 显示选中的文本
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.selectedText,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            // 高亮特有：样式选择
            if (widget.type == AnnotationType.highlight) ...[
              HighlightStylePicker(
                initialStyle: _style,
                onStyleChanged: (style) =&gt; setState(() =&gt; _style = style),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: l10n.note,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
            // 书签特有：标签输入
            if (widget.type == AnnotationType.bookmark) ...[
              TextField(
                controller: _labelController,
                decoration: InputDecoration(
                  labelText: l10n.bookmark,
                  hintText: l10n.tapToSelect,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =&gt; Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(
              context,
              AddAnnotationResult(
                style: widget.type == AnnotationType.highlight ? _style : null,
                label: widget.type == AnnotationType.bookmark ? _labelController.text : null,
                note: widget.type == AnnotationType.highlight ? _noteController.text : null,
              ),
            );
          },
          child: Text(l10n.confirm),
        ),
      ],
    );
  }
}
