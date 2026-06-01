import 'package:flutter/material.dart';
import 'package:wiki/gen/strings.dart';

final _strings = const L10nStringsMixin();

/// 引用浮窗组件。
///
/// 点击引用角标弹出，显示引用文档的原文片段，
/// 可点击跳转到源文档。
class CitationPopup extends StatelessWidget {
  const CitationPopup({
    super.key,
    required this.snippet,
    required this.docId,
    required this.docTitle,
    this.onTapSource,
  });

  /// 引用片段内容。
  final String snippet;

  /// 源文档 id。
  final int docId;

  /// 源文档标题。
  final String docTitle;

  /// 点击跳转到源文档的回调。
  final VoidCallback? onTapSource;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      alignment: Alignment.center,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题行。
              Row(
                children: [
                  Icon(
                    Icons.format_quote,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _strings.wiki_citation,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 引用片段。
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border(
                    left: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  snippet,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),

              // 源文档信息 + 跳转按钮。
              Row(
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      docTitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onTapSource?.call();
                    },
                    icon: const Icon(Icons.open_in_new, size: 14),
                    label: Text(_strings.wiki_view_source, style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}