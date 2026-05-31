import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:core/models/cloud_vendor.dart';
import 'package:core/models/local_model.dart';
import 'package:core/providers/model_provider.dart';
import 'package:core/providers/settings_provider.dart';
import 'package:core/services/cloud_vendor_service.dart';
import 'package:core/utils/device_utils.dart';
import 'package:knode_app/screens/model_card_widget.dart';
import 'package:knode_app/screens/cloud_config_form.dart';
import 'package:knode_app/gen/strings.dart';

final _strings = const L10nStringsMixin();

/// AI 引擎主设置页面。
///
/// SegmentedButton 切换「本地模型」和「云端 API」两个 Tab。
class AiSettingsPage extends ConsumerStatefulWidget {
  const AiSettingsPage({super.key});

  @override
  ConsumerState<AiSettingsPage> createState() => _AiSettingsPageState();
}

class _AiSettingsPageState extends ConsumerState<AiSettingsPage> {
  bool _isCloudMode = true;
  final _repoUrlController = TextEditingController();
  final _cloudRepoUrlController = TextEditingController();
  List<CloudVendor> _cloudVendors = [];
  bool _isLoadingVendors = false;
  int _availableMemory = 0;
  String _searchProvider = 'Tavily';
  String _searchApiKey = '';
  String _testResult = '';

  // 默认仓库地址
  static const _defaultModelRepoUrl =
      'https://cdn.jsdelivr.net/gh/xxue-z/Knode@master/.resource/models.json';
  static const _defaultCloudRepoUrl =
      'https://cdn.jsdelivr.net/gh/xxue-z/Knode@master/.resource/cloud_models.json';

  @override
  void initState() {
    super.initState();
    _repoUrlController.text = _defaultModelRepoUrl;
    _cloudRepoUrlController.text = _defaultCloudRepoUrl;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
      _loadMemory();
    });
  }

  void _loadSettings() {
    final settings = ref.read(settingsProvider).valueOrNull ?? {};
    setState(() {
      _isCloudMode = (settings['ai_type'] ?? 'cloud') == 'cloud';
      if (settings['model_repo_url']?.isNotEmpty == true) {
        _repoUrlController.text = settings['model_repo_url']!;
      }
      if (settings['cloud_vendor_repo_url']?.isNotEmpty == true) {
        _cloudRepoUrlController.text = settings['cloud_vendor_repo_url']!;
      }
    });
    // 加载云端厂商缓存
    _loadCachedVendors();
  }

  Future<void> _loadMemory() async {
    final mem = await DeviceUtils.getAvailableMemory();
    if (mounted) setState(() => _availableMemory = mem);
  }

  Future<void> _loadCachedVendors() async {
    final service = CloudVendorService();
    final vendors = await service.getCachedVendors();
    if (mounted) setState(() => _cloudVendors = vendors);
  }

  Future<void> _fetchModels() async {
    final url = _repoUrlController.text.trim();
    if (url.isEmpty) return;

    await ref.read(settingsProvider.notifier).set('model_repo_url', url);
    await ref.read(modelListProvider.notifier).fetchFromRepo(url);

    if (mounted) {
      final state = ref.read(modelListProvider);
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_strings.knode_app_fetch_failed_use_cache}: ${state.error}')),
        );
      }
    }
  }

  Future<void> _fetchCloudVendors() async {
    final url = _cloudRepoUrlController.text.trim();
    if (url.isEmpty) return;

    setState(() => _isLoadingVendors = true);
    try {
      await ref.read(settingsProvider.notifier).set('cloud_vendor_repo_url', url);
      final service = CloudVendorService();
      final vendors = await service.fetchVendors(url);
      if (mounted) setState(() => _cloudVendors = vendors);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_strings.knode_app_fetch_failed_use_cache}: $e')),
        );
      }
    }
    setState(() => _isLoadingVendors = false);
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

  Future<void> _onTypeChanged(bool isCloud) async {
    setState(() => _isCloudMode = isCloud);
    await ref.read(settingsProvider.notifier).set('ai_type', isCloud ? 'cloud' : 'local');
  }

  @override
  void dispose() {
    _repoUrlController.dispose();
    _cloudRepoUrlController.dispose();
    super.dispose();
  }

  void _showSearchProviderPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_strings.knode_app_select_search_provider),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Tavily'),
              value: 'Tavily',
              groupValue: _searchProvider,
              onChanged: (v) {
                setState(() => _searchProvider = v!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('SerpAPI'),
              value: 'SerpAPI',
              groupValue: _searchProvider,
              onChanged: (v) {
                setState(() => _searchProvider = v!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showApiKeyDialog(BuildContext context) {
    final controller = TextEditingController(text: _searchApiKey);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_strings.knode_app_search_api_key),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: _strings.knode_app_input_api_key,
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_strings.knode_app_cancel),
          ),
          FilledButton(
            onPressed: () {
              setState(() => _searchApiKey = controller.text);
              Navigator.pop(context);
            },
            child: Text(_strings.knode_app_save),
          ),
        ],
      ),
    );
  }

  void _testSearchConnection() async {
    setState(() => _testResult = _strings.knode_app_testing);
    // TODO: 实际测试连接
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _testResult = _searchApiKey.isNotEmpty ? _strings.knode_app_connection_success : _strings.knode_app_config_api_key_first);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_strings.knode_app_ai_engine), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // SegmentedButton 切换
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: false, label: Text(_strings.knode_app_local_model), icon: const Icon(Icons.phone_android)),
              ButtonSegment(value: true, label: Text(_strings.knode_app_cloud_api), icon: const Icon(Icons.cloud_outlined)),
            ],
            selected: {_isCloudMode},
            onSelectionChanged: (s) => _onTypeChanged(s.first),
          ),
          const SizedBox(height: 20),

          if (_isCloudMode) _buildCloudTab() else _buildLocalTab(),
        ],
      ),
    );
  }

  Widget _buildLocalTab() {
    final modelsAsync = ref.watch(modelListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 仓库地址输入框 + 获取按钮
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _repoUrlController,
                decoration: InputDecoration(
                  labelText: _strings.knode_app_model_repo_url,
                  border: OutlineInputBorder(),
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

        // 导入本地模型按钮
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _importLocalModel,
            icon: const Icon(Icons.file_upload_outlined),
            label: Text(_strings.knode_app_import_local_model),
          ),
        ),
        const SizedBox(height: 16),

        // 设备内存信息
        if (_availableMemory > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              _strings.knode_app_available_memory(memory: '$_availableMemory'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),

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
                    // 重试：重新下载第一个可用镜像
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
          error: (e, _) => Center(child: Text('${_strings.knode_app_load_failed}: $e')),
        ),
      ],
    );
  }

  Widget _buildCloudTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 云端仓库地址输入框 + 获取按钮
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _cloudRepoUrlController,
                decoration: InputDecoration(
                  labelText: _strings.knode_app_cloud_model_repo_url,
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _isLoadingVendors ? null : _fetchCloudVendors,
              child: _isLoadingVendors
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_strings.knode_app_fetch),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 云端配置表单
        CloudConfigForm(vendors: _cloudVendors),
      ],
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
