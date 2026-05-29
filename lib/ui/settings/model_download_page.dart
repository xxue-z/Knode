import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/model_download_service.dart';
import '../../core/utils/device_utils.dart';
import '../../providers/settings_provider.dart';

class ModelDownloadPage extends ConsumerStatefulWidget {
  const ModelDownloadPage({super.key});
  @override
  ConsumerState<ModelDownloadPage> createState() => _ModelDownloadPageState();
}

class _ModelDownloadPageState extends ConsumerState<ModelDownloadPage> {
  final _service = ModelDownloadService('');
  List<String> _downloaded = [];
  int _availableMemory = 0;
  bool _isLoading = true;
  DownloadProgress? _progress;
  String? _downloadingName;
  String? _activeModel;
  StreamSubscription? _progressSub;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _availableMemory = await DeviceUtils.getAvailableMemory();
    _downloaded = await _service.getDownloadedModels();
    final settings = ref.read(settingsProvider).valueOrNull ?? {};
    _activeModel = settings['local_model_name'];
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _progressSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final supported = ModelDownloadService.availableModels.where((m) => m.sizeMB <= _availableMemory * 0.6).toList();
    final unsupported = ModelDownloadService.availableModels.where((m) => m.sizeMB > _availableMemory * 0.6).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('模型管理'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('可用内存: ${_availableMemory} MB'),
          )),
          const SizedBox(height: 16),
          const Text('推荐模型', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...supported.map((m) => _ModelTile(
            model: m,
            isDownloaded: _downloaded.contains(m.name),
            isDownloading: _downloadingName == m.name,
            isActive: _activeModel == m.name,
            progress: _progress,
            onDownload: () => _download(m),
            onDelete: () => _delete(m),
            onUse: () => _useModel(m),
          )),
          if (unsupported.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('不支持的模型（内存不足）', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            ...unsupported.map((m) => _ModelTile(model: m, isDownloaded: _downloaded.contains(m.name), unsupported: true)),
          ],
        ],
      ),
    );
  }

  Future<void> _download(ModelInfo model) async {
    _progressSub?.cancel();
    setState(() { _downloadingName = model.name; _progress = null; });
    _progressSub = _service.downloadProgress.listen((p) {
      if (mounted) setState(() => _progress = p);
    });
    try {
      await _service.downloadModel(model.url, model.name);
      _downloaded = await _service.getDownloadedModels();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('下载失败: $e')));
    }
    _progressSub?.cancel();
    setState(() { _downloadingName = null; _progress = null; });
  }

  Future<void> _delete(ModelInfo model) async {
    await _service.deleteModel(model.name);
    _downloaded = await _service.getDownloadedModels();
    if (_activeModel == model.name) {
      await ref.read(settingsProvider.notifier).set('local_model_name', '');
      _activeModel = null;
    }
    setState(() {});
  }

  Future<void> _useModel(ModelInfo model) async {
    await ref.read(settingsProvider.notifier).set('local_model_name', model.name);
    setState(() => _activeModel = model.name);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已切换到 ${model.name}')),
      );
    }
  }
}

class _ModelTile extends StatelessWidget {
  final ModelInfo model;
  final bool isDownloaded;
  final bool isDownloading;
  final bool isActive;
  final bool unsupported;
  final DownloadProgress? progress;
  final VoidCallback? onDownload;
  final VoidCallback? onDelete;
  final VoidCallback? onUse;
  const _ModelTile({
    required this.model,
    this.isDownloaded = false,
    this.isDownloading = false,
    this.isActive = false,
    this.unsupported = false,
    this.progress,
    this.onDownload,
    this.onDelete,
    this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isActive ? colorScheme.primaryContainer.withValues(alpha: 0.3) : null,
      child: ListTile(
        title: Row(
          children: [
            Expanded(child: Text(model.name)),
            if (isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('使用中', style: TextStyle(fontSize: 10, color: colorScheme.onPrimary)),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(model.description),
            Text('${model.sizeMB} MB', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        trailing: unsupported
            ? const Icon(Icons.block, color: Colors.grey)
            : isDownloaded
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isActive)
                        TextButton(onPressed: onUse, child: const Text('使用')),
                      IconButton(icon: const Icon(Icons.delete_outline), onPressed: onDelete),
                    ],
                  )
                : isDownloading
                    ? SizedBox(width: 40, height: 40, child: CircularProgressIndicator(value: progress?.percent))
                    : FilledButton.tonal(onPressed: onDownload, child: const Text('下载')),
      ),
    );
  }
}