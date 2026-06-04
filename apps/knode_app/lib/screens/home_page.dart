import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:knode_app/gen/strings.dart';
import 'package:knode_app/screens/daily_card.dart';
import 'package:knode_app/screens/quick_card.dart';
import 'package:knode_app/screens/score_card.dart';
import 'package:knode_app/screens/wrong_card.dart';
import 'package:knode_app/screens/settings_page.dart';
import 'package:knode_app/screens/theme/home_theme.dart';
import 'package:knode_app/providers/theme_provider.dart';

const _strings = L10nStringsMixin();

/// 首页，展示每日一测、随机速记、最近成绩、错题本等卡片。
class HomePage extends ConsumerWidget {
  const HomePage({super.key, this.onNavigateToTab});

  /// 切换底部导航 tab 的回调（参数为页面索引：0=Wiki, 1=Home, 2=Chat, 3=Quiz）
  final void Function(int pageIndex)? onNavigateToTab;

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
        drawer: Drawer(
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                CircleAvatar(
                  radius: 36,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    size: 36,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Knode User',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Divider(height: 32),
                ListTile(
                  leading: const Icon(Icons.bookmark_border),
                  title: Text(_strings.knode_app_favorites),
                  onTap: () => Navigator.of(context).pop(),
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(_strings.knode_app_browse_history),
                  onTap: () => Navigator.of(context).pop(),
                ),
                ListTile(
                  leading: const Icon(Icons.cloud_upload_outlined),
                  title: Text(_strings.knode_app_cloud_sync),
                  onTap: () => Navigator.of(context).pop(),
                ),
                const Spacer(),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: Text(_strings.knode_app_settings),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SettingsPage()));
                  },
                ),
              ],
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

              // 功能入口：2x2 方块网格
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.2,
                children: [
                  DailyCard(onNavigateToTab: onNavigateToTab),
                  QuickCard(onNavigateToTab: onNavigateToTab),
                  ScoreCard(onNavigateToTab: onNavigateToTab),
                  WrongCard(onNavigateToTab: onNavigateToTab),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
