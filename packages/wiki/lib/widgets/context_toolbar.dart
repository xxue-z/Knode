import 'package:flutter/material.dart';
import 'package:core/services/app_logger.dart';
import 'package:wiki/gen/strings.dart';

/// 工具栏菜单项定义。
class ToolbarMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ToolbarMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

/// 上下文浮动工具栏。
///
/// 定位到选中区域上方或下方，水平滚动按钮栏。
class ContextToolbar extends StatelessWidget {
  final List<ToolbarMenuItem> items;
  final bool showAbove;

  const ContextToolbar({
    super.key,
    required this.items,
    this.showAbove = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.95),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: items.map((item) => _ToolbarButton(item: item)).toList(),
          ),
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final ToolbarMenuItem item;
  const _ToolbarButton({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        AppLogger.instance.d('工具栏点击: ${item.label}', tag: 'ContextToolbar');
        item.onTap();
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 20, color: theme.colorScheme.onSurface),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// 构建阅读器上下文菜单项列表。
List<ToolbarMenuItem> buildReaderMenuItems({
  required VoidCallback onCopy,
  required VoidCallback onBookmark,
  required VoidCallback onReadAloud,
  required VoidCallback onDictionary,
  required VoidCallback onBrowserSearch,
  required VoidCallback onAskAI,
  required VoidCallback onFullTextSearch,
  required VoidCallback onKnowledgeSearch,
  required VoidCallback onHighlightNote,
}) {
  return [
    ToolbarMenuItem(icon: Icons.copy, label: '复制', onTap: onCopy),
    ToolbarMenuItem(icon: Icons.bookmark_add, label: '书签', onTap: onBookmark),
    ToolbarMenuItem(icon: Icons.volume_up, label: '朗读', onTap: onReadAloud),
    ToolbarMenuItem(icon: Icons.menu_book, label: '字典', onTap: onDictionary),
    ToolbarMenuItem(icon: Icons.open_in_browser, label: '浏览器搜索', onTap: onBrowserSearch),
    ToolbarMenuItem(icon: Icons.psychology, label: '问问AI', onTap: onAskAI),
    ToolbarMenuItem(icon: Icons.find_in_page, label: '全文搜索', onTap: onFullTextSearch),
    ToolbarMenuItem(icon: Icons.search, label: '知识库搜索', onTap: onKnowledgeSearch),
    ToolbarMenuItem(icon: Icons.highlight, label: '划重点', onTap: onHighlightNote),
  ];
}
