import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:knode_app/screens/home_page.dart';
import 'package:knode_app/providers/nav_config_provider.dart';
import 'package:knode_app/widgets/floating_chat_ball.dart';
import 'package:wiki/screens/wiki_page.dart';
import 'package:quiz/screens/quiz_page.dart';
import 'package:chat/screens/chat_page.dart';

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
      bottomNavigationBar: NavigationBar(
        height: 60, // 减小导航栏高度
        selectedIndex: _currentIndex.clamp(0, visibleTabs.length - 1),
        onDestinationSelected: (index) => _onTabChanged(index),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide, // 隐藏标签
        destinations: visibleTabs.map((tab) {
          return NavigationDestination(
            icon: Icon(tab.icon),
            selectedIcon: Icon(tab.icon),
            label: '', // 不显示文字
          );
        }).toList(),
      ),
    );
  }
}
