import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';

class AiSettingsPage extends ConsumerStatefulWidget {
  const AiSettingsPage({super.key});
  @override
  ConsumerState<AiSettingsPage> createState() => _AiSettingsPageState();
}

class _AiSettingsPageState extends ConsumerState<AiSettingsPage> {
  bool _isCloudMode = true;
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _modelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(settingsProvider).valueOrNull ?? {};
      setState(() {
        _isCloudMode = (settings['ai_provider_type'] ?? 'cloud') == 'cloud';
        _apiKeyController.text = settings['ai_api_key'] ?? '';
        _baseUrlController.text = settings['ai_base_url'] ?? 'https://api.openai.com';
        _modelController.text = settings['ai_model'] ?? 'gpt-4o-mini';
      });
    });
  }

  Future<void> _save() async {
    final notifier = ref.read(settingsProvider.notifier);
    await notifier.set('ai_provider_type', _isCloudMode ? 'cloud' : 'local');
    await notifier.set('ai_api_key', _apiKeyController.text);
    await notifier.set('ai_base_url', _baseUrlController.text);
    await notifier.set('ai_model', _modelController.text);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已保存')));
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 模型配置'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('云端模式'),
            subtitle: Text(_isCloudMode ? '使用云端 API' : '使用本地模型'),
            value: _isCloudMode,
            onChanged: (v) => setState(() => _isCloudMode = v),
          ),
          const SizedBox(height: 16),
          if (_isCloudMode) ...[
            TextField(
              controller: _apiKeyController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'API Key', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _baseUrlController,
              decoration: const InputDecoration(labelText: 'Base URL', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _modelController,
              decoration: const InputDecoration(labelText: 'Model', border: OutlineInputBorder()),
            ),
          ] else ...[
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('本地模型配置功能即将上线'),
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: const Text('保存配置')),
        ],
      ),
    );
  }
}