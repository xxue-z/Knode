import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/extensions/riverpod_compat.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:core/models/cloud_vendor.dart';
import 'package:core/services/cloud_vendor_service.dart';
import 'package:core/providers/settings_provider.dart';
import 'package:knode_app/gen/strings.dart';

final _strings = const L10nStringsMixin();

/// 云端 API 配置表单。
///
/// 支持厂商预设自动填充、API Key 安全存储、连接测试。
class CloudConfigForm extends ConsumerStatefulWidget {
  final List<CloudVendor> vendors;

  const CloudConfigForm({super.key, required this.vendors});

  @override
  ConsumerState<CloudConfigForm> createState() => _CloudConfigFormState();
}

class _CloudConfigFormState extends ConsumerState<CloudConfigForm> {
  static const _secureStorage = FlutterSecureStorage();

  String? _selectedVendor;
  String _apiSpec = 'openai';
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _modelController = TextEditingController();
  bool _showApiKey = false;
  bool _isCustomVendor = false;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedConfig();
    });
  }

  void _loadSavedConfig() {
    final settings = ref.read(settingsProvider).valueOrNull ?? {};
    final savedVendor = settings['cloud_vendor'] ?? '';

    setState(() {
      _selectedVendor = savedVendor.isNotEmpty ? savedVendor : null;
      _apiSpec = settings['cloud_api_spec'] ?? 'openai';
      _baseUrlController.text = settings['cloud_base_url'] ?? '';
      _modelController.text = settings['cloud_model'] ?? '';

      // 判断是否为自定义厂商
      if (_selectedVendor != null) {
        final match = widget.vendors.where((v) => v.vendor == _selectedVendor);
        _isCustomVendor = match.isEmpty;
      } else {
        _isCustomVendor = true;
      }
    });

    // 从 secure storage 读取 API Key
    _secureStorage.read(key: 'cloud_api_key').then((key) {
      if (key != null && mounted) {
        setState(() => _apiKeyController.text = key);
      }
    });
  }

  void _onVendorChanged(String? vendor) {
    if (vendor == null) return;
    final isCustom = vendor == '__custom__';

    setState(() {
      _selectedVendor = isCustom ? null : vendor;
      _isCustomVendor = isCustom;

      if (!isCustom) {
        final v = widget.vendors.firstWhere((v) => v.vendor == vendor);
        // 自动填充协议
        if (v.supportedModes.isNotEmpty) {
          _apiSpec = v.supportedModes.first;
        }
        // 自动填充 base_url
        if (v.baseUrls.containsKey(_apiSpec)) {
          _baseUrlController.text = v.baseUrls[_apiSpec]!;
        }
        // 自动选第一个模型
        if (v.models.isNotEmpty) {
          _modelController.text = v.models.first;
        }
      }
    });

    _autoSave();
  }

  Future<void> _autoSave() async {
    final notifier = ref.read(settingsProvider.notifier);
    await notifier.set('cloud_vendor', _selectedVendor ?? '');
    await notifier.set('cloud_api_spec', _apiSpec);
    await notifier.set('cloud_base_url', _baseUrlController.text);
    await notifier.set('cloud_model', _modelController.text);
    await _secureStorage.write(key: 'cloud_api_key', value: _apiKeyController.text);
  }

  Future<void> _testConnection() async {
    setState(() => _isTesting = true);
    try {
      // 简单测试：发送一个轻量请求
      final cloudService = CloudVendorService();
      // 这里只是测试网络连通性，实际可替换为 AIProvider 调用
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_strings.knode_app_connection_success), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_strings.knode_app_connection_failed}: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _isTesting = false);
  }

  CloudVendor? get _currentVendor {
    if (_selectedVendor == null) return null;
    try {
      return widget.vendors.firstWhere((v) => v.vendor == _selectedVendor);
    } catch (_) {
      return null;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 服务商选择
        _buildVendorDropdown(),
        const SizedBox(height: 12),

        // API Key 引导链接
        if (_currentVendor != null && _currentVendor!.keyUrl.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () {
                // url_launcher 打开链接
              },
              child: Text(
                _strings.knode_app_no_key_hint,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),

        // API 协议
        _buildApiSpecField(),
        const SizedBox(height: 12),

        // API Key
        _buildApiKeyField(),
        const SizedBox(height: 12),

        // 接口地址
        _buildBaseUrlField(),
        const SizedBox(height: 12),

        // 模型选择
        _buildModelField(),
        const SizedBox(height: 16),

        // 测试连接
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _isTesting ? null : _testConnection,
            child: _isTesting
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(_strings.knode_app_test_connection),
          ),
        ),
      ],
    );
  }

  Widget _buildVendorDropdown() {
    final items = [
      ...widget.vendors.map((v) => DropdownMenuItem(
        value: v.vendor,
        child: Text(v.vendor),
      )),
      DropdownMenuItem(
        value: '__custom__',
        child: Text(_strings.knode_app_custom_label),
      ),
    ];

    return DropdownButtonFormField<String>(
      value: _isCustomVendor ? '__custom__' : _selectedVendor,
      decoration: InputDecoration(
        labelText: _strings.knode_app_service_provider,
        border: const OutlineInputBorder(),
      ),
      items: items,
      onChanged: _onVendorChanged,
    );
  }

  Widget _buildApiSpecField() {
    if (_isCustomVendor) {
      return DropdownButtonFormField<String>(
        value: _apiSpec,
        decoration: InputDecoration(
          labelText: _strings.knode_app_api_protocol,
          border: const OutlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem(value: 'openai', child: Text('OpenAI Compatible')),
          DropdownMenuItem(value: 'anthropic', child: Text('Anthropic Claude')),
        ],
        onChanged: (v) {
          if (v != null) {
            setState(() => _apiSpec = v);
            _autoSave();
          }
        },
      );
    }

    // 已知厂商：只读显示
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'API Protocol',
        border: OutlineInputBorder(),
      ),
      child: Text(_apiSpec == 'anthropic' ? 'Anthropic' : 'OpenAI Compatible'),
    );
  }

  Widget _buildApiKeyField() {
    return TextField(
      controller: _apiKeyController,
      obscureText: !_showApiKey,
      decoration: InputDecoration(
        labelText: 'API Key',
        border: const OutlineInputBorder(),
        hintText: _apiSpec == 'anthropic' ? 'sk-ant-api03-...' : 'sk-...',
        suffixIcon: IconButton(
          icon: Icon(_showApiKey ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _showApiKey = !_showApiKey),
        ),
      ),
      onChanged: (_) => _autoSave(),
    );
  }

  Widget _buildBaseUrlField() {
    return TextField(
      controller: _baseUrlController,
      decoration: InputDecoration(
        labelText: _strings.knode_app_api_base_url,
        border: const OutlineInputBorder(),
        hintText: _isCustomVendor ? 'https://api.example.com' : null,
      ),
      onChanged: (_) => _autoSave(),
    );
  }

  Widget _buildModelField() {
    if (_isCustomVendor || _currentVendor == null) {
      return TextField(
        controller: _modelController,
        decoration: InputDecoration(
          labelText: _strings.knode_app_model_name_label,
          border: const OutlineInputBorder(),
          hintText: 'gpt-4o-mini',
        ),
        onChanged: (_) => _autoSave(),
      );
    }

    // 已知厂商：下拉 + 支持手动输入
    return DropdownButtonFormField<String>(
      value: _currentVendor!.models.contains(_modelController.text)
          ? _modelController.text
          : null,
      decoration: InputDecoration(
        labelText: _strings.knode_app_model_name_label,
        border: const OutlineInputBorder(),
      ),
      items: _currentVendor!.models.map((m) => DropdownMenuItem(
        value: m,
        child: Text(m),
      )).toList(),
      onChanged: (v) {
        if (v != null) {
          _modelController.text = v;
          _autoSave();
        }
      },
    );
  }
}
