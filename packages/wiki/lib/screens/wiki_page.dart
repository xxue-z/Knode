import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wiki/gen/strings.dart';
import 'package:wiki/widgets/graph_canvas.dart';
import 'package:wiki/widgets/graph_edge.dart' show EdgeType;
import 'package:wiki/providers/category_provider.dart';
import 'package:wiki/providers/document_provider.dart';
import 'package:wiki/providers/graph_provider.dart' hide GraphNode, GraphEdge;
import 'package:wiki/services/import_service.dart';
import 'package:wiki/screens/editor_page.dart';
import 'package:wiki/utils/graph_theme.dart';
import 'package:knode_app/screens/settings_page.dart';

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
  String _currentCategoryName = _strings.wiki_all_knowledge;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // 初始加载所有文档并构建图谱
    Future.microtask(() {
      ref.read(documentListProvider.notifier).filterByCategory(null);
      ref.read(graphProvider.notifier).buildGraph('all');
    });
  }

  static final List<_CategoryEntry> _categories = [
    _CategoryEntry(
      id: 'all',
      name: _strings.wiki_all_knowledge,
      icon: Icons.home_outlined,
    ),
    _CategoryEntry(
      id: 'notes',
      name: _strings.wiki_notes,
      icon: Icons.note_outlined,
    ),
    _CategoryEntry(
      id: 'study',
      name: _strings.wiki_study_materials,
      icon: Icons.menu_book_outlined,
    ),
    _CategoryEntry(
      id: 'work',
      name: _strings.wiki_work,
      icon: Icons.work_outline,
    ),
    _CategoryEntry(
      id: 'ideas',
      name: _strings.wiki_ideas,
      icon: Icons.lightbulb_outline,
    ),
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

  /// Shows the create/add menu with options for new document, import, and node.
  void _showCreateMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.note_add_outlined),
              title: const Text('新建文档'),
              subtitle: const Text('创建空白 Markdown 文档'),
              onTap: () {
                Navigator.pop(ctx);
                _createNewDocument(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file_outlined),
              title: const Text('导入文件'),
              subtitle: const Text('支持 PDF、Word、Markdown、TXT'),
              onTap: () {
                Navigator.pop(ctx);
                _importFile(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_tree_outlined),
              title: Text(_strings.wiki_create_node),
              subtitle: const Text('在知识图谱中创建节点'),
              onTap: () {
                Navigator.pop(ctx);
                _showCreateNodeDialog(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Creates a new blank Markdown document and opens the editor.
  Future<void> _createNewDocument(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('新建文档'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入文档标题',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => Navigator.pop(ctx, controller.text.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_strings.wiki_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(_strings.wiki_confirm),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty || !context.mounted) return;

    try {
      final notifier = ref.read(documentListProvider.notifier);
      final doc = await notifier.createDocument(
        categoryId: 1,
        title: result,
        initialContent: '# $result\n\n',
      );
      if (!context.mounted) return;

      if (doc != null) {
        // 刷新文档列表和图谱
        ref.read(documentListProvider.notifier).filterByCategory(null);
        ref.read(graphProvider.notifier).buildGraph('all');

        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditorPage(docId: doc.id, title: doc.title),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('创建文档失败，请重试')));
      }
    } catch (e, stack) {
      debugPrint('创建文档异常: $e\n$stack');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('创建文档失败: $e')));
      }
    }
  }

  /// Imports a file (PDF/Word/MD/TXT) and creates a document from it.
  Future<void> _importFile(BuildContext context) async {
    try {
      final service = ImportService();
      final result = await service.pickAndImport();

      if (result != null && context.mounted) {
        final title = result['title'] ?? '导入文档';
        final content = result['content'] ?? '';

        final notifier = ref.read(documentListProvider.notifier);
        final doc = await notifier.createDocument(
          categoryId: 1,
          title: title,
          initialContent: content,
        );

        if (doc != null && context.mounted) {
          // 刷新文档列表和图谱
          ref.read(documentListProvider.notifier).filterByCategory(null);
          ref.read(graphProvider.notifier).buildGraph('all');

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('已导入: $title')));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditorPage(docId: doc.id, title: doc.title),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('导入失败: $e')));
      }
    }
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
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(': ')));
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
                  Text(
                    _strings.wiki_manage_categories,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
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
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(': ')));
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

  // Demo data used as fallback when the graph provider has no data.
  List<GraphNode> _demoNodes() {
    return [
      GraphNode(
        id: '1',
        label: _strings.wiki_all_knowledge,
        position: const Offset(300, 300),
        width: 120,
        height: 120,
        type: NodeType.category,
        categoryId: 0,
        gradientColors: GraphTheme.getGradientForCategory(0),
      ),
      GraphNode(
        id: '2',
        label: _strings.wiki_notes,
        position: const Offset(200, 400),
        width: 80,
        height: 80,
        type: NodeType.category,
        categoryId: 1,
        gradientColors: GraphTheme.getGradientForCategory(1),
      ),
      GraphNode(
        id: '3',
        label: _strings.wiki_study_materials,
        position: const Offset(400, 400),
        width: 80,
        height: 80,
        type: NodeType.category,
        categoryId: 2,
        gradientColors: GraphTheme.getGradientForCategory(2),
      ),
      GraphNode(
        id: '4',
        label: _strings.wiki_work,
        position: const Offset(200, 200),
        width: 80,
        height: 80,
        type: NodeType.category,
        categoryId: 3,
        gradientColors: GraphTheme.getGradientForCategory(3),
      ),
      GraphNode(
        id: '5',
        label: _strings.wiki_ideas,
        position: const Offset(400, 200),
        width: 80,
        height: 80,
        type: NodeType.category,
        categoryId: 4,
        gradientColors: GraphTheme.getGradientForCategory(4),
      ),
    ];
  }

  List<GraphEdge> _demoEdges() {
    return [
      GraphEdge(
        id: 'e1',
        sourceId: '1',
        targetId: '2',
        type: EdgeType.reference,
      ),
      GraphEdge(
        id: 'e2',
        sourceId: '1',
        targetId: '3',
        type: EdgeType.reference,
      ),
      GraphEdge(
        id: 'e3',
        sourceId: '1',
        targetId: '4',
        type: EdgeType.reference,
      ),
      GraphEdge(
        id: 'e4',
        sourceId: '1',
        targetId: '5',
        type: EdgeType.reference,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final drawerWidth = screenWidth >= 600
        ? screenWidth * 0.4
        : screenWidth * 0.75;
    final graphState = ref.watch(graphProvider);

    // Use provider data when available, fall back to demo data.
    final providerNodes = graphState.value?.nodes;
    final providerEdges = graphState.value?.edges;
    final nodes = providerNodes != null
        ? providerNodes
              .map(
                (n) => GraphNode(
                  id: n.id,
                  label: n.title,
                  position: n.position,
                  type: n.categoryId != null
                      ? NodeType.category
                      : NodeType.article,
                  categoryId: n.categoryId,
                  gradientColors: n.categoryId != null
                      ? GraphTheme.getGradientForCategory(n.categoryId!)
                      : null,
                  tags: n.tags,
                ),
              )
              .toList()
        : _demoNodes();
    final edges = providerEdges != null
        ? providerEdges
              .map(
                (e) => GraphEdge(
                  id: '${e.sourceId}-${e.targetId}',
                  sourceId: e.sourceId,
                  targetId: e.targetId,
                  type: e.type,
                  similarity: e.similarity,
                ),
              )
              .toList()
        : _demoEdges();

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
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  );
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
              nodes: nodes,
              edges: edges,
              onNodeTap: (node) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('\: ')));
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
          _showCreateMenu(context);
        },
        tooltip: '新建',
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
                    selectedTileColor: colorScheme.primaryContainer.withValues(
                      alpha: 0.3,
                    ),
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
