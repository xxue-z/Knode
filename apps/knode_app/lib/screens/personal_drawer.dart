import 'package:flutter/material.dart';
import 'package:knode_app/screens/settings_page.dart';

class PersonalDrawer extends StatelessWidget {
  const PersonalDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // ===== Header =====
            DrawerHeader(
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: colorScheme.primary,
                    child: Icon(
                      Icons.person,
                      size: 36,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Knode',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    'Tap to sign in',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            // ===== Body (placeholder items) =====
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.bar_chart_rounded),
                    title: const Text('Reading Stats'),
                    subtitle: const Text('Coming soon'),
                    enabled: false,
                    onTap: null,
                  ),
                  ListTile(
                    leading: const Icon(Icons.quiz_rounded),
                    title: const Text('Quiz Overview'),
                    subtitle: const Text('Coming soon'),
                    enabled: false,
                    onTap: null,
                  ),
                  ListTile(
                    leading: const Icon(Icons.bookmark_border_rounded),
                    title: const Text('Bookmarks'),
                    subtitle: const Text('Coming soon'),
                    enabled: false,
                    onTap: null,
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: const Text('About'),
                    subtitle: const Text('Coming soon'),
                    enabled: false,
                    onTap: null,
                  ),
                ],
              ),
            ),

            // ===== Settings (fixed at bottom) =====
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.settings_rounded),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
