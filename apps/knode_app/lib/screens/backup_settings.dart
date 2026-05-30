import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/providers/settings_provider.dart';
import 'package:core/services/backup_service.dart';
import 'package:knode_app/gen/strings.dart';

final _strings = const L10nStringsMixin();

/// WebDAV 备份配置页面。
///
/// 包含 WebDAV 连接配置、测试连接、定时备份频率选择、手动备份/恢复。
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
  bool _isBacking = false;
  bool _isRestoring = false;
  String _backupFrequency = 'daily'; // daily / weekly / manual

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = ref.read(settingsProvider).valueOrNull ?? {};
      _urlController.text = s['webdav_url'] ?? '';
      _userController.text = s['webdav_user'] ?? '';
      _passController.text = s['webdav_pass'] ?? '';
      setState(() {
        _backupFrequency = s['webdav_frequency'] ?? 'daily';
      });
    });
  }

  void _configure() {
    _backupService.configure(
      url: _urlController.text,
      user: _userController.text,
      pass: _passController.text,
    );
  }

  Future<void> _testConnection() async {
    setState(() => _isTesting = true);
    _configure();
    final ok = await _backupService.testConnection();
    setState(() => _isTesting = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? '连接成功' : '连接失败'),
          backgroundColor: ok ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _backup() async {
    setState(() => _isBacking = true);
    _configure();
    try {
      final s = ref.read(settingsProvider).valueOrNull ?? {};
      final dbPath = s['db_path'] ?? 'knode.db';
      final wikiRoot = s['wiki_root'] ?? 'wiki_root';
      await _backupService.backup(dbPath: dbPath, wikiRoot: wikiRoot);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('备份完成'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('备份失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _isBacking = false);
  }

  Future<void> _restore() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('确认恢复'),
        content: const Text('恢复将覆盖当前数据，是否继续？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(_strings.knode_app_cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('恢复')),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isRestoring = true);
    _configure();
    try {
      final s = ref.read(settingsProvider).valueOrNull ?? {};
      final dbPath = s['db_path'] ?? 'knode.db';
      final wikiRoot = s['wiki_root'] ?? 'wiki_root';
      await _backupService.restore(dbPath: dbPath, wikiRoot: wikiRoot);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('恢复完成'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('恢复失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _isRestoring = false);
  }

  Future<void> _save() async {
    final notifier = ref.read(settingsProvider.notifier);
    await notifier.set('webdav_url', _urlController.text);
    await notifier.set('webdav_user', _userController.text);
    await notifier.set('webdav_pass', _passController.text);
    await notifier.set('webdav_frequency', _backupFrequency);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已保存')));
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _userController.dispose();
    _passController.dispose();
    _backupService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_strings.knode_app_webdav + ' 备份'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 连接配置
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'WebDAV URL',
              border: OutlineInputBorder(),
              hintText: 'https://example.com/dav',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _userController,
            decoration: const InputDecoration(
              labelText: '账号',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: '密码',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // 测试连接 + 保存
          Row(
            children: [
              OutlinedButton(
                onPressed: _isTesting ? null : _testConnection,
                child: _isTesting
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('测试连接'),
              ),
              const SizedBox(width: 12),
              FilledButton(onPressed: _save, child: Text(_strings.knode_app_save)),
            ],
          ),
          const Divider(height: 32),

          // 定时备份频率
          ListTile(
            title: const Text('定时备份频率'),
            subtitle: Text(_frequencyLabel(_backupFrequency)),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showFrequencySelector,
          ),
          const Divider(height: 32),

          // 手动备份/恢复
          Text('手动操作', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isBacking ? null : _backup,
                  icon: _isBacking
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.cloud_upload),
                  label: const Text('立即备份'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isRestoring ? null : _restore,
                  icon: _isRestoring
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.cloud_download),
                  label: const Text('恢复数据'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFrequencySelector() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('每天'),
              leading: Radio<String>(
                value: 'daily',
                groupValue: _backupFrequency,
                onChanged: (v) => _setFrequency(v!),
              ),
            ),
            ListTile(
              title: const Text('每周'),
              leading: Radio<String>(
                value: 'weekly',
                groupValue: _backupFrequency,
                onChanged: (v) => _setFrequency(v!),
              ),
            ),
            ListTile(
              title: Text(_strings.knode_app_auto_backup),
              leading: Radio<String>(
                value: 'manual',
                groupValue: _backupFrequency,
                onChanged: (v) => _setFrequency(v!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setFrequency(String freq) {
    setState(() => _backupFrequency = freq);
    Navigator.pop(context);
  }

  String _frequencyLabel(String freq) {
    switch (freq) {
      case 'daily':
        return '每天自动备份';
      case 'weekly':
        return '每周自动备份';
      case 'manual':
        return '仅手动备份';
      default:
        return freq;
    }
  }
}