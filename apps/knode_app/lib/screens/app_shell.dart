import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:knode_app/gen/strings.dart';
import 'package:knode_app/screens/home_page.dart';
import 'package:knode_app/screens/settings_page.dart';
import 'package:knode_app/providers/nav_config_provider.dart';
import 'package:knode_app/providers/theme_provider.dart';
import 'package:knode_app/widgets/floating_chat_ball.dart';
import 'package:wiki/screens/wiki_page.dart';
import 'package:quiz/screens/quiz_page.dart';
import 'package:chat/screens/chat_page.dart';

final _strings = const L10nStringsMixin();

/// Root scaffold of the Knode knowledge-management app.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0;

  // 页面列表（包括隐藏的ChatPage）
  static final _pages = <Widget>[
    const WikiPage(),
    const HomePage(),
    const ChatPage(), // 保留但隐藏
    const QuizPage(),
  ];

  void _onTabChanged(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  int _getPageIndex(String tabId) {
    switch (tabId) {
      case 'wiki':
        return 0;
      case 'home':
        return 1;
      case 'chat':
        return 2;
      case 'quiz':
        return 3;
      default:
        return 0;
    }
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final navConfig = ref.watch(navConfigProvider);
    final visibleTabs = navConfig.getVisibleTabs();

    // 找到当前可见标签对应的页面索引
    final currentTabId = visibleTabs.isNotEmpty
        ? visibleTabs[_currentIndex.clamp(0, visibleTabs.length - 1)].id
        : 'wiki';
    final pageIndex = _getPageIndex(currentTabId);

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: pageIndex,
            children: _pages,
          ),
          const FloatingChatBall(),
        ],
      ),
      drawer: _buildDrawer(context),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex.clamp(0, visibleTabs.length - 1),
        onDestinationSelected: (index) => _onTabChanged(index),
        destinations: visibleTabs.map((tab) {
          return NavigationDestination(
            icon: Icon(tab.icon),
            selectedIcon: Icon(tab.icon),
            label: const SizedBox.shrink(), // 不显示文字
          );
        }).toList(),
      ),
    );
  }
}
