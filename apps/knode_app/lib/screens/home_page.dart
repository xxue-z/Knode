import 'package:flutter/material.dart';
import 'package:knode_app/screens/daily_card.dart';
import 'package:knode_app/screens/quick_card.dart';
import 'package:knode_app/screens/score_card.dart';
import 'package:knode_app/screens/wrong_card.dart';

/// 首页，展示每日一测、随机速记、最近成绩、错题本等卡片。
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 欢迎语
            Text(
              '欢迎回来',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '今天也要坚持学习哦',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),

            // 每日一测卡片
            const DailyCard(),
            const SizedBox(height: 12),

            // 随机速记卡片
            const QuickCard(),
            const SizedBox(height: 12),

            // 最近成绩卡片
            const ScoreCard(),
            const SizedBox(height: 12),

            // 错题本卡片
            const WrongCard(),
          ],
        ),
      ),
    );
  }
}
