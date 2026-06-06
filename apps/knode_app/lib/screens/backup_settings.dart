import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/extensions/riverpod_compat.dart';
import 'package:core/utils/file_picker_util.dart';
import 'package:core/providers/settings_provider.dart';
import 'package:core/services/backup_service.dart';
import 'package:core/services/local_backup_service.dart';
import 'package:core/models/backup_snapshot.dart';
import 'package:knode_app/gen/strings.dart';

final _strings = const L10nStringsMixin();

class BackupSettingsPage extends ConsumerStatefulWidget {
  const BackupSettingsPage({super.key});

  @override
  ConsumerState<BackupSettingsPage> createState() => _BackupSettingsPageState();
}

class _BackupSettingsPageState extends ConsumerState<BackupSettingsPage> {
  // WebDAV 控制器
  final _urlController = TextEditingController();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _backupService = BackupService();
  final _localBackupService = LocalBackupService();

  bool _isTesting = false;
  bool _isBacking = false;
  bool _isRestoring = false;
  String _backupFrequency = 'daily';
  List<BackupSnapshot> _webdavSnapshots = [];
  List<BackupSnapshot> _localSnapshots = [];
  bool _isLoadingSnapshots = false;
  double _backupProgress = -1;
  String _backupProgressMessage = '';
  int _keepCount = 5;
  String _localBackupPath = '';

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
        _keepCount = int.tryParse(s['backup_keep_count'] ?? '5') ?? 5;
        _localBackupPath = s['local_backup_path'] ?? '';
      });
      _loadSnapshots();
    });
  }

  void _configureWebDav() {
    _backupService.configure(
      url: _urlController.text,
      user: _userController.text,
      pass: _passController.text,
    );
  }

  bool get _isWebDavConfigured => _urlController.text.isNotEmpty && _userController.text.isNotEmpty;
  bool get _isLocalBackupConfigured => _localBackupPath.isNotEmpty;
  bool get _isAnyBackupConfigured => _isWebDavConfigured || _isLocalBackupConfigured;

  Future<void> _loadSnapshots() async {
    setState(() => _isLoadingSnapshots = true);

    // 加载 WebDAV 快照
    if (_isWebDavConfigured) {
      _configureWebDav();
      try {
        final snapshots = await _backupService.listBackups();
        if (mounted) setState(() => _webdavSnapshots = snapshots);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(': '), backgroundColor: Colors.red),
          );
        }
      }
    }

    // 加载本地快照
    if (_isLocalBackupConfigured) {
      try {
        final snapshots = await _localBackupService.listBackups(_localBackupPath);
        if (mounted) setState(() => _localSnapshots = snapshots);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(': '), backgroundColor: Colors.red),
          );
        }
      }
    }

    setState(() => _isLoadingSnapshots = false);
  }

  Future<void> _testConnection() async {
    setState(() => _isTesting = true);
    _configureWebDav();
    final ok = await _backupService.testConnection();
    setState(() => _isTesting = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? _strings.knode_app_connection_success : _strings.knode_app_connection_failed),
          backgroundColor: ok ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _backupNow() async {
    if (!_isAnyBackupConfigured) {
      _showConfigureDialog();
      return;
    }

    setState(() {
      _isBacking = true;
      _backupProgress = 0;
      _backupProgressMessage = _strings.knode_app_packing_files;
    });

    final s = ref.read(settingsProvider).valueOrNull ?? {};
    final dbPath = s['db_path'] ?? 'knode.db';
    final wikiRoot = s['wiki_root'] ?? 'wiki_root';

    // WebDAV 备份
    if (_isWebDavConfigured) {
      _configureWebDav();
      try {
        await _backupService.backup(
          dbPath: dbPath,
          wikiRoot: wikiRoot,
          onProgress: (percent, message) {
            if (mounted) {
              setState(() {
                _backupProgress = percent * 0.5;
                _backupProgressMessage = 'WebDAV: ';
              });
            }
          },
        );
        if (_keepCount > 0) {
          await _backupService.autoCleanup(keepCount: _keepCount);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(': '), backgroundColor: Colors.red),
          );
        }
      }
    }

    // 本地备份
    if (_isLocalBackupConfigured) {
      try {
        await _localBackupService.backup(
          dbPath: dbPath,
          wikiRoot: wikiRoot,
          backupRoot: _localBackupPath,
          onProgress: (percent, message) {
            if (mounted) {
              setState(() {
                _backupProgress = _isWebDavConfigured ? 0.5 + percent * 0.5 : percent;
                _backupProgressMessage = 'Local: ';
              });
            }
          },
        );
        if (_keepCount > 0) {
          await _localBackupService.autoCleanup(_localBackupPath, keepCount: _keepCount);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(': '), backgroundColor: Colors.red),
          );
        }
      }
    }

    await _loadSnapshots();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_strings.knode_app_backup_complete), backgroundColor: Colors.green),
      );
    }

    setState(() {
      _isBacking = false;
      _backupProgress = -1;
    });
  }

  Future<void> _restore() async {
    // 弹窗选择恢复来源
    final source = await showDialog<String>(
      context: context,
      builder: (_) => _RestoreSourceDialog(
        isWebDavConfigured: _isWebDavConfigured,
        isLocalConfigured: _isLocalBackupConfigured,
        webdavSnapshots: _webdavSnapshots,
        localSnapshots: _localSnapshots,
      ),
    );

    if (source == null) return;

    BackupSnapshot? selectedSnapshot;
    if (source == 'webdav') {
      if (_webdavSnapshots.isEmpty) await _loadSnapshots();
      selectedSnapshot = await showDialog<BackupSnapshot>(
        context: context,
        builder: (_) => _SnapshotPickerDialog(snapshots: _webdavSnapshots, title: _strings.knode_app_webdav_restore),
      );
    } else if (source == 'local') {
      if (_localSnapshots.isEmpty) await _loadSnapshots();
      selectedSnapshot = await showDialog<BackupSnapshot>(
        context: context,
        builder: (_) => _SnapshotPickerDialog(snapshots: _localSnapshots, title: _strings.knode_app_local_restore),
      );
    }

    if (selectedSnapshot == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_strings.knode_app_select_restore_version),
        content: Text(_strings.knode_app_restore_confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_strings.knode_app_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(_strings.knode_app_confirm_restore),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isRestoring = true;
      _backupProgress = 0;
      _backupProgressMessage = _strings.knode_app_downloading;
    });

    final s = ref.read(settingsProvider).valueOrNull ?? {};
    final dbPath = s['db_path'] ?? 'knode.db';
    final wikiRoot = s['wiki_root'] ?? 'wiki_root';

    try {
      if (source == 'webdav') {
        _configureWebDav();
        await _backupService.restore(
          dbPath: dbPath,
          wikiRoot: wikiRoot,
          snapshot: selectedSnapshot,
          onProgress: (percent, message) {
            if (mounted) {
              setState(() {
                _backupProgress = percent;
                _backupProgressMessage = message;
              });
            }
          },
        );
      } else {
        await _localBackupService.restore(
          dbPath: dbPath,
          wikiRoot: wikiRoot,
          backupRoot: _localBackupPath,
          snapshot: selectedSnapshot,
          onProgress: (percent, message) {
            if (mounted) {
              setState(() {
                _backupProgress = percent;
                _backupProgressMessage = message;
              });
            }
          },
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_strings.knode_app_restore_complete), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(': '), backgroundColor: Colors.red),
        );
      }
    }

    setState(() {
      _isRestoring = false;
      _backupProgress = -1;
    });
  }

  Future<void> _deleteSnapshot(BackupSnapshot snapshot, bool isWebDav) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_strings.knode_app_delete),
        content: Text(': ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_strings.knode_app_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(_strings.knode_app_delete),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      if (isWebDav) {
        _configureWebDav();
        await _backupService.deleteBackup(snapshot);
      } else {
        await _localBackupService.deleteBackup(snapshot);
      }
      await _loadSnapshots();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(': '), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showConfigureDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_strings.knode_app_both_not_configured),
        content: Text(_strings.knode_app_both_not_configured),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_strings.knode_app_confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _pickLocalBackupPath() async {
    final selected = await FilePickerUtil.pickDirectory(
      dialogTitle: _strings.knode_app_local_backup_path,
    );
    if (selected == null) return;

    setState(() => _localBackupPath = selected);
    await ref.read(settingsProvider.notifier).set('local_backup_path', selected);
    await _loadSnapshots();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_strings.knode_app_storage_path_updated)),
      );
    }
  }

  void _showFrequencySelector() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(_strings.knode_app_daily),
              leading: Radio<String>(
                value: 'daily',
                groupValue: _backupFrequency,
                onChanged: (v) => _setFrequency(v!),
              ),
            ),
            ListTile(
              title: Text(_strings.knode_app_weekly),
              leading: Radio<String>(
                value: 'weekly',
                groupValue: _backupFrequency,
                onChanged: (v) => _setFrequency(v!),
              ),
            ),
            ListTile(
              title: Text(_strings.knode_app_manual),
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
    ref.read(settingsProvider.notifier).set('backup_frequency', freq);
    Navigator.pop(context);
  }

  String _frequencyLabel(String freq) {
    switch (freq) {
      case 'daily':
        return _strings.knode_app_daily;
      case 'weekly':
        return _strings.knode_app_weekly;
      case 'manual':
        return _strings.knode_app_manual;
      default:
        return freq;
    }
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '-';
    return dt.toString().substring(0, 19);
  }

  @override
  Widget build(BuildContext context) {
    final isOperating = _isBacking || _isRestoring;

    return Scaffold(
      appBar: AppBar(title: Text(_strings.knode_app_backup_settings), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 备份频率
          Card(
            child: ListTile(
              leading: const Icon(Icons.schedule),
              title: Text(_strings.knode_app_backup_frequency_label),
              subtitle: Text(_frequencyLabel(_backupFrequency)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showFrequencySelector,
            ),
          ),
          const SizedBox(height: 16),

          // WebDAV 配置
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.cloud_outlined),
                      const SizedBox(width: 8),
                      Text(_strings.knode_app_webdav, style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      if (_isWebDavConfigured)
                        const Icon(Icons.check_circle, color: Colors.green, size: 20)
                      else
                        const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      labelText: _strings.knode_app_api_base_url,
                      hintText: 'https://your-webdav-server.com/dav',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _userController,
                    decoration: InputDecoration(
                      labelText: _strings.knode_app_user,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: _strings.knode_app_password,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isTesting ? null : _testConnection,
                          icon: _isTesting
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.wifi_find),
                          label: Text(_strings.knode_app_test_connection),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 本地备份配置
          Card(
            child: ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: Text(_strings.knode_app_local_backup_path),
              subtitle: Text(
                _localBackupPath.isEmpty ? _strings.knode_app_local_backup_not_configured : _localBackupPath,
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isLocalBackupConfigured)
                    const Icon(Icons.check_circle, color: Colors.green, size: 20)
                  else
                    const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: _pickLocalBackupPath,
            ),
          ),
          const SizedBox(height: 24),

          // 上次备份时间
          if (_isWebDavConfigured || _isLocalBackupConfigured) ...[
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_strings.knode_app_backup_history, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    if (_isWebDavConfigured)
                      Text(_strings.knode_app_webdav_last_backup(
                        time: _formatDateTime(_webdavSnapshots.isNotEmpty ? _webdavSnapshots.first.createdAt : null),
                      )),
                    if (_isLocalBackupConfigured)
                      Text(_strings.knode_app_local_backup_last_backup(
                        time: _formatDateTime(_localSnapshots.isNotEmpty ? _localSnapshots.first.createdAt : null),
                      )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 立即备份和恢复按钮
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isOperating ? null : _backupNow,
                  icon: _isBacking
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: _backupProgress >= 0 ? _backupProgress : null,
                          ),
                        )
                      : const Icon(Icons.cloud_upload),
                  label: Text(_isBacking ? _backupProgressMessage : _strings.knode_app_backup_now),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isOperating ? null : _restore,
                  icon: _isRestoring
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.cloud_download),
                  label: Text(_strings.knode_app_restore),
                ),
              ),
            ],
          ),

          const Divider(height: 32),

          // WebDAV 备份历史
          if (_isWebDavConfigured) ...[
            Row(
              children: [
                const Icon(Icons.cloud_outlined, size: 20),
                const SizedBox(width: 8),
                Text(_strings.knode_app_webdav, style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _isLoadingSnapshots ? null : _loadSnapshots,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isLoadingSnapshots)
              const Center(child: CircularProgressIndicator())
            else if (_webdavSnapshots.isEmpty)
              Text(_strings.knode_app_no_backups, style: const TextStyle(color: Colors.grey))
            else
              ...List.generate(_webdavSnapshots.length, (i) {
                final s = _webdavSnapshots[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.archive_outlined),
                    title: Text(s.createdAt.toString().substring(0, 19)),
                    subtitle: Text(s.sizeFormatted),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteSnapshot(s, true),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 16),
          ],

          // 本地备份历史
          if (_isLocalBackupConfigured) ...[
            Row(
              children: [
                const Icon(Icons.folder_outlined, size: 20),
                const SizedBox(width: 8),
                Text(_strings.knode_app_local_backup, style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _isLoadingSnapshots ? null : _loadSnapshots,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isLoadingSnapshots)
              const Center(child: CircularProgressIndicator())
            else if (_localSnapshots.isEmpty)
              Text(_strings.knode_app_no_backups, style: const TextStyle(color: Colors.grey))
            else
              ...List.generate(_localSnapshots.length, (i) {
                final s = _localSnapshots[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.archive_outlined),
                    title: Text(s.createdAt.toString().substring(0, 19)),
                    subtitle: Text(s.sizeFormatted),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteSnapshot(s, false),
                    ),
                  ),
                );
              }),
          ],
        ],
      ),
    );
  }
}

class _RestoreSourceDialog extends StatelessWidget {
  final bool isWebDavConfigured;
  final bool isLocalConfigured;
  final List<BackupSnapshot> webdavSnapshots;
  final List<BackupSnapshot> localSnapshots;

  const _RestoreSourceDialog({
    required this.isWebDavConfigured,
    required this.isLocalConfigured,
    required this.webdavSnapshots,
    required this.localSnapshots,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_strings.knode_app_select_restore_source),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isWebDavConfigured)
            ListTile(
              leading: const Icon(Icons.cloud_outlined),
              title: Text(_strings.knode_app_webdav_restore),
              subtitle: Text(
                webdavSnapshots.isNotEmpty
                    ? ': '
                    : _strings.knode_app_no_webdav_backup,
              ),
              onTap: () => Navigator.pop(context, 'webdav'),
            ),
          if (isLocalConfigured)
            ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: Text(_strings.knode_app_local_restore),
              subtitle: Text(
                localSnapshots.isNotEmpty
                    ? ': '
                    : _strings.knode_app_no_local_backup,
              ),
              onTap: () => Navigator.pop(context, 'local'),
            ),
          if (!isWebDavConfigured && !isLocalConfigured)
            Text(_strings.knode_app_both_not_configured),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(_strings.knode_app_cancel),
        ),
      ],
    );
  }
}

class _SnapshotPickerDialog extends StatelessWidget {
  static const _strings = L10nStringsMixin();

  final List<BackupSnapshot> snapshots;
  final String title;

  const _SnapshotPickerDialog({required this.snapshots, required this.title});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: double.maxFinite,
        child: snapshots.isEmpty
            ? Text(_strings.knode_app_no_backups_available)
            : ListView.builder(
                shrinkWrap: true,
                itemCount: snapshots.length,
                itemBuilder: (context, index) {
                  final s = snapshots[index];
                  return ListTile(
                    title: Text(s.createdAt.toString().substring(0, 19)),
                    subtitle: Text(s.sizeFormatted),
                    onTap: () => Navigator.pop(context, s),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(_strings.knode_app_cancel),
        ),
      ],
    );
  }
}
