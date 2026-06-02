import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/extensions/riverpod_compat.dart';
import 'package:core/providers/settings_provider.dart';
import 'package:core/services/backup_service.dart';
import 'package:core/models/backup_snapshot.dart';
import 'package:knode_app/gen/strings.dart';

final _strings = const L10nStringsMixin();

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
  String _backupFrequency = 'daily';
  List<BackupSnapshot> _snapshots = [];
  bool _isLoadingSnapshots = false;
  double _backupProgress = -1;
  String _backupProgressMessage = '';
  int _keepCount = 5;

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
      });
      _loadSnapshots();
    });
  }

  void _configure() {
    _backupService.configure(
      url: _urlController.text,
      user: _userController.text,
      pass: _passController.text,
    );
  }

  Future<void> _loadSnapshots() async {
    if (_urlController.text.isEmpty) return;
    setState(() => _isLoadingSnapshots = true);
    _configure();
    try {
      final snapshots = await _backupService.listBackups();
      if (mounted) setState(() => _snapshots = snapshots);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_strings.knode_app_get_backup_list_failed}: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _isLoadingSnapshots = false);
  }

  Future<void> _testConnection() async {
    setState(() => _isTesting = true);
    _configure();
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

  Future<void> _backup() async {
    setState(() {
      _isBacking = true;
      _backupProgress = 0;
      _backupProgressMessage = _strings.knode_app_packing_files;
    });
    _configure();
    try {
      final s = ref.read(settingsProvider).valueOrNull ?? {};
      final dbPath = s['db_path'] ?? 'knode.db';
      final wikiRoot = s['wiki_root'] ?? 'wiki_root';
      await _backupService.backup(
        dbPath: dbPath,
        wikiRoot: wikiRoot,
        onProgress: (percent, message) {
          if (mounted) {
            setState(() {
              _backupProgress = percent;
              _backupProgressMessage = message;
            });
          }
        },
      );
      if (_keepCount > 0) {
        await _backupService.autoCleanup(keepCount: _keepCount);
      }
      await _loadSnapshots();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_strings.knode_app_backup_complete), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_strings.knode_app_backup_failed}: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() {
      _isBacking = false;
      _backupProgress = -1;
    });
  }

  Future<void> _restore() async {
    if (_snapshots.isEmpty) await _loadSnapshots();

    final selected = await showDialog<BackupSnapshot>(
      context: context,
      builder: (_) => _SnapshotPickerDialog(snapshots: _snapshots),
    );
    if (selected == null) return;

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
            child: Text(_strings.knode_app_restore),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() {
      _isRestoring = true;
      _backupProgress = 0;
    });
    _configure();
    try {
      final s = ref.read(settingsProvider).valueOrNull ?? {};
      final dbPath = s['db_path'] ?? 'knode.db';
      final wikiRoot = s['wiki_root'] ?? 'wiki_root';
      await _backupService.restore(
        dbPath: dbPath,
        wikiRoot: wikiRoot,
        snapshot: selected,
        onProgress: (percent, message) {
          if (mounted) {
            setState(() {
              _backupProgress = percent;
              _backupProgressMessage = message;
            });
          }
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_strings.knode_app_restore_complete), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_strings.knode_app_restore_failed}: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() {
      _isRestoring = false;
      _backupProgress = -1;
    });
  }

  Future<void> _deleteSnapshot(BackupSnapshot snapshot) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_strings.knode_app_delete_backup_confirm),
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

    _configure();
    try {
      await _backupService.deleteBackup(snapshot);
      await _loadSnapshots();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_strings.knode_app_success), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_strings.knode_app_delete_failed}: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _save() async {
    final notifier = ref.read(settingsProvider.notifier);
    await notifier.set('webdav_url', _urlController.text);
    await notifier.set('webdav_user', _userController.text);
    await notifier.set('webdav_pass', _passController.text);
    await notifier.set('webdav_frequency', _backupFrequency);
    await notifier.set('backup_keep_count', _keepCount.toString());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_strings.knode_app_save_success), backgroundColor: Colors.green),
      );
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
    final isOperating = _isBacking || _isRestoring;

    return Scaffold(
      appBar: AppBar(title: Text(_strings.knode_app_webdav + ' ' + _strings.knode_app_backup), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: 'WebDAV URL',
              border: const OutlineInputBorder(),
              hintText: 'https://example.com/dav',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _userController,
            decoration: InputDecoration(
              labelText: _strings.knode_app_user,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: _strings.knode_app_password,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              OutlinedButton(
                onPressed: _isTesting ? null : _testConnection,
                child: _isTesting
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_strings.knode_app_test_connection),
              ),
              const SizedBox(width: 12),
              FilledButton(onPressed: _save, child: Text(_strings.knode_app_save)),
            ],
          ),
          const Divider(height: 32),

          ListTile(
            title: Text(_strings.knode_app_backup_frequency),
            subtitle: Text(_frequencyLabel(_backupFrequency)),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showFrequencySelector,
          ),

          ListTile(
            title: Text(_strings.knode_app_keep_backup_count),
            subtitle: Text(_strings.knode_app_keep_backup_desc(n: _keepCount.toString())),
            trailing: DropdownButton<int>(
              value: _keepCount,
              items: [3, 5, 10, 20, -1].map((n) => DropdownMenuItem(
                value: n,
                child: Text(n == -1 ? _strings.knode_app_no_cleanup : '$n'),
              )).toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() => _keepCount = v);
                }
              },
            ),
          ),

          const Divider(height: 32),

          if (_backupProgress >= 0) ...[
            LinearProgressIndicator(value: _backupProgress),
            const SizedBox(height: 8),
            Text(_backupProgressMessage, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
          ],

          Text(_strings.knode_app_manual_operation, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isOperating ? null : _backup,
                  icon: _isBacking
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.cloud_upload),
                  label: Text(_strings.knode_app_backup_now),
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

          Row(
            children: [
              Text(_strings.knode_app_backup_history, style: Theme.of(context).textTheme.titleSmall),
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
          else if (_snapshots.isEmpty)
            Text(_strings.knode_app_no_backups, style: const TextStyle(color: Colors.grey))
          else
            ...List.generate(_snapshots.length, (i) {
              final s = _snapshots[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.archive_outlined),
                  title: Text(s.createdAt.toString().substring(0, 19)),
                  subtitle: Text(s.sizeFormatted),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deleteSnapshot(s),
                  ),
                ),
              );
            }),
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
}

class _SnapshotPickerDialog extends StatelessWidget {
  static const _strings = L10nStringsMixin();

  final List<BackupSnapshot> snapshots;
  const _SnapshotPickerDialog({required this.snapshots});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_strings.knode_app_select_restore_version),
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
