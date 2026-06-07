import 'package:flutter/material.dart';
import 'package:knode_app/gen/strings.dart';
import 'package:knode_app/screens/ai_settings.dart';
import 'package:knode_app/screens/backup_settings.dart';
import 'package:knode_app/screens/log_viewer_screen.dart';
import 'package:knode_app/screens/storage_settings.dart';
import 'package:knode_app/screens/wiki_settings.dart';
import 'package:knode_app/screens/quiz_settings.dart';

const _strings = L10nStringsMixin();

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_strings.knode_app_settings), centerTitle: true),
      body: ListView(
        children: [
          _Section(title: _strings.knode_app_module_settings, children: [
            _SettingsTile(
              icon: Icons.book_outlined,
              title: _strings.knode_app_wiki_settings,
              subtitle: '',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WikiSettingsPage())),
            ),
            _SettingsTile(
              icon: Icons.smart_toy_outlined,
              title: _strings.knode_app_ai_settings,
              subtitle: '',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiSettingsPage())),
            ),
            _SettingsTile(
              icon: Icons.quiz_outlined,
              title: _strings.knode_app_quiz_settings,
              subtitle: '',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizSettingsPage())),
            ),
          ]),
          _Section(title: _strings.knode_app_storage_settings, children: [
            _SettingsTile(
              icon: Icons.backup_outlined,
              title: _strings.knode_app_backup_settings,
              subtitle: '',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupSettingsPage())),
            ),
            _SettingsTile(
              icon: Icons.folder_outlined,
              title: _strings.knode_app_storage_space,
              subtitle: '',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StorageSettingsPage())),
            ),
          ]),
          _Section(title: _strings.knode_app_advanced_settings, children: [
            _SettingsTile(
              icon: Icons.bug_report_outlined,
              title: _strings.knode_app_application_log,
              subtitle: '',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LogViewerScreen())),
            ),
          ]),
          _Section(title: _strings.knode_app_about, children: [
            _SettingsTile(
              icon: Icons.system_update_outlined,
              title: _strings.knode_app_check_update,
              subtitle: '',
              onTap: () {},
            ),
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
  const _SettingsTile({required this.icon, required this.title, this.subtitle = '', this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
