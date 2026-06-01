import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz/providers/quiz_provider.dart';
import 'package:knode_app/gen/strings.dart';

final _strings = const L10nStringsMixin();

/// 首页随机速记卡片，点击实时生成题目。
class QuickCard extends ConsumerWidget {
  const QuickCard({super.key, this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap ?? () => _startQuickQuiz(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.flash_on, color: Theme.of(context).colorScheme.tertiary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_strings.knode_app_quick_card, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      '基于最近阅读文件出题',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  void _startQuickQuiz(BuildContext context, WidgetRef ref) {
    ref.read(quizProvider.notifier).startQuiz(count: 10);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_strings.knode_app_quiz_started_switch_tab)),
    );
  }
}