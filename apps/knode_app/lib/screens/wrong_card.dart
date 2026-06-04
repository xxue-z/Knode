import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz/providers/quiz_provider.dart';
import 'package:knode_app/gen/strings.dart';

final _strings = const L10nStringsMixin();

/// 首页错题本方块卡片，点击跳转到错题复习。
class WrongCard extends ConsumerWidget {
  const WrongCard({super.key, this.onNavigateToTab});
  final void Function(int pageIndex)? onNavigateToTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(questionRepositoryProvider);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: InkWell(
        onTap: () => onNavigateToTab?.call(3), // 暂跳转到 Quiz 页
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surfaceContainerLowest,
                Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 36,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 8),
                Text(
                  _strings.knode_app_wrong_card,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                FutureBuilder<List>(
                  future: repo.getWrongQuestions(limit: 100),
                  builder: (ctx, snap) {
                    if (!snap.hasData) {
                      return Text(
                        _strings.knode_app_loading,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      );
                    }
                    final count = snap.data!.length;
                    return Text(
                      count > 0 ? '$count 待复习' : _strings.knode_app_no_wrong_cards,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
