import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz/providers/exam_provider.dart';
import 'package:knode_app/gen/strings.dart';

final _strings = const L10nStringsMixin();

/// 首页最近成绩方块卡片，点击跳转到成绩页。
class ScoreCard extends ConsumerWidget {
  const ScoreCard({super.key, this.onNavigateToTab});
  final void Function(int pageIndex)? onNavigateToTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examsAsync = ref.watch(examListProvider);

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
                Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bar_chart,
                  size: 36,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  _strings.knode_app_score_card,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                examsAsync.when(
                  data: (exams) {
                    if (exams.isEmpty) {
                      return Text(
                        _strings.knode_app_no_exam_records,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      );
                    }
                    final recent = exams.take(3).toList();
                    final avgScore = recent.fold<double>(0, (sum, e) {
                      final s = e.obtainedScore ?? 0;
                      final t = e.totalScore ?? 100;
                      return sum + (t > 0 ? s / t * 100 : 0);
                    }) / recent.length;
                    return Text(
                      'Avg ${avgScore.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                  loading: () => Text(
                    _strings.knode_app_loading,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  error: (e, _) => Text(
                    _strings.knode_app_load_failed,
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
