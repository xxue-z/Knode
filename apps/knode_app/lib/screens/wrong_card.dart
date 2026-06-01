import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz/providers/quiz_provider.dart';
import 'package:knode_app/gen/strings.dart';

final _strings = const L10nStringsMixin();

/// 首页最近错题卡片，显示错题总数，点击跳转错题本。
class WrongCard extends ConsumerWidget {
  const WrongCard({super.key, this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(questionRepositoryProvider);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_strings.knode_app_wrong_card, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    FutureBuilder<List>(
                      future: repo.getWrongQuestions(limit: 100),
                      builder: (ctx, snap) {
                        if (!snap.hasData) return Text(_strings.knode_app_loading);
                        final count = snap.data!.length;
                        return Text(
                          count > 0 ? '$count 道待复习' : '暂无错题',
                          style: Theme.of(context).textTheme.bodySmall,
                        );
                      },
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
}