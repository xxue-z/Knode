import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz/providers/quiz_provider.dart';
import 'package:knode_app/gen/strings.dart';

final _strings = const L10nStringsMixin();

/// 首页每日一测方块卡片，点击跳转到答题页。
class DailyCard extends ConsumerWidget {
  const DailyCard({super.key, this.onNavigateToTab});
  final void Function(int pageIndex)? onNavigateToTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(dailyConfigProvider);

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
                Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.today,
                  size: 36,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  _strings.knode_app_daily_card,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                configAsync.when(
                  data: (config) {
                    final count = config?.questionCount ?? 10;
                    final isEnabled = config?.isEnabled == 1;
                    return Text(
                      isEnabled ? '$count questions' : 'Not enabled',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                  loading: () => Text(
                    _strings.knode_app_loading,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  error: (_, __) => Text(
                    _strings.knode_app_tap_to_start,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
