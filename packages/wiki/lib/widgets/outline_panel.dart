
import 'package:flutter/material.dart';
import 'package:core/core.dart' as core;
import 'package:wiki/utils/heading_extractor.dart';

/// 目录/标题导航面板
class OutlinePanel extends StatelessWidget {
  final List&lt;HeadingItem&gt; headings;
  final ValueChanged&lt;HeadingItem&gt; onHeadingTap;
  final int? activeOffset;

  const OutlinePanel({
    super.key,
    required this.headings,
    required this.onHeadingTap,
    this.activeOffset,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = core.CoreLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      width: 280,
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            // 头部
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.list_outlined, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    l10n.outline,
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            // 标题列表
            Expanded(
              child: headings.isEmpty
                  ? Center(child: Text(l10n.noHeadings))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: headings.length,
                      itemBuilder: (context, index) {
                        final heading = headings[index];
                        final isActive = activeOffset != null &amp;&amp;
                            heading.offset == activeOffset;
                        return _HeadingListItem(
                          heading: heading,
                          isActive: isActive,
                          onTap: () =&gt; onHeadingTap(heading),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeadingListItem extends StatelessWidget {
  final HeadingItem heading;
  final bool isActive;
  final VoidCallback onTap;

  const _HeadingListItem({
    required this.heading,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final level = heading.level;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(
          left: 16.0 + (level - 1) * 16,
          right: 16,
          top: 8,
          bottom: 8,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primaryContainer
              : Colors.transparent,
          border: isActive
              ? Border(
                  left: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 3,
                  ),
                )
              : null,
        ),
        child: Text(
          heading.text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isActive
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurface,
            fontWeight: level &lt;= 2 ? FontWeight.w500 : FontWeight.normal,
            fontSize: 16 - (level - 1) * 2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
