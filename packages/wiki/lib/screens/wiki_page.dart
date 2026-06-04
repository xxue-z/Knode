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
import 'package:core/models/document.dart';
import 'package:core/models/category.dart';

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

class _WikiPageState extends ConsumerState<WikiPage>
    with WidgetsBindingObserver {
  int _currentCategoryId = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 延迟加载，避免在 widget tree 构建期间修改 provider
    Future.microtask(_loadData);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  void _loadData() {
    ref.read(documentListProvider.notifier).filterByCategory(null);
    ref.read(graphProvider.notifier).buildGraph('all');
  }



  void _onCategorySelected(Category category) {
    setState(() {
      _currentCategoryId = category.id;
    });
    Navigator.of(context).pop();
  }

  String _getCategoryName() {
    if (_currentCategoryId == 0) return _strings.wiki_all_documents;
    final catState = ref.read(categoryListProvider).value;
    if (catState == null) return _strings.wiki_all_documents;
    try {
      final cat = catState.allCategories.firstWhere((Category c) => c.id == _currentCategoryId);
      return cat.name;
    } catch (_) {
      return _strings.wiki_all_documents;
    }
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
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Creates a new blank Markdown document and opens the editor.
  Future<void> _createNewDocument(BuildContext context) async {
    final titleController = TextEditingController();
    final categorySearchController = TextEditingController();
    int? selectedCategoryId;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text(_strings.wiki_add_document),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Category selector (searchable dropdown)
                  Consumer(
                    builder: (ctx, ref, _) {
                      final catState = ref.watch(categoryListProvider);
                      return catState.when(
                        data: (state) {
                          final categories = state.allCategories
                              .where((c) => c.parentId == 0)
                              .toList()
                            ..sort(
                                (a, b) => a.sortOrder.compareTo(b.sortOrder));
                          final searchText =
                              categorySearchController.text.toLowerCase();
                          final filtered = searchText.isEmpty
                              ? categories
                              : categories
                                  .where((c) => c.name
                                      .toLowerCase()
                                      .contains(searchText))
                                  .toList();
                          final showCreateNew = searchText.isNotEmpty &&
                              !categories.any((c) =>
                                  c.name.toLowerCase() == searchText);

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: categorySearchController,
                                decoration: InputDecoration(
                                  labelText: _strings.wiki_category,
                                  hintText: _strings.wiki_search,
                                  prefixIcon: const Icon(
                                      Icons.folder_outlined),
                                  border: const OutlineInputBorder(),
                                  suffixIcon: categorySearchController
                                          .text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear,
                                              size: 18),
                                          onPressed: () {
                                            categorySearchController.clear();
                                            setDialogState(() {});
                                          },
                                        )
                                      : null,
                                ),
                                onChanged: (_) => setDialogState(() {}),
                              ),
                              const SizedBox(height: 8),
                              if (filtered.isNotEmpty)
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxHeight: 180),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: filtered.length,
                                    itemBuilder: (ctx, index) {
                                      final cat = filtered[index];
                                      final isSelected =
                                          selectedCategoryId == cat.id;
                                      return ListTile(
                                        dense: true,
                                        leading: Icon(
                                          isSelected
                                              ? Icons.check_circle
                                              : Icons.circle_outlined,
                                          size: 18,
                                          color: isSelected
                                              ? Theme.of(ctx)
                                                  .colorScheme
                                                  .primary
                                              : null,
                                        ),
                                        title: Text(cat.name),
                                        onTap: () {
                                          setDialogState(() {
                                            selectedCategoryId = cat.id;
                                            categorySearchController.text =
                                                cat.name;
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                              if (showCreateNew)
                                ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.add_circle_outline,
                                      size: 18),
                                  title: Text(
                                      '创建类目: "${categorySearchController.text}"'),
                                  onTap: () async {
                                    final newName =
                                        categorySearchController.text.trim();
                                    if (newName.isEmpty) return;
                                    final notifier = ref.read(
                                        categoryListProvider.notifier);
                                    await notifier.add(newName, 0);
                                    if (!ctx.mounted) return;
                                    final newState = ref
                                        .read(categoryListProvider)
                                        .value;
                                    if (newState != null) {
                                      final newCat = newState.allCategories
                                          .where((c) =>
                                              c.name == newName &&
                                              c.parentId == 0)
                                          .toList();
                                      if (newCat.isNotEmpty) {
                                        setDialogState(() {
                                          selectedCategoryId = newCat.first.id;
                                          categorySearchController.text =
                                              newName;
                                        });
                                      }
                                    }
                                  },
                                ),
                              if (filtered.isEmpty && !showCreateNew)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text('暂无类目'),
                                ),
                            ],
                          );
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.all(16),
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        ),
                        error: (e, _) => Text('加载失败: $e'),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  // Title input
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: _strings.wiki_document_title,
                      hintText: '输入文档标题',
                      prefixIcon: const Icon(Icons.description_outlined),
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) {
                      final title = titleController.text.trim();
                      if (title.isNotEmpty) {
                        Navigator.pop(ctx, {
                          'title': title,
                          'categoryId': selectedCategoryId ?? 0,
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(_strings.wiki_cancel),
              ),
              FilledButton(
                onPressed: () {
                  final title = titleController.text.trim();
                  if (title.isNotEmpty) {
                    Navigator.pop(ctx, {
                      'title': title,
                      'categoryId': selectedCategoryId ?? 0,
                    });
                  }
                },
                child: Text(_strings.wiki_confirm),
              ),
            ],
          );
        },
      ),
    );

    if (result == null || !context.mounted) return;
    final title = result['title'] as String? ?? '';
    if (title.isEmpty) return;
    final categoryId = result['categoryId'] as int? ?? 0;

    try {
      final notifier = ref.read(documentListProvider.notifier);
      final doc = await notifier.createDocument(
        categoryId: categoryId,
        title: title,
        initialContent: '# $title\n\n',
      );
      if (!context.mounted) return;

      if (doc != null) {
        _loadData();

        if (context.mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => EditorPage(docId: doc.id, title: doc.title),
            ),
          );
          _loadData();
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
          _loadData();

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('已导入: $title')));
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditorPage(docId: doc.id, title: doc.title),
            ),
          );
          // 从编辑器返回后再次刷新
          _loadData();
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
                    onPressed: () => _addCategory(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  final catState = ref.watch(categoryListProvider);
                  return catState.when(
                    data: (state) {
                      final categories = state.allCategories;
                      if (categories.isEmpty) {
                        return const Center(child: Text('暂无类目'));
                      }
                      return ListView.builder(
                        controller: controller,
                        itemCount: categories.length,
                        itemBuilder: (_, index) {
                          final cat = categories[index];
                          return ListTile(
                            leading: const Icon(Icons.folder_outlined),
                            title: Text(cat.name),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _renameCategory(context, cat.id, cat.name),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('加载失败: $e')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addCategory(BuildContext context) {
    final controller = TextEditingController();
    showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_strings.wiki_add_category),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入类目名称',
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
    ).then((name) {
      if (name != null && name.isNotEmpty) {
        ref.read(categoryListProvider.notifier).add(name, 0);
      }
    });
  }

  void _renameCategory(BuildContext context, int catId, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_strings.wiki_rename_category),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入新名称',
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
    ).then((newName) {
      if (newName != null && newName.isNotEmpty && newName != currentName) {
        ref.read(categoryListProvider.notifier).rename(catId, newName);
      }
    });
  }

  // Demo data used as fallback when the graph provider has no data.
  List<GraphNode> _demoNodes() {
    return [
      GraphNode(
        id: '1',
        label: _strings.wiki_all_documents,
        position: const Offset(300, 300),
        width: 120,
        height: 120,
        type: NodeType.category,
        categoryId: 0,
        gradientColors: GraphTheme.getGradientForCategory(0),
      ),
      GraphNode(
        id: '3',
        label: _strings.wiki_study_materials,
        position: const Offset(200, 400),
        width: 80,
        height: 80,
        type: NodeType.category,
        categoryId: 2,
        gradientColors: GraphTheme.getGradientForCategory(2),
      ),
      GraphNode(
        id: '4',
        label: _strings.wiki_work,
        position: const Offset(400, 400),
        width: 80,
        height: 80,
        type: NodeType.category,
        categoryId: 3,
        gradientColors: GraphTheme.getGradientForCategory(3),
      ),
      GraphNode(
        id: '5',
        label: _strings.wiki_ideas,
        position: const Offset(300, 200),
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
        title: Text(_getCategoryName()),
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
      drawer: _WikiDrawer(documents: ref.watch(documentListProvider).value?.documents ?? []),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GraphCanvas(
              nodes: nodes,
              edges: edges,
              brightness: Theme.of(context).brightness,
              onNodeTap: (node) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(': ')));
              },
            );
          },
        ),
      ),
      endDrawer: _CategoryDrawer(
        selectedId: _currentCategoryId,
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
// Wiki Left Drawer (Reading Stats + Document Tree)
// ---------------------------------------------------------------------------

class _WikiDrawer extends StatefulWidget {
  const _WikiDrawer({required this.documents});

  final List<Document> documents;

  @override
  State<_WikiDrawer> createState() => _WikiDrawerState();
}

class _WikiDrawerState extends State<_WikiDrawer> {
  final ScrollController _scrollController = ScrollController();
  final Set<int> _expandedCategories = {};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatReadingTime(int seconds) {
    if (seconds < 60) return '0${_strings.wiki_min}';
    final m = seconds ~/ 60;
    return '$m${_strings.wiki_min}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Calculate reading stats
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    int todaySeconds = 0;
    int totalSeconds = 0;
    for (final doc in widget.documents) {
      totalSeconds += doc.readingTime;
      if (doc.lastReadAt != null) {
        final lastRead = DateTime.tryParse(doc.lastReadAt!);
        if (lastRead != null && lastRead.isAfter(todayStart)) {
          todaySeconds += doc.readingTime;
        }
      }
    }

    // Get recent 3 documents sorted by lastReadAt
    final recentDocs = List<Document>.from(widget.documents)
      ..sort((a, b) {
        if (a.lastReadAt == null) return 1;
        if (b.lastReadAt == null) return -1;
        return b.lastReadAt!.compareTo(a.lastReadAt!);
      });
    final lastThree = recentDocs
        .where((d) => d.lastReadAt != null)
        .take(3)
        .toList();

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // === TOP 1/3: Reading Stats ===
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  children: [
                    // Top half: two stat blocks
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatBlock(
                              icon: Icons.today,
                              label: _strings.wiki_today_reading,
                              value: _formatReadingTime(todaySeconds),
                              color: colorScheme.primaryContainer,
                              iconColor: colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _StatBlock(
                              icon: Icons.schedule,
                              label: _strings.wiki_total_reading,
                              value: _formatReadingTime(totalSeconds),
                              color: colorScheme.tertiaryContainer,
                              iconColor: colorScheme.onTertiaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Bottom half: last 3 articles
                    if (lastThree.isNotEmpty)
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '最近阅读',
                              style: textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              child: Column(
                                children: lastThree.map((doc) => Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.article_outlined,
                                            size: 14,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              doc.title,
                                              style: textTheme.bodySmall,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            _formatReadingTime(doc.readingTime),
                                            style: textTheme.bodySmall?.copyWith(
                                              color: colorScheme.onSurfaceVariant,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),

            // === BOTTOM 2/3: Document Tree ===
            Expanded(
              flex: 2,
              child: Scrollbar(
                thumbVisibility: true,
                controller: _scrollController,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      _buildAllDocsSection(colorScheme, textTheme),
                      _buildNotesSection(colorScheme, textTheme),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllDocsSection(ColorScheme colorScheme, TextTheme textTheme) {
    return ExpansionTile(
      leading: Icon(Icons.folder_outlined, color: colorScheme.onSurfaceVariant),
      title: Text(
        _strings.wiki_all_documents,
        style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      children: [
        // Category tree from provider
        Consumer(
          builder: (context, ref, _) {
            final catState = ref.watch(categoryListProvider);
            return catState.when(
              data: (state) {
                final tree = state.tree;
                if (tree.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('暂无类目'),
                  );
                }
                return Column(
                  children: tree.map((node) {
                    return _buildCategoryNode(node, colorScheme, textTheme);
                  }).toList(),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('加载失败: $e'),
              ),
            );
          },
        ),
      ],
      onExpansionChanged: (expanded) {
        if (expanded) _scrollToBottom();
      },
    );
  }

  Widget _buildCategoryNode(
    CategoryTreeNode node,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final catId = node.category.id;
    final isExpanded = _expandedCategories.contains(catId);
    final hasChildren = node.children.isNotEmpty;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: PageStorageKey<String>('cat_$catId'),
        initiallyExpanded: isExpanded,
        tilePadding: const EdgeInsets.only(left: 16, right: 8),
        childrenPadding: const EdgeInsets.only(left: 16),
        leading: Icon(
          hasChildren ? Icons.folder_outlined : Icons.description_outlined,
          size: 20,
          color: colorScheme.onSurfaceVariant,
        ),
        title: Text(
          node.category.name,
          style: textTheme.bodyMedium,
        ),
        children: [
          // Sub-categories
          ...node.children.map(
            (child) => _buildCategoryNode(child, colorScheme, textTheme),
          ),
          // Documents in this category
          _CategoryDocuments(categoryId: catId),
        ],
        onExpansionChanged: (expanded) {
          setState(() {
            if (expanded) {
              _expandedCategories.add(catId);
            } else {
              _expandedCategories.remove(catId);
            }
          });
          if (expanded) _scrollToBottom();
        },
      ),
    );
  }

  Widget _buildNotesSection(ColorScheme colorScheme, TextTheme textTheme) {
    final notes = widget.documents.where((d) => d.sourceDocId != null).toList()
      ..sort((a, b) {
        if (a.lastReadAt == null) return 1;
        if (b.lastReadAt == null) return -1;
        return b.lastReadAt!.compareTo(a.lastReadAt!);
      });

    return ExpansionTile(
      leading: Icon(Icons.note_outlined, color: colorScheme.onSurfaceVariant),
      title: Text(
        _strings.wiki_notes,
        style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      onExpansionChanged: (expanded) {
        if (expanded) _scrollToBottom();
      },
      children: notes.isEmpty
          ? [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  _strings.wiki_no_documents,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ]
          : notes
              .map(
                (doc) => ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.only(left: 16, right: 8),
                  leading: Icon(
                    Icons.note,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  title: Text(
                    doc.title,
                    style: textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => EditorPage(
                          docId: doc.id,
                          title: doc.title,
                        ),
                      ),
                    );
                  },
                ),
              )
              .toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Category Documents (loaded lazily per category)
// ---------------------------------------------------------------------------

class _CategoryDocuments extends ConsumerWidget {
  const _CategoryDocuments({required this.categoryId});

  final int categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docState = ref.watch(documentListProvider);
    return docState.when(
      data: (state) {
        // If filtering by a different category, we need all docs.
        // Use the repository directly for category-specific queries.
        return FutureBuilder<List<Document>>(
          future: ref.read(documentRepositoryProvider).getByCategory(categoryId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(8),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
            final docs = snapshot.data ?? [];
            if (docs.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              children: docs
                  .map(
                    (doc) => ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.only(left: 32, right: 8),
                      leading: Icon(
                        Icons.description_outlined,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      title: Text(
                        doc.title,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => EditorPage(
                              docId: doc.id,
                              title: doc.title,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                  .toList(),
            );
          },
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

// ---------------------------------------------------------------------------
// Stat Block (Drawer Header)
// ---------------------------------------------------------------------------

class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category Panel (Right Drawer)
// ---------------------------------------------------------------------------

class _CategoryDrawer extends ConsumerWidget {
  const _CategoryDrawer({
    required this.selectedId,
    required this.width,
    required this.onSelected,
    this.onManage,
  });

  final int selectedId;
  final double width;
  final ValueChanged<Category> onSelected;
  final VoidCallback? onManage;

  static const _defaultIcons = [
    Icons.menu_book_outlined,
    Icons.work_outline,
    Icons.lightbulb_outline,
    Icons.science_outlined,
    Icons.code_outlined,
    Icons.palette_outlined,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final catState = ref.watch(categoryListProvider);

    final categories = catState.whenOrNull(
      data: (state) => state.allCategories
          .where((c) => c.parentId == 0)
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
    );

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
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.home_outlined,
                      color: selectedId == 0
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                    title: Text(
                      _strings.wiki_all_documents,
                      style: textTheme.bodyLarge?.copyWith(
                        color: selectedId == 0
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                        fontWeight: selectedId == 0 ? FontWeight.w600 : null,
                      ),
                    ),
                    selected: selectedId == 0,
                    selectedTileColor:
                        colorScheme.primaryContainer.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () => onSelected(const Category(
                      id: 0, name: "", parentId: 0,
                      sortOrder: 0, createdAt: "", updatedAt: "",
                    )),
                  ),
                  if (categories != null)
                    for (int i = 0; i < categories.length; i++)
                      ListTile(
                        leading: Icon(
                          _defaultIcons[i % _defaultIcons.length],
                          color: selectedId == categories[i].id
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                        title: Text(
                          categories[i].name,
                          style: textTheme.bodyLarge?.copyWith(
                            color: selectedId == categories[i].id
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                            fontWeight: selectedId == categories[i].id
                                ? FontWeight.w600
                                : null,
                          ),
                        ),
                        selected: selectedId == categories[i].id,
                        selectedTileColor:
                            colorScheme.primaryContainer.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onTap: () => onSelected(categories[i]),
                      ),
                ],
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


