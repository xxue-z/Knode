import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import 'ai_settings.dart';
import 'backup_settings.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置'), centerTitle: true),
      body: ListView(
        children: [
          _Section(title: 'AI 设置', children: [
            _SettingsTile(
              icon: Icons.smart_toy_outlined,
              title: 'AI 引擎',
              subtitle: '本地模型管理、云端 API 配置',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiSettingsPage())),
            ),
          ]),
          _Section(title: '存储', children: [
            _SettingsTile(
              icon: Icons.folder_outlined,
              title: '存储路径',
              subtitle: '管理知识库文件存储位置',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.backup_outlined,
              title: '备份与恢复',
              subtitle: 'WebDAV / 本地备份',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupSettingsPage())),
            ),
          ]),
          _Section(title: '关于', children: [
            _SettingsTile(
              icon: Icons.info_outline,
              title: '版本',
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