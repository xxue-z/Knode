
import 'package:flutter/material.dart';
import 'package:core/core.dart' as core;
import 'package:core/models/bookmark.dart';
import 'package:core/models/highlight.dart';

/// 标注面板类型
enum AnnotationsTab { bookmarks, highlights }

/// 标注面板（右侧边栏
class AnnotationsPanel extends StatefulWidget {
  final List&lt;Bookmark&gt; bookmarks;
  final List&lt;Highlight&gt; highlights;
  final ValueChanged&lt;Bookmark&gt; onBookmarkTap;
  final ValueChanged&lt;Highlight&gt; onHighlightTap;
  final ValueChanged&lt;Bookmark&gt; onBookmarkDelete;
  final ValueChanged&lt;Highlight&gt; onHighlightDelete;

  const AnnotationsPanel({
    super.key,
    required this.bookmarks,
    required this.highlights,
    required this.onBookmarkTap,
    required this.onHighlightTap,
    required this.onBookmarkDelete,
    required this.onHighlightDelete,
  });

  @override
  State&lt;AnnotationsPanel&gt; createState() =&gt; _AnnotationsPanelState();
}

class _AnnotationsPanelState extends State&lt;AnnotationsPanel&gt; {
  AnnotationsTab _currentTab = AnnotationsTab.bookmarks;

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
          // 头部标签
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            child: Row(
              children: [
              Expanded(
                child: _TabButton(
                  label: l10n.bookmark,
                  icon: Icons.bookmark,
                  isActive: _currentTab == AnnotationsTab.bookmarks,
                  onTap: () =&gt; setState(() =&gt; _currentTab = AnnotationsTab.bookmarks),
                  count: widget.bookmarks.length,
                ),
              ),
              Container(
                width: 1,
                color: theme.colorScheme.outline,
                height: 32,
              ),
              Expanded(
                child: _TabButton(
                  label: l10n.highlight,
                  icon: Icons.border_color,
                  isActive: _currentTab == AnnotationsTab.highlights,
                  onTap: () =&gt; setState(() =&gt; _currentTab = AnnotationsTab.highlights),
                  count: widget.highlights.length,
                ),
              ),
            ],
          ),
          // 内容区域
          Expanded(
            child: _currentTab == AnnotationsTab.bookmarks
                ? _BookmarksList(
                    bookmarks: widget.bookmarks,
                    onTap: widget.onBookmarkTap,
                    onDelete: widget.onBookmarkDelete,
                  )
                : _HighlightsList(
                    highlights: widget.highlights,
                    onTap: widget.onHighlightTap,
                    onDelete: widget.onHighlightDelete,
                  ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final int count;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (count &gt; 0) ...[
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BookmarksList extends StatelessWidget {
  final List&lt;Bookmark&gt; bookmarks;
  final ValueChanged&lt;Bookmark&gt; onTap;
  final ValueChanged&lt;Bookmark&gt; onDelete;

  const _BookmarksList({
    required this.bookmarks,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = core.CoreLocalizations.of(context);
    final theme = Theme.of(context);

    if (bookmarks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.noBookmarks),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = bookmarks[index];
        return _BookmarkItem(
          bookmark: bookmark,
          onTap: () =&gt; onTap(bookmark),
          onDelete: () =&gt; onDelete(bookmark),
        );
      },
    );
  }
}

class _BookmarkItem extends StatelessWidget {
  final Bookmark bookmark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _BookmarkItem({
    required this.bookmark,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.bookmark, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (bookmark.label != null &amp;&amp; bookmark.label!.isNotEmpty) ...[
                    Text(
                      bookmark.label!,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    bookmark.selectedText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
              color: theme.colorScheme.error,
              iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightsList extends StatelessWidget {
  final List&lt;Highlight&gt; highlights;
  final ValueChanged&lt;Highlight&gt; onTap;
  final ValueChanged&lt;Highlight&gt; onDelete;

  const _HighlightsList({
    required this.highlights,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = core.CoreLocalizations.of(context);
    final theme = Theme.of(context);

    if (highlights.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.noHighlights),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: highlights.length,
      itemBuilder: (context, index) {
        final highlight = highlights[index];
        return _HighlightItem(
          highlight: highlight,
          onTap: () =&gt; onTap(highlight),
          onDelete: () =&gt; onDelete(highlight),
        );
      },
    );
  }
}

class _HighlightItem extends StatelessWidget {
  final Highlight highlight;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HighlightItem({
    required this.highlight,
    required this.onTap,
    required this.onDelete,
  });

  Color _getColor() {
    final hex = highlight.style.colorHex;
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getColor();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    highlight.selectedText,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (highlight.note != null &amp;&amp; highlight.note!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      highlight.note!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
              color: theme.colorScheme.error,
              iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }
}
