import 'package:flutter/material.dart';
import '../../services/model_download_service.dart';
import '../../core/utils/device_utils.dart';

class ModelDownloadPage extends StatefulWidget {
  const ModelDownloadPage({super.key});
  @override
  State<ModelDownloadPage> createState() => _ModelDownloadPageState();
}

class _ModelDownloadPageState extends State<ModelDownloadPage> {
  final _service = ModelDownloadService('');
  List<String> _downloaded = [];
  int _availableMemory = 0;
  bool _isLoading = true;
  DownloadProgress? _progress;
  String? _downloadingName;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _availableMemory = await DeviceUtils.getAvailableMemory();
    _downloaded = await _service.getDownloadedModels();
    setState(() => _isLoading = false);
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
          ...supported.map((m) => _ModelTile(model: m, isDownloaded: _downloaded.contains(m.name), isDownloading: _downloadingName == m.name, progress: _progress, onDownload: () => _download(m), onDelete: () => _delete(m))),
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
    setState(() { _downloadingName = model.name; _progress = null; });
    _service.downloadProgress.listen((p) => setState(() => _progress = p));
    try {
      await _service.downloadModel(model.url, model.name);
      _downloaded = await _service.getDownloadedModels();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('下载失败: $e')));
    }
    setState(() { _downloadingName = null; _progress = null; });
  }

  Future<void> _delete(ModelInfo model) async {
    await _service.deleteModel(model.name);
    _downloaded = await _service.getDownloadedModels();
    setState(() {});
  }
}

class _ModelTile extends StatelessWidget {
  final ModelInfo model;
  final bool isDownloaded;
  final bool isDownloading;
  final bool unsupported;
  final DownloadProgress? progress;
  final VoidCallback? onDownload;
  final VoidCallback? onDelete;
  const _ModelTile({required this.model, this.isDownloaded = false, this.isDownloading = false, this.unsupported = false, this.progress, this.onDownload, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(model.name),
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
                ? IconButton(icon: const Icon(Icons.delete_outline), onPressed: onDelete)
                : isDownloading
                    ? SizedBox(width: 40, height: 40, child: CircularProgressIndicator(value: progress?.percent))
                    : FilledButton.tonal(onPressed: onDownload, child: const Text('下载')),
      ),
    );
  }
}