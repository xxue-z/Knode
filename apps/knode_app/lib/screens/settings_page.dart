import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/providers/settings_provider.dart';
import 'package:knode_app/gen/strings.dart';
import 'package:knode_app/screens/ai_settings.dart';
import 'package:knode_app/screens/backup_settings.dart';
import 'package:knode_app/screens/prompt_management_screen.dart';

final _strings = const L10nStringsMixin();

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(_strings.knode_app_settings), centerTitle: true),
      body: ListView(
        children: [
          _Section(title: _strings.knode_app_ai_settings, children: [
            _SettingsTile(
              icon: Icons.language,
              title: _strings.knode_app_web_search,
              subtitle: _strings.knode_app_web_search_subtitle,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiSettingsPage())),
            ),
            _SettingsTile(
              icon: Icons.smart_toy_outlined,
              title: _strings.knode_app_ai_engine,
              subtitle: _strings.knode_app_ai_engine_subtitle,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiSettingsPage())),
            ),
            _SettingsTile(
              icon: Icons.edit_note,
              title: _strings.knode_app_prompt_management,
              subtitle: _strings.knode_app_prompt_management_subtitle,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PromptManagementScreen())),
            ),
          ]),
          _Section(title: _strings.knode_app_storage_settings, children: [
            _SettingsTile(
              icon: Icons.folder_outlined,
              title: _strings.knode_app_storage_path,
              subtitle: _strings.knode_app_storage_path_subtitle,
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.backup_outlined,
              title: _strings.knode_app_backup_settings,
              subtitle: _strings.knode_app_webdav_subtitle,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupSettingsPage())),
            ),
          ]),
          _Section(title: _strings.knode_app_about, children: [
            _SettingsTile(
              icon: Icons.info_outline,
              title: _strings.knode_app_version,
              subtitle: 'v1.0.0',
              onTap: () {},
            ),
          ]),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          )),
        ),
        ...children,
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  const _SettingsTile({required this.icon, required this.title, required this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}