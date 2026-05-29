import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';

/// AI 模型配置页面。
///
/// 支持切换云端/本地模式，云端模式下可选择 OpenAI 或 Anthropic API 规范。
class AiSettingsPage extends ConsumerStatefulWidget {
  const AiSettingsPage({super.key});

  @override
  ConsumerState<AiSettingsPage> createState() => _AiSettingsPageState();
}

class _AiSettingsPageState extends ConsumerState<AiSettingsPage> {
  bool _isCloudMode = true;
  String _apiSpec = 'openai'; // openai / anthropic
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _modelController = TextEditingController();

  // 预设配置
  static const _presets = {
    'openai': {
      'baseUrl': 'https://api.openai.com',
      'model': 'gpt-4o-mini',
      'hint': '支持 OpenAI、DeepSeek、通义千问等兼容接口',
    },
    'anthropic': {
      'baseUrl': 'https://api.anthropic.com',
      'model': 'claude-sonnet-4-20250514',
      'hint': 'Anthropic Claude 系列模型',
    },
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(settingsProvider).valueOrNull ?? {};
      setState(() {
        _isCloudMode = (settings['ai_provider_type'] ?? 'cloud') == 'cloud';
        _apiSpec = settings['ai_api_spec'] ?? 'openai';
        _apiKeyController.text = settings['ai_api_key'] ?? '';
        _baseUrlController.text = settings['ai_base_url'] ?? _presets[_apiSpec]!['baseUrl']!;
        _modelController.text = settings['ai_model'] ?? _presets[_apiSpec]!['model']!;
      });
    });
  }

  void _onSpecChanged(String? spec) {
    if (spec == null) return;
    setState(() {
      _apiSpec = spec;
      // 如果当前 URL 是另一个规范的默认值，自动切换
      final otherSpec = spec == 'openai' ? 'anthropic' : 'openai';
      if (_baseUrlController.text == _presets[otherSpec]!['baseUrl']) {
        _baseUrlController.text = _presets[spec]!['baseUrl']!;
      }
      if (_modelController.text == _presets[otherSpec]!['model']) {
        _modelController.text = _presets[spec]!['model']!;
      }
    });
  }

  Future<void> _save() async {
    final notifier = ref.read(settingsProvider.notifier);
    await notifier.set('ai_provider_type', _isCloudMode ? 'cloud' : 'local');
    await notifier.set('ai_api_spec', _apiSpec);
    await notifier.set('ai_api_key', _apiKeyController.text);
    await notifier.set('ai_base_url', _baseUrlController.text);
    await notifier.set('ai_model', _modelController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已保存')));
    }
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
    final preset = _presets[_apiSpec]!;

    return Scaffold(
      appBar: AppBar(title: const Text('AI 模型配置'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 云端/本地切换
          SwitchListTile(
            title: const Text('云端模式'),
            subtitle: Text(_isCloudMode ? '使用云端 API' : '使用本地模型'),
            value: _isCloudMode,
            onChanged: (v) => setState(() => _isCloudMode = v),
          ),
          const SizedBox(height: 16),

          if (_isCloudMode) ...[
            // API 规范选择
            DropdownButtonFormField<String>(
              value: _apiSpec,
              decoration: const InputDecoration(
                labelText: 'API 规范',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'openai', child: Text('OpenAI 兼容')),
                DropdownMenuItem(value: 'anthropic', child: Text('Anthropic Claude')),
              ],
              onChanged: _onSpecChanged,
            ),
            const SizedBox(height: 8),
            Text(
              preset['hint']!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),

            // API Key
            TextField(
              controller: _apiKeyController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'API Key',
                border: const OutlineInputBorder(),
                hintText: _apiSpec == 'anthropic' ? 'sk-ant-api03-...' : 'sk-...',
              ),
            ),
            const SizedBox(height: 12),

            // Base URL
            TextField(
              controller: _baseUrlController,
              decoration: InputDecoration(
                labelText: 'Base URL',
                border: const OutlineInputBorder(),
                hintText: preset['baseUrl'],
              ),
            ),
            const SizedBox(height: 12),

            // Model
            TextField(
              controller: _modelController,
              decoration: InputDecoration(
                labelText: 'Model',
                border: const OutlineInputBorder(),
                hintText: preset['model'],
              ),
            ),
            const SizedBox(height: 8),

            // 预设快捷按钮
            Wrap(
              spacing: 8,
              children: [
                if (_apiSpec == 'openai') ...[
                  ActionChip(
                    label: const Text('DeepSeek'),
                    onPressed: () {
                      _baseUrlController.text = 'https://api.deepseek.com';
                      _modelController.text = 'deepseek-chat';
                    },
                  ),
                  ActionChip(
                    label: const Text('通义千问'),
                    onPressed: () {
                      _baseUrlController.text = 'https://dashscope.aliyuncs.com/compatible-mode';
                      _modelController.text = 'qwen-turbo';
                    },
                  ),
                ],
                if (_apiSpec == 'anthropic') ...[
                  ActionChip(
                    label: const Text('Claude Sonnet'),
                    onPressed: () => _modelController.text = 'claude-sonnet-4-20250514',
                  ),
                  ActionChip(
                    label: const Text('Claude Haiku'),
                    onPressed: () => _modelController.text = 'claude-haiku-4-5-20251001',
                  ),
                ],
              ],
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
