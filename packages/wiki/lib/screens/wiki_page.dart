import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wiki/gen/strings.dart';
import 'package:wiki/widgets/graph_canvas.dart';
import 'package:wiki/providers/category_provider.dart';
import 'package:knode_app/screens/settings_page.dart';

final _strings = const L10nStringsMixin();

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
  String _currentCategoryName = _strings.wiki_all_knowledge;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static final List<_CategoryEntry> _categories = [
    _CategoryEntry(id: 'all', name: _strings.wiki_all_knowledge, icon: Icons.home_outlined),
    _CategoryEntry(id: 'notes', name: _strings.wiki_notes, icon: Icons.note_outlined),
    _CategoryEntry(id: 'study', name: _strings.wiki_study_materials, icon: Icons.menu_book_outlined),
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
                  SnackBar(content: Text(': ')),
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
                        SnackBar(content: Text(_strings.wiki_add_category)),
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
                                SnackBar(content: Text(': ')),
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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final drawerWidth = screenWidth >= 600 ? screenWidth * 0.4 : screenWidth * 0.75;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_currentCategoryName),
        centerTitle: true,
        leading: Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.person,
                  color:
                      Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_tree_outlined),
            tooltip: _strings.wiki_category_panel,
            onPressed: _openCategoryPanel,
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              CircleAvatar(
                radius: 36,
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.person,
                  size: 36,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Knode User',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.bookmark_border),
                title: Text(_strings.wiki_all_knowledge),
                onTap: () => Navigator.of(context).pop(),
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: Text(_strings.wiki_notes),
                onTap: () => Navigator.of(context).pop(),
              ),
              ListTile(
                leading: const Icon(Icons.cloud_upload_outlined),
                title: Text(_strings.wiki_study_materials),
                onTap: () => Navigator.of(context).pop(),
              ),
              const Spacer(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SettingsPage()));
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GraphCanvas(
              nodes: [
                GraphNode(
                  id: '1',
                  label: _strings.wiki_all_knowledge,
                  position: const Offset(300, 300),
                  width: 120,
                  height: 120,
                  type: NodeType.category,
                  categoryId: 0,
                  gradientColors: [Color(0xFF90CAF9), Color(0xFF42A5F5), Color(0xFF1565C0)],
                ),
                GraphNode(
                  id: '2',
                  label: _strings.wiki_notes,
                  position: const Offset(500, 200),
                  width: 80,
                  height: 80,
                  type: NodeType.category,
                  categoryId: 1,
                  gradientColors: [Color(0xFF64B5F6), Color(0xFF1E88E5), Color(0xFF0D47A1)],
                ),
                GraphNode(
                  id: '3',
                  label: _strings.wiki_study_materials,
                  position: const Offset(500, 400),
                  width: 80,
                  height: 80,
                  type: NodeType.category,
                  categoryId: 2,
                  gradientColors: [Color(0xFF81C784), Color(0xFF43A047), Color(0xFF1B5E20)],
                ),
                GraphNode(
                  id: '4',
                  label: _strings.wiki_work,
                  position: const Offset(100, 400),
                  width: 80,
                  height: 80,
                  type: NodeType.category,
                  categoryId: 3,
                  gradientColors: [Color(0xFFCE93D8), Color(0xFF8E24AA), Color(0xFF4A148C)],
                ),
                GraphNode(
                  id: '5',
                  label: _strings.wiki_ideas,
                  position: const Offset(100, 200),
                  width: 80,
                  height: 80,
                  type: NodeType.category,
                  categoryId: 4,
                  gradientColors: [Color(0xFFFFB74D), Color(0xFFFB8C00), Color(0xFFE65100)],
                ),
              ],
              edges: [
                GraphEdge(id: 'e1', sourceId: '1', targetId: '2', type: EdgeType.categoryArticle),
                GraphEdge(id: 'e2', sourceId: '1', targetId: '3', type: EdgeType.categoryArticle),
                GraphEdge(id: 'e3', sourceId: '1', targetId: '4', type: EdgeType.categoryArticle),
                GraphEdge(id: 'e4', sourceId: '1', targetId: '5', type: EdgeType.categoryArticle),
              ],
              onNodeTap: (node) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('\: ')),
                );
              },
            );
          },
        ),
      ),
      endDrawer: _CategoryDrawer(
        categories: _categories,
        selectedId: 'all',
        width: drawerWidth,
        onSelected: _onCategorySelected,
        onManage: () => _showCategoryManager(context),
      ),
      endDrawerEnableOpenDragGesture: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateNodeDialog(context);
        },
        tooltip: _strings.wiki_create_node,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category Panel (Right Drawer)
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
                      color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    ),
                    title: Text(
                      cat.name,
                      style: textTheme.bodyLarge?.copyWith(
                        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.w600 : null,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () => onSelected(cat),
                  );
                },
              ),
            ),
            const Divider(height: 1),
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
// Category Data Model (Page Internal)
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
