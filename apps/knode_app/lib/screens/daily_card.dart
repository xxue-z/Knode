import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz/providers/quiz_provider.dart';
import 'package:quiz/providers/exam_provider.dart';
import 'package:knode_app/gen/strings.dart';

final _strings = const L10nStringsMixin();

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
                  Text(_strings.knode_app_daily_card, style: Theme.of(context).textTheme.titleSmall),
                ],
              ),
              const SizedBox(height: 12),
              configAsync.when(
                data: (config) {
                  final count = config?.questionCount ?? 10;
                  final isEnabled = config?.isEnabled == 1;
                  return Text(
                    isEnabled ? 'Today $count questions, tap to start' : 'Daily quiz not enabled',
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                },
                loading: () => Text(_strings.knode_app_loading),
                error: (_, __) => Text(_strings.knode_app_tap_to_start),
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () => _startDailyQuiz(context, ref),
                child: Text(_strings.knode_app_start_practice),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startDailyQuiz(BuildContext context, WidgetRef ref) {
    ref.read(quizProvider.notifier).startQuiz(count: 10);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_strings.knode_app_daily_quiz_started)),
    );
  }
}