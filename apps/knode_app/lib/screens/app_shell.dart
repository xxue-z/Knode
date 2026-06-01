import 'package:flutter/material.dart';
import 'package:knode_app/gen/strings.dart';
import 'package:knode_app/screens/home_page.dart';
import 'package:wiki/screens/wiki_page.dart';
import 'package:chat/screens/chat_page.dart';
import 'package:quiz/screens/quiz_page.dart';
import 'package:knode_app/screens/settings_page.dart';

final _strings = const L10nStringsMixin();

/// Root scaffold of the Knode knowledge-management app.
///
/// Provides a top [AppBar] with an avatar-triggered [Drawer],
/// an [IndexedStack] for tab-page persistence, and a Material 3
/// [BottomNavigationBar] with four destinations.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  List<String> get _tabTitles => [_strings.knode_app_home, 'Wiki', 'Chat', 'Quiz'];

  static const _tabIcons = <IconData>[
    Icons.home,
    Icons.menu_book,
    Icons.chat,
    Icons.quiz,
  ];

  static final _pages = <Widget>[
    const HomePage(),
    const WikiPage(),
    const ChatPage(),
    const QuizPage(),
  ];

  void _onTabChanged(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
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
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tabTitles[_currentIndex]),
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
      drawer: _buildDrawer(context),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabChanged,
        destinations: List.generate(
          _tabTitles.length,
          (i) => NavigationDestination(
            icon: Icon(_tabIcons[i]),
            label: _tabTitles[i],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}