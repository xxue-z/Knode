import 'package:flutter/material.dart';

/// 知识图谱页面骨架
///
/// 包含 [GraphCanvas] 画布和右侧类目面板入口（EndDrawer）。
/// 使用 Material 3 组件，响应式适配手机与平板布局。
class WikiPage extends StatefulWidget {
  const WikiPage({super.key});

  @override
  State<WikiPage> createState() => _WikiPageState();
}

class _WikiPageState extends State<WikiPage> {
  /// 当前选中的类目名称，显示在 AppBar 标题。
  String _currentCategoryName = '全部知识';

  /// 全局 Key 用于控制 EndDrawer（右侧类目面板）。
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// 模拟的类目列表，后续从数据库加载。
  static const List<_CategoryEntry> _categories = [
    _CategoryEntry(id: 'all', name: '全部知识', icon: Icons.home_outlined),
    _CategoryEntry(id: 'notes', name: '笔记', icon: Icons.note_outlined),
    _CategoryEntry(
      id: 'study',
      name: '学习资料',
      icon: Icons.menu_book_outlined,
    ),
    _CategoryEntry(id: 'work', name: '工作', icon: Icons.work_outline),
    _CategoryEntry(id: 'ideas', name: '灵感', icon: Icons.lightbulb_outline),
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    // 响应式：平板（>= 600px）时 Drawer 宽度取屏幕 40%，否则取 75%。
    final drawerWidth =
        screenWidth >= 600 ? screenWidth * 0.4 : screenWidth * 0.75;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_currentCategoryName),
        centerTitle: true,
        actions: [
          // 右侧类目面板入口按钮（显式入口，配合右滑手势使用）。
          IconButton(
            icon: const Icon(Icons.account_tree_outlined),
            tooltip: '类目面板',
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
      ),
      endDrawerEnableOpenDragGesture: true,
      // 浮动按钮：快速添加新节点。
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO(P1): 跳转到新建文档/节点页面
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('新建节点 - 待实现')),
          );
        },
        tooltip: '新建节点',
        child: const Icon(Icons.add),
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
            '知识图谱',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '图谱画布待实现',
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
  });

  final List<_CategoryEntry> categories;
  final String selectedId;
  final double width;
  final ValueChanged<_CategoryEntry> onSelected;

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
                '类目',
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
                  // TODO(P1): 管理类目页面
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('管理类目 - 待实现')),
                  );
                },
                icon: const Icon(Icons.settings_outlined, size: 18),
                label: const Text('管理类目'),
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
