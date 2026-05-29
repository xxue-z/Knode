import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/category_provider.dart';

/// 层级目录树组件。
///
/// 支持无限层级展开/折叠，长按弹出操作菜单（重命名/删除/移动），
/// 点击类目过滤图谱。
class CategoryTree extends ConsumerStatefulWidget {
  const CategoryTree({
    super.key,
    this.selectedCategoryId,
    this.onCategorySelected,
  });

  final int? selectedCategoryId;
  final ValueChanged<int?>? onCategorySelected;

  @override
  ConsumerState<CategoryTree> createState() => _CategoryTreeState();
}

class _CategoryTreeState extends ConsumerState<CategoryTree> {
  /// 已展开的类目 id 集合。
  final Set<int> _expandedIds = {};

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryListProvider);
    return categoryState.when(
      data: (state) {
        final tree = state.tree;
        if (tree.isEmpty) {
          return const Center(child: Text('暂无类目'));
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: tree.length,
          itemBuilder: (context, index) {
            return _buildTreeNode(tree[index], depth: 0);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败: $e')),
    );
  }

  Widget _buildTreeNode(CategoryTreeNode node, {required int depth}) {
    final hasChildren = node.children.isNotEmpty;
    final isExpanded = _expandedIds.contains(node.category.id);
    final isSelected = widget.selectedCategoryId == node.category.id;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => widget.onCategorySelected?.call(node.category.id),
          onLongPress: () => _showContextMenu(node.category),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.only(
              left: 16.0 + depth * 24.0,
              right: 16.0,
              top: 6.0,
              bottom: 6.0,
            ),
            child: Row(
              children: [
                // 展开/折叠箭头。
                if (hasChildren)
                  GestureDetector(
                    onTap: () => _toggleExpand(node.category.id),
                    child: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  const SizedBox(width: 20),
                const SizedBox(width: 8),
                // 类目名称。
                Expanded(
                  child: Text(
                    node.category.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // 子类目计数。
                if (hasChildren)
                  Text(
                    '${node.children.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ),
        // 子节点（展开时渲染）。
        if (hasChildren && isExpanded)
          ...node.children.map(
            (child) => _buildTreeNode(child, depth: depth + 1),
          ),
      ],
    );
  }

  void _toggleExpand(int categoryId) {
    setState(() {
      if (_expandedIds.contains(categoryId)) {
        _expandedIds.remove(categoryId);
      } else {
        _expandedIds.add(categoryId);
      }
    });
  }

  void _showContextMenu(Category category) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('重命名'),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(category);
              },
            ),
            ListTile(
              leading: const Icon(Icons.drive_file_move_outlined),
              title: const Text('移动到'),
              onTap: () {
                Navigator.pop(context);
                _showMoveDialog(category);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                '删除',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(category);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(Category category) {
    final controller = TextEditingController(text: category.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重命名类目'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '类目名称'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref
                    .read(categoryListProvider.notifier)
                    .rename(category.id, name);
              }
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showMoveDialog(Category category) {
    final state = ref.read(categoryListProvider).valueOrNull;
    if (state == null) return;
    final candidates = state.allCategories
        .where((c) => c.id != category.id)
        .toList();
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          children: [
            ListTile(
              title: const Text('根目录'),
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(categoryListProvider.notifier)
                    .move(category.id, 0);
              },
            ),
            ...candidates.map((c) => ListTile(
                  title: Text(c.name),
                  onTap: () {
                    Navigator.pop(context);
                    ref
                        .read(categoryListProvider.notifier)
                        .move(category.id, c.id);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除类目'),
        content: Text('确定删除「${category.name}」？子类目将移至根目录。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              ref.read(categoryListProvider.notifier).delete(category.id);
              Navigator.pop(context);
            },
            child: const Text('删除',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
