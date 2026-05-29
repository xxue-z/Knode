import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../providers/settings_provider.dart';

class StorageSettingsPage extends ConsumerStatefulWidget {
  const StorageSettingsPage({super.key});
  @override
  ConsumerState<StorageSettingsPage> createState() => _StorageSettingsPageState();
}

class _StorageSettingsPageState extends ConsumerState<StorageSettingsPage> {
  String _currentPath = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPath();
  }

  Future<void> _loadPath() async {
    final dir = await getApplicationDocumentsDirectory();
    _currentPath = dir.path;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('存储设置'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(child: ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: const Text('当前存储路径'),
            subtitle: Text(_currentPath, style: const TextStyle(fontSize: 12)),
          )),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () async {
              final dir = await getApplicationDocumentsDirectory();
              setState(() => _currentPath = dir.path);
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('路径已刷新')));
            },
            child: const Text('刷新路径'),
          ),
        ],
      ),
    );
  }
}