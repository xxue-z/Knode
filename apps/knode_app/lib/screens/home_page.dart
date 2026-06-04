import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:knode_app/gen/strings.dart';
import 'package:knode_app/screens/daily_card.dart';
import 'package:knode_app/screens/quick_card.dart';
import 'package:knode_app/screens/score_card.dart';
import 'package:knode_app/screens/wrong_card.dart';
import 'package:knode_app/screens/theme/home_theme.dart';
import 'package:knode_app/providers/theme_provider.dart';

const _strings = L10nStringsMixin();

/// 首页，展示每日一测、随机速记、最近成绩、错题本等卡片。
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final isDark = themeMode == ThemeMode.dark;
    final theme = HomeTheme.of(isDark: isDark);

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: theme.primaryColor,
          surface: theme.backgroundColor,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_strings.knode_app_home),
          leading: Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    color:
                        Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 欢迎语
              Text(
                _strings.knode_app_welcome_back,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _strings.knode_app_daily_encouragement,
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
      ),
    );
  }
}
