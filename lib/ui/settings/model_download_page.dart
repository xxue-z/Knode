import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/model_provider.dart';
import '../../providers/settings_provider.dart';
import 'package:core/utils/device_utils.dart';
import 'model_card_widget.dart';

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
    final settings = ref.read(settingsProvider).valueOrNull ?? {};
    if (settings['model_repo_url']?.isNotEmpty == true) {
      _repoUrlController.text = settings['model_repo_url']!;
    }
    setState(() => _isLoading = false);
  }

  Future<void> _fetchModels() async {
    final url = _repoUrlController.text.trim();
    if (url.isEmpty) return;
    await ref.read(settingsProvider.notifier).set('model_repo_url', url);
    await ref.read(modelListProvider.notifier).fetchFromRepo(url);
  }

  Future<void> _importLocalModel() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['gguf'],
    );
    if (result == null || result.files.isEmpty) return;
    final filePath = result.files.first.path;
    if (filePath == null) return;

    try {
      await ref.read(modelListProvider.notifier).importLocalModel(filePath);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('导入成功'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: $e'), backgroundColor: Colors.red),
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
      appBar: AppBar(title: const Text('模型管理'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 设备内存信息
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.memory, size: 20),
                  const SizedBox(width: 8),
                  Text('可用内存: ${_availableMemory} MB'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 仓库地址 + 获取
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _repoUrlController,
                  decoration: const InputDecoration(
                    labelText: '模型仓库地址',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _fetchModels,
                child: const Text('获取'),
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
              label: const Text('导入本地模型'),
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
                children: models.map((model) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ModelCardWidget(
                    model: model,
                    onDownload: (mirrorKey) {
                      ref.read(modelListProvider.notifier).startDownload(model, mirrorKey);
                    },
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
                )).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('加载失败: $e')),
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
              '暂无模型',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '请获取仓库或导入本地文件',
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
