import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/extensions/riverpod_compat.dart';
import 'package:file_picker/file_picker.dart';
import 'package:core/providers/model_provider.dart';
import 'package:core/providers/settings_provider.dart';
import 'package:core/services/model_download_service.dart';
import 'package:core/utils/device_utils.dart';
import 'package:core/gen/strings.dart' as core_strings;
import 'package:knode_app/gen/strings.dart';
import 'package:knode_app/screens/model_card_widget.dart';

final _strings = const L10nStringsMixin();
const _coreStrings = core_strings.L10nStringsMixin();

/// 模型下载管理页面。
///
/// 使用 ModelCardWidget 替换原有 _ModelTile，增加仓库地址和导入功能。
class ModelDownloadPage extends ConsumerStatefulWidget {
  const ModelDownloadPage({super.key});

  @override
  ConsumerState<ModelDownloadPage> createState() => _ModelDownloadPageState();
}

class _ModelDownloadPageState extends ConsumerState<ModelDownloadPage> {
  final _repoUrlController = TextEditingController();
  int _availableMemory = 0;
  double _totalMemoryGB = 0;
  bool _skipMemoryCheck = false;
  bool _isLoading = true;

  static const _defaultRepoUrl =
      'https://cdn.jsdelivr.net/gh/xxue-z/Knode@master/.resource/models.json';

  @override
  void initState() {
    super.initState();
    _repoUrlController.text = _defaultRepoUrl;
    _load();
  }

  Future<void> _load() async {
    _availableMemory = await DeviceUtils.getAvailableMemory();
    _totalMemoryGB = await DeviceUtils.getTotalMemoryInGB();
    final settings = ref.read(settingsProvider).valueOrNull ?? {};
    if (settings['model_repo_url']?.isNotEmpty == true) {
      _repoUrlController.text = settings['model_repo_url']!;
    }
    _skipMemoryCheck = settings['skip_memory_check'] == 'true';
    setState(() => _isLoading = false);
  }

  Future<void> _fetchModels() async {
    final url = _repoUrlController.text.trim();
    if (url.isEmpty) return;
    await ref.read(settingsProvider.notifier).set('model_repo_url', url);
    await ref.read(modelListProvider.notifier).fetchFromRepo(url);
  }

  Future<void> _importLocalModel() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['gguf'],
    );
    if (result == null || result.files.isEmpty) return;
    final filePath = result.files.first.path;
    if (filePath == null) return;

    // 内存兼容性检查
    final settings = ref.read(settingsProvider).valueOrNull ?? {};
    final skipCheck = settings['skip_memory_check'] == 'true';

    if (!skipCheck) {
      final file = File(filePath);
      final fileSizeMB = await file.length() / (1024 * 1024);
      final totalMemoryGB = await DeviceUtils.getTotalMemoryInGB();
      final isCompatible = fileSizeMB <= totalMemoryGB * 1024 * 0.6;

      if (!isCompatible && mounted) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(_coreStrings.core_memory_insufficient),
            content: Text(
              _coreStrings.core_model_may_not_run(
                size: '${fileSizeMB.toStringAsFixed(0)} MB',
                mem: '${totalMemoryGB.toStringAsFixed(1)} GB',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(_strings.knode_app_cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(_coreStrings.core_continue_import),
              ),
            ],
          ),
        );
        if (proceed != true) return;
      }
    }

    try {
      await ref.read(modelListProvider.notifier).importLocalModel(filePath);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_strings.knode_app_import_success), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_strings.knode_app_import_failed}: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _repoUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final modelsAsync = ref.watch(modelListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_strings.knode_app_model_download), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 设备内存信息
          if (_totalMemoryGB > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${_coreStrings.core_total_memory}: ${_totalMemoryGB.toStringAsFixed(1)} GB  |  ${_coreStrings.core_available_memory}: $_availableMemory MB',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),

          // 跳过内存检查开关
          SwitchListTile(
            title: Text(_strings.knode_app_skip_memory_check),
            subtitle: Text(_strings.knode_app_skip_memory_check_desc),
            value: _skipMemoryCheck,
            dense: true,
            contentPadding: EdgeInsets.zero,
            onChanged: (value) async {
              setState(() => _skipMemoryCheck = value);
              await ref.read(settingsProvider.notifier).set(
                'skip_memory_check', value.toString(),
              );
            },
          ),
          const SizedBox(height: 8),

          // 仓库地址 + 获取
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _repoUrlController,
                  decoration: InputDecoration(
                    labelText: _strings.knode_app_model_repo_url,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _fetchModels,
                child: Text(_strings.knode_app_fetch),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 导入本地模型
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _importLocalModel,
              icon: const Icon(Icons.file_upload_outlined),
              label: Text(_strings.knode_app_import_local_model),
            ),
          ),
          const SizedBox(height: 16),

          // 模型列表
          modelsAsync.when(
            data: (models) {
              if (models.isEmpty) {
                return _buildEmptyState();
              }
              return Column(
                children: models.map((model) {
                  final isCompatible = _skipMemoryCheck || ModelDownloadService.filterModelsByRam(
                    models: [model],
                    totalMemoryGB: _totalMemoryGB,
                  ).isNotEmpty;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ModelCardWidget(
                      model: model,
                      isIncompatible: !isCompatible,
                      onDownload: isCompatible
                          ? (mirrorKey) {
                              ref.read(modelListProvider.notifier).startDownload(model, mirrorKey);
                            }
                          : null,
                      onCancel: () {
                        ref.read(modelListProvider.notifier).cancelDownload();
                      },
                      onLoad: () {
                        ref.read(modelListProvider.notifier).loadModel(model);
                      },
                      onDelete: () {
                        ref.read(modelListProvider.notifier).deleteModel(model);
                      },
                      onRetry: () {
                        final key = model.downloadUrls.keys.firstOrNull;
                        if (key != null) {
                          ref.read(modelListProvider.notifier).startDownload(model, key);
                        }
                      },
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('${_strings.knode_app_load_failed}: $e')),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(
              Icons.download_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              _strings.knode_app_no_models,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _strings.knode_app_fetch_or_import_hint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
