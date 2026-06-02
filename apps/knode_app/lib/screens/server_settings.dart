import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/extensions/riverpod_compat.dart';
import 'package:core/providers/settings_provider.dart';
import 'package:knode_app/gen/strings.dart';

final _strings = const L10nStringsMixin();

class ServerSettingsPage extends ConsumerStatefulWidget {
  const ServerSettingsPage({super.key});
  @override
  ConsumerState<ServerSettingsPage> createState() => _ServerSettingsPageState();
}

class _ServerSettingsPageState extends ConsumerState<ServerSettingsPage> {
  bool _enabled = false;
  final _portController = TextEditingController(text: '8080');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(settingsProvider).valueOrNull ?? {};
      setState(() {
        _enabled = settings['server_enabled'] == 'true';
        _portController.text = settings['server_port'] ?? '8080';
      });
    });
  }

  Future<void> _save() async {
    final notifier = ref.read(settingsProvider.notifier);
    await notifier.set('server_enabled', _enabled.toString());
    await notifier.set('server_port', _portController.text);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_strings.knode_app_save_success)));
  }

  @override
  void dispose() { _portController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_strings.knode_app_server_settings), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: Text(_strings.knode_app_enable_micro_server),
            subtitle: Text(_strings.knode_app_enable_micro_server_desc),
            value: _enabled,
            onChanged: (v) => setState(() => _enabled = v),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _portController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: _strings.knode_app_port, border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: Text(_strings.knode_app_save)),
        ],
      ),
    );
  }
}
