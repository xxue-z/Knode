import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/extensions/riverpod_compat.dart';
import 'package:wiki/gen/strings.dart';

import 'package:core/models/category.dart';
import 'package:wiki/providers/category_provider.dart';

final _strings = const L10nStringsMixin();

/// 灞傜骇鐩綍鏍戠粍浠躲€?
///
/// 鏀寔鏃犻檺灞傜骇灞曞紑/鎶樺彔锛岄暱鎸夊脊鍑烘搷浣滆彍鍗曪紙閲嶅懡鍚?鍒犻櫎/绉诲姩锛夛紝
/// 鐐瑰嚮绫荤洰杩囨护鍥捐氨銆?
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
  /// 宸插睍寮€鐨勭被鐩?id 闆嗗悎銆?
  final Set<int> _expandedIds = {};

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryListProvider);
    return categoryState.when(
      data: (state) {
        final tree = state.tree;
        if (tree.isEmpty) {
          return Center(child: Text(_strings.wiki_no_categories));
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
      error: (e, _) => Center(child: Text('${_strings.wiki_error}: $e')),
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
                // 灞曞紑/鎶樺彔绠ご銆?
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
                // 绫荤洰鍚嶇О銆?
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
                // 瀛愮被鐩鏁般€?
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
        // 瀛愯妭鐐癸紙灞曞紑鏃舵覆鏌擄級銆?
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
              title: Text(_strings.wiki_rename),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(category);
              },
            ),
            ListTile(
              leading: const Icon(Icons.drive_file_move_outlined),
              title: Text(_strings.wiki_move_to),
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
                _strings.wiki_delete,
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
        title: Text(_strings.wiki_rename_category),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: _strings.wiki_category_name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_strings.wiki_cancel),
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
            child: Text(_strings.wiki_confirm),
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
              title: Text(_strings.wiki_root_directory),
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
        title: Text(_strings.wiki_delete_category),
        content: Text(_strings.wiki_delete_category_confirm(name: category.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_strings.wiki_cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(categoryListProvider.notifier).delete(category.id);
              Navigator.pop(context);
            },
            child: Text(_strings.wiki_delete,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}