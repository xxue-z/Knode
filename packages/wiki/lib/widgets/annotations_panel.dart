import 'package:flutter/material.dart';
import 'package:core/models/bookmark.dart';
import 'package:core/models/highlight.dart';
import 'package:wiki/gen/strings.dart';

final _strings = const L10nStringsMixin();

/// 标注面板类型
enum AnnotationsTab { bookmarks, highlights }

/// 标注面板（右侧边栏）
class AnnotationsPanel extends StatefulWidget {
  final List<Bookmark> bookmarks;
  final List<Highlight> highlights;
  final ValueChanged<Bookmark> onBookmarkTap;
  final ValueChanged<Highlight> onHighlightTap;
  final ValueChanged<Bookmark> onBookmarkDelete;
  final ValueChanged<Highlight> onHighlightDelete;

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
  State<AnnotationsPanel> createState() => _AnnotationsPanelState();
}

class _AnnotationsPanelState extends State<AnnotationsPanel> {
  AnnotationsTab _currentTab = AnnotationsTab.bookmarks;

  @override
  Widget build(BuildContext context) {
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
                      label: _strings.bookmark,
                      icon: Icons.bookmark,
                      isActive: _currentTab == AnnotationsTab.bookmarks,
                      onTap: () => setState(() => _currentTab = AnnotationsTab.bookmarks),
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
                      label: _strings.highlight,
                      icon: Icons.border_color,
                      isActive: _currentTab == AnnotationsTab.highlights,
                      onTap: () => setState(() => _currentTab = AnnotationsTab.highlights),
                      count: widget.highlights.length,
                    ),
                  ),
                ],
              ),
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
            if (count > 0) ...[
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
  final List<Bookmark> bookmarks;
  final ValueChanged<Bookmark> onTap;
  final ValueChanged<Bookmark> onDelete;

  const _BookmarksList({
    required this.bookmarks,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (bookmarks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(_strings.no_bookmarks),
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
          onTap: () => onTap(bookmark),
          onDelete: () => onDelete(bookmark),
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
                  if (bookmark.label != null && bookmark.label!.isNotEmpty) ...[
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
  final List<Highlight> highlights;
  final ValueChanged<Highlight> onTap;
  final ValueChanged<Highlight> onDelete;

  const _HighlightsList({
    required this.highlights,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (highlights.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(_strings.no_highlights),
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
          onTap: () => onTap(highlight),
          onDelete: () => onDelete(highlight),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = highlight.style.color;

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
                  if (highlight.noteText != null && highlight.noteText!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      highlight.noteText!,
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
