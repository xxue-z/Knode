import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/exam_provider.dart';

/// 首页每日一测卡片，显示今日题目数量，点击进入答题。
class DailyCard extends ConsumerWidget {
  const DailyCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(dailyConfigProvider);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _startDailyQuiz(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.today, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text('每日一测', style: Theme.of(context).textTheme.titleSmall),
                ],
              ),
              const SizedBox(height: 12),
              configAsync.when(
                data: (config) {
                  final count = config?.questionCount ?? 10;
                  final isEnabled = config?.isEnabled == 1;
                  return Text(
                    isEnabled ? '今日 $count 题，点击开始' : '每日一测未启用',
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                },
                loading: () => const Text('加载中...'),
                error: (_, __) => const Text('点击开始练习'),
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () => _startDailyQuiz(context, ref),
                child: const Text('开始练习'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startDailyQuiz(BuildContext context, WidgetRef ref) {
    ref.read(quizProvider.notifier).startQuiz(count: 10);
    // TODO: 跳转到 ExamPage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('每日一测已开始')),
    );
  }
}
