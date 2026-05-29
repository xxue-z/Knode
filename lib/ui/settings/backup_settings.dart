import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import '../../services/backup_service.dart';

class BackupSettingsPage extends ConsumerStatefulWidget {
  const BackupSettingsPage({super.key});
  @override
  ConsumerState<BackupSettingsPage> createState() => _BackupSettingsPageState();
}

class _BackupSettingsPageState extends ConsumerState<BackupSettingsPage> {
  final _urlController = TextEditingController();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _backupService = BackupService();
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = ref.read(settingsProvider).valueOrNull ?? {};
      _urlController.text = s['webdav_url'] ?? '';
      _userController.text = s['webdav_user'] ?? '';
      _passController.text = s['webdav_pass'] ?? '';
    });
  }

  Future<void> _testConnection() async {
    setState(() => _isTesting = true);
    _backupService.configure(url: _urlController.text, user: _userController.text, pass: _passController.text);
    final ok = await _backupService.testConnection();
    setState(() => _isTesting = false);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? '连接成功' : '连接失败'), backgroundColor: ok ? Colors.green : Colors.red));
  }

  Future<void> _save() async {
    final notifier = ref.read(settingsProvider.notifier);
    await notifier.set('webdav_url', _urlController.text);
    await notifier.set('webdav_user', _userController.text);
    await notifier.set('webdav_pass', _passController.text);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已保存')));
  }

  @override
  void dispose() { _urlController.dispose(); _userController.dispose(); _passController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WebDAV 备份'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _urlController, decoration: const InputDecoration(labelText: 'WebDAV URL', border: OutlineInputBorder(), hintText: 'https://example.com/dav')),
          const SizedBox(height: 12),
          TextField(controller: _userController, decoration: const InputDecoration(labelText: '账号', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _passController, obscureText: true, decoration: const InputDecoration(labelText: '密码', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          Row(children: [
            OutlinedButton(onPressed: _isTesting ? null : _testConnection, child: _isTesting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('测试连接')),
            const SizedBox(width: 12),
            FilledButton(onPressed: _save, child: const Text('保存')),
          ]),
        ],
      ),
    );
  }
}