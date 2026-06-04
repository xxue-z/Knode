import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz/providers/quiz_provider.dart';
import 'package:knode_app/gen/strings.dart';

final _strings = const L10nStringsMixin();

/// 首页随机速记方块卡片，点击跳转到答题页。
class QuickCard extends ConsumerWidget {
  const QuickCard({super.key, this.onNavigateToTab});
  final void Function(int pageIndex)? onNavigateToTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: InkWell(
        onTap: () {
          ref.read(quizProvider.notifier).startQuiz(count: 10);
          onNavigateToTab?.call(3); // 跳转到 Quiz 页
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surfaceContainerLowest,
                Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.3),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.flash_on,
                  size: 36,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                const SizedBox(height: 8),
                Text(
                  _strings.knode_app_quick_card,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _strings.knode_app_based_on_recent,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
