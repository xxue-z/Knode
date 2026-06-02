import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/extensions/riverpod_compat.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:core/providers/settings_provider.dart';
import 'package:knode_app/gen/strings.dart';

final _strings = const L10nStringsMixin();

/// 存储路径配置页面。
///
/// 显示当前存储路径，支持修改路径和迁移已有文件。
class StorageSettingsPage extends ConsumerStatefulWidget {
  const StorageSettingsPage({super.key});

  @override
  ConsumerState<StorageSettingsPage> createState() => _StorageSettingsPageState();
}

class _StorageSettingsPageState extends ConsumerState<StorageSettingsPage> {
  String _currentPath = '';
  bool _isLoading = true;
  bool _isMigrating = false;

  @override
  void initState() {
    super.initState();
    _loadPath();
  }

  Future<void> _loadPath() async {
    final settings = ref.read(settingsProvider).valueOrNull ?? {};
    final savedPath = settings['wiki_storage_path'];
    if (savedPath != null && savedPath.isNotEmpty) {
      _currentPath = savedPath;
    } else {
      final dir = await getApplicationDocumentsDirectory();
      _currentPath = '${dir.path}/knode_wiki';
    }
    setState(() => _isLoading = false);
  }

  /// 选择新的存储路径。
  Future<void> _pickNewPath() async {
    final selected = await FilePicker.getDirectoryPath(
      dialogTitle: _strings.knode_app_modify_storage_path,
    );
    if (selected == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_strings.knode_app_modify_storage_path),
        content: Text(_strings.knode_app_migrate_files_confirm(path: selected)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_strings.knode_app_path_only),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(_strings.knode_app_migrate_and_change),
          ),
        ],
      ),
    );

    if (confirmed == null) return;

    await ref.read(settingsProvider.notifier).set('wiki_storage_path', selected);
    setState(() => _currentPath = selected);

    if (confirmed) {
      await _migrateFiles(selected);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_strings.knode_app_storage_path_updated)),
      );
    }
  }

  /// 迁移已有文件到新路径。
  Future<void> _migrateFiles(String newPath) async {
    setState(() => _isMigrating = true);

    try {
      final oldDir = Directory(_currentPath);
      final newDir = Directory(newPath);

      if (!await oldDir.exists()) {
        setState(() => _isMigrating = false);
        return;
      }

      if (!await newDir.exists()) {
        await newDir.create(recursive: true);
      }

      // 复制所有 .md 文件
      int count = 0;
      await for (final entity in oldDir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.md')) {
          final relativePath = entity.path.substring(oldDir.path.length);
          final targetFile = File('${newDir.path}$relativePath');
          await targetFile.parent.create(recursive: true);
          await entity.copy(targetFile.path);
          count++;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_strings.knode_app_migrated_n_files(n: count.toString()))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_strings.knode_app_migration_failed}: $e'), backgroundColor: Colors.red),
        );
      }
    }

    setState(() => _isMigrating = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(_strings.knode_app_storage_settings), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 当前路径
          Card(
            child: ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: Text(_strings.knode_app_current_storage_path),
              subtitle: Text(
                _currentPath,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 修改路径
          FilledButton.icon(
            onPressed: _pickNewPath,
            icon: const Icon(Icons.folder_open),
            label: Text(_strings.knode_app_modify_storage_path),
          ),
          const SizedBox(height: 12),

          // 迁移文件
          OutlinedButton.icon(
            onPressed: _isMigrating ? null : () => _migrateFiles(_currentPath),
            icon: _isMigrating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.drive_file_move),
            label: Text(_isMigrating ? 'Migrating...' : 'Migrate files to current path'),
          ),
          const SizedBox(height: 24),

          // 说明
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_strings.knode_app_description, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('• ${_strings.knode_app_storage_migration_hint_1}'),
                  Text('• ${_strings.knode_app_storage_migration_hint_2}'),
                  Text('• ${_strings.knode_app_storage_migration_hint_3}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
