import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz/providers/exam_provider.dart';
import 'package:knode_app/gen/strings.dart';

final _strings = const L10nStringsMixin();

/// 首页最近成绩卡片，显示最近 3 次考试成绩。
class ScoreCard extends ConsumerWidget {
  const ScoreCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examsAsync = ref.watch(examListProvider);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // 切换到测验 Tab（index 3）
          // 由于 ScoreCard 在 HomeTab 内，需要通过回调或导航实现
          // 目前显示提示
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('请切换到"测验"标签查看考试历史')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.bar_chart, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(_strings.knode_app_score_card, style: Theme.of(context).textTheme.titleSmall),
                ],
              ),
              const SizedBox(height: 12),
              examsAsync.when(
                data: (exams) {
                  if (exams.isEmpty) return const Text('暂无考试记录');
                  final recent = exams.take(3).toList();
                  return Column(
                    children: recent.map((exam) {
                      final score = exam.obtainedScore ?? 0;
                      final total = exam.totalScore ?? 100;
                      final percent = total > 0 ? (score / total * 100).toStringAsFixed(0) : '0';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                exam.title ?? '考试',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: score >= 60
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '$percent%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: score >= 60 ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('加载失败: $e'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}