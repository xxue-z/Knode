import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:core/providers/settings_provider.dart';

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
    final selected = await FilePicker.platform.getDirectoryPath(
      dialogTitle: '选择知识库存储目录',
    );
    if (selected == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('修改存储路径'),
        content: Text('将存储路径修改为:\n$selected\n\n是否迁移已有文件？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('仅修改路径'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('修改并迁移'),
          ),
        ],
      ),
    );

    if (confirmed == null) return;

    // 保存新路径
    await ref.read(settingsProvider.notifier).set('wiki_storage_path', selected);
    setState(() => _currentPath = selected);

    // 如果用户选择迁移
    if (confirmed) {
      await _migrateFiles(selected);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('存储路径已更新')),
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
          SnackBar(content: Text('已迁移 $count 个文件')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('迁移失败: $e'), backgroundColor: Colors.red),
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
      appBar: AppBar(title: const Text('存储设置'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 当前路径
          Card(
            child: ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: const Text('当前存储路径'),
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
            label: const Text('修改存储路径'),
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
            label: Text(_isMigrating ? '迁移中...' : '迁移文件到当前路径'),
          ),
          const SizedBox(height: 24),

          // 说明
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('说明', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('• 修改路径后，新文档将保存到新位置'),
                  Text('• 迁移功能会复制已有 .md 文件到新目录'),
                  Text('• 原文件不会被删除，可手动清理'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
