import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/providers/theme_provider.dart';
import 'package:wiki/gen/strings.dart';
import 'package:wiki/theme/wiki_theme.dart';

final _strings = const L10nStringsMixin();

/// 知识图谱页面骨架
///
/// 包含 [GraphCanvas] 画布和右侧类目面板入口（EndDrawer）。
/// 使用 Material 3 组件，响应式适配手机与平板布局。
class WikiPage extends ConsumerStatefulWidget {
  const WikiPage({super.key});

  @override
  ConsumerState<WikiPage> createState() => _WikiPageState();
}

class _WikiPageState extends ConsumerState<WikiPage> {
  /// 当前选中的类目名称，显示在 AppBar 标题。
  String _currentCategoryName = _strings.wiki_all_knowledge;

  /// 全局 Key 用于控制 EndDrawer（右侧类目面板）。
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// 模拟的类目列表，后续从数据库加载。
  static final List<_CategoryEntry> _categories = [
    _CategoryEntry(id: 'all', name: _strings.wiki_all_knowledge, icon: Icons.home_outlined),
    _CategoryEntry(id: 'notes', name: _strings.wiki_notes, icon: Icons.note_outlined),
    _CategoryEntry(
      id: 'study',
      name: _strings.wiki_study_materials,
      icon: Icons.menu_book_outlined,
    ),
    _CategoryEntry(id: 'work', name: _strings.wiki_work, icon: Icons.work_outline),
    _CategoryEntry(id: 'ideas', name: _strings.wiki_ideas, icon: Icons.lightbulb_outline),
  ];

  void _onCategorySelected(_CategoryEntry category) {
    setState(() {
      _currentCategoryName = category.name;
    });
    Navigator.of(context).pop();
  }

  void _openCategoryPanel() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _showCreateNodeDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_strings.wiki_create_node),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: _strings.wiki_node_name,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_strings.wiki_cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (controller.text.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${_strings.wiki_create_node}: ${controller.text} - ${_strings.wiki_feature_development}')),
                );
              }
            },
            child: Text(_strings.wiki_confirm),
          ),
        ],
      ),
    );
  }

  void _showCategoryManager(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_strings.wiki_manage_categories, style: Theme.of(context).textTheme.titleMedium),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${_strings.wiki_add_category} ${_strings.wiki_feature_development}')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: _categories.length,
                itemBuilder: (_, index) {
                  final cat = _categories[index];
                  return ListTile(
                    leading: Icon(cat.icon),
                    title: Text(cat.name),
                    trailing: cat.id == 'all'
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${_strings.wiki_edit_category}: ${cat.name} - ${_strings.wiki_feature_development}')),
                              );
                            },
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);
    final isDark = themeMode == ThemeMode.dark;
    final theme = WikiTheme.of(isDark: isDark);

    final screenWidth = MediaQuery.sizeOf(context).width;

    // 响应式：平板（>= 600px）时 Drawer 宽度取屏幕 40%，否则取 75%。
    final drawerWidth =
        screenWidth >= 600 ? screenWidth * 0.4 : screenWidth * 0.75;

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: theme.primaryColor,
          surface: theme.backgroundColor,
        ),
      ),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(_currentCategoryName),
          centerTitle: true,
          actions: [
            // 右侧类目面板入口按钮（显式入口，配合右滑手势使用）。
            IconButton(
              icon: const Icon(Icons.account_tree_outlined),
              tooltip: _strings.wiki_category_panel,
              onPressed: _openCategoryPanel,
            ),
          ],
        ),
        // GraphCanvas 作为主画布区域。
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return _GraphCanvasPlaceholder(
                maxWidth: constraints.maxWidth,
                maxHeight: constraints.maxHeight,
              );
            },
          ),
        ),
        // 右侧类目面板（EndDrawer），支持右滑触发。
        endDrawer: _CategoryDrawer(
          categories: _categories,
          selectedId: 'all',
          width: drawerWidth,
          onSelected: _onCategorySelected,
          onManage: () => _showCategoryManager(context),
        ),
        endDrawerEnableOpenDragGesture: true,
        // 浮动按钮：快速添加新节点。
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showCreateNodeDialog(context);
          },
          tooltip: _strings.wiki_create_node,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// GraphCanvas 占位组件
//
// 当 graph/graph_canvas.dart 实现完成后，替换此占位为真正的 GraphCanvas。
// ---------------------------------------------------------------------------

class _GraphCanvasPlaceholder extends StatelessWidget {
  const _GraphCanvasPlaceholder({
    required this.maxWidth,
    required this.maxHeight,
  });

  final double maxWidth;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.hub_outlined,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            _strings.wiki_knowledge_graph,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _strings.wiki_graph_canvas_pending,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 类目面板（右侧 Drawer）
// ---------------------------------------------------------------------------

class _CategoryDrawer extends StatelessWidget {
  const _CategoryDrawer({
    required this.categories,
    required this.selectedId,
    required this.width,
    required this.onSelected,
    this.onManage,
  });

  final List<_CategoryEntry> categories;
  final String selectedId;
  final double width;
  final ValueChanged<_CategoryEntry> onSelected;
  final VoidCallback? onManage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Drawer(
      width: width,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 面板标题
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                _strings.wiki_category,
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const Divider(height: 1),
            // 类目列表
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = cat.id == selectedId;
                  return ListTile(
                    leading: Icon(
                      cat.icon,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                    title: Text(
                      cat.name,
                      style: textTheme.bodyLarge?.copyWith(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.w600 : null,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor:
                        colorScheme.primaryContainer.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () => onSelected(cat),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            // 底部操作
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onManage?.call();
                },
                icon: const Icon(Icons.settings_outlined, size: 18),
                label: Text(_strings.wiki_manage_categories),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 类目数据模型（页面内部使用）
// ---------------------------------------------------------------------------

class _CategoryEntry {
  const _CategoryEntry({
    required this.id,
    required this.name,
    required this.icon,
  });

  final String id;
  final String name;
  final IconData icon;
}