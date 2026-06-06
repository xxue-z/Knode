import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/extensions/riverpod_compat.dart';
import 'package:core/providers/settings_provider.dart';
import 'package:knode_app/gen/strings.dart';

const _strings = L10nStringsMixin();

class AiQuizSettingsPage extends ConsumerStatefulWidget {
  const AiQuizSettingsPage({super.key});

  @override
  ConsumerState<AiQuizSettingsPage> createState() => _AiQuizSettingsPageState();
}

class _AiQuizSettingsPageState extends ConsumerState<AiQuizSettingsPage> {
  bool _aiEnabled = true;
  String _aiRatioMode = 'smart';
  double _aiFixedRatio = 0.3;
  bool _variantEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = ref.read(settingsProvider).valueOrNull ?? {};
      setState(() {
        _aiEnabled = s['quiz_ai_enabled'] == 'true';
        _aiRatioMode = s['quiz_ai_ratio_mode'] ?? 'smart';
        _aiFixedRatio = double.tryParse(s['quiz_ai_fixed_ratio'] ?? '0.3') ?? 0.3;
        _variantEnabled = s['quiz_variant_enabled'] == 'true';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_strings.knode_app_ai_quiz), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(title: Text(_strings.knode_app_quiz_ai_enabled), value: _aiEnabled, onChanged: (v) => setState(() => _aiEnabled = v)),
          if (_aiEnabled) ...[
            ListTile(
              title: Text(_strings.knode_app_quiz_ai_ratio_mode),
              trailing: DropdownButton<String>(value: _aiRatioMode, items: [
                DropdownMenuItem(value: 'smart', child: Text(_strings.knode_app_quiz_ai_ratio_smart)),
                DropdownMenuItem(value: 'fixed', child: Text(_strings.knode_app_quiz_ai_ratio_fixed)),
              ], onChanged: (v) { if (v != null) setState(() => _aiRatioMode = v); }),
            ),
            if (_aiRatioMode == 'fixed')
              ListTile(
                title: Text(_strings.knode_app_quiz_ai_fixed_ratio),
                subtitle: Slider(value: _aiFixedRatio, min: 0, max: 0.6, divisions: 12, label: '${(_aiFixedRatio * 100).round()}%', onChanged: (v) => setState(() => _aiFixedRatio = v)),
                trailing: Text('${(_aiFixedRatio * 100).round()}%', style: const TextStyle(fontSize: 14)),
              ),
            SwitchListTile(title: Text(_strings.knode_app_quiz_variant_enabled), value: _variantEnabled, onChanged: (v) => setState(() => _variantEnabled = v)),
          ],
          const SizedBox(height: 32),
          FilledButton(onPressed: _save, child: Text(_strings.knode_app_quiz_save_settings)),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final notifier = ref.read(settingsProvider.notifier);
    await notifier.set('quiz_ai_enabled', _aiEnabled.toString());
    await notifier.set('quiz_ai_ratio_mode', _aiRatioMode);
    await notifier.set('quiz_ai_fixed_ratio', _aiFixedRatio.toString());
    await notifier.set('quiz_variant_enabled', _variantEnabled.toString());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_strings.knode_app_quiz_settings_saved)));
      Navigator.of(context).pop();
    }
  }
}