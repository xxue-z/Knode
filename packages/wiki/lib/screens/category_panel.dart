import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wiki/gen/strings.dart';

import 'package:wiki/screens/category_tree.dart';

final _strings = const L10nStringsMixin();

/// 右滑类目面板组件。
///
/// 从右侧滑出的半透明面板，显示层级目录树。
/// 支持右滑拉出、点击遮罩关闭。
class CategoryPanel extends ConsumerStatefulWidget {
  const CategoryPanel({
    super.key,
    this.onCategorySelected,
    this.selectedCategoryId,
  });

  /// 类目被选中时的回调。
  final ValueChanged<int?>? onCategorySelected;

  /// 当前选中的类目 id。
  final int? selectedCategoryId;

  @override
  ConsumerState<CategoryPanel> createState() => _CategoryPanelState();
}

class _CategoryPanelState extends ConsumerState<CategoryPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    await _controller.reverse();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final panelWidth = screenWidth >= 600 ? screenWidth * 0.4 : screenWidth * 0.75;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          children: [
            // 半透明遮罩。
            GestureDetector(
              onTap: _close,
              child: Container(
                color: Colors.black.withValues(alpha: 0.4 * _fadeAnimation.value),
              ),
            ),
            // 右侧滑入面板。
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: panelWidth,
              child: SlideTransition(
                position: _slideAnimation,
                child: Material(
                  color: Theme.of(context).colorScheme.surface,
                  elevation: 8,
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 面板标题。
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            _strings.wiki_category,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const Divider(height: 1),
                        // 「全部知识」选项。
                        ListTile(
                          leading: const Icon(Icons.home_outlined),
                          title: Text(_strings.wiki_all_knowledge),
                          selected: widget.selectedCategoryId == null,
                          selectedTileColor: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onTap: () {
                            widget.onCategorySelected?.call(null);
                            _close();
                          },
                        ),
                        const Divider(height: 1),
                        // 类目树。
                        Expanded(
                          child: CategoryTree(
                            selectedCategoryId: widget.selectedCategoryId,
                            onCategorySelected: (id) {
                              widget.onCategorySelected?.call(id);
                              _close();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 打开类目面板的便捷方法。
void showCategoryPanel(
  BuildContext context, {
  ValueChanged<int?>? onCategorySelected,
  int? selectedCategoryId,
}) {
  showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    builder: (_) => CategoryPanel(
      onCategorySelected: onCategorySelected,
      selectedCategoryId: selectedCategoryId,
    ),
  );
}