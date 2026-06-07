import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/extensions/riverpod_compat.dart';
import 'package:core/providers/settings_provider.dart';
import 'package:knode_app/gen/strings.dart';

const _strings = L10nStringsMixin();

class DailyQuizSettingsPage extends ConsumerStatefulWidget {
  const DailyQuizSettingsPage({super.key});

  @override
  ConsumerState<DailyQuizSettingsPage> createState() => _DailyQuizSettingsPageState();
}

class _DailyQuizSettingsPageState extends ConsumerState<DailyQuizSettingsPage> {
  int _dailyCount = 10;
  String _dailyScope = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = ref.read(settingsProvider).valueOrNull ?? {};
      setState(() {
        _dailyCount = int.tryParse(s['quiz_daily_count'] ?? '10') ?? 10;
        _dailyScope = s['quiz_daily_scope'] ?? 'all';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_strings.knode_app_daily_quiz), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNumberTile(
            title: _strings.knode_app_quiz_daily_count,
            value: _dailyCount,
            min: 5,
            max: 30,
            onChanged: (v) => setState(() => _dailyCount = v),
          ),
          _buildDropdownTile(
            title: _strings.knode_app_quiz_daily_scope,
            value: _dailyScope,
            items: [
              {'value': 'all', 'label': _strings.knode_app_quiz_scope_all},
              {'value': 'category', 'label': _strings.knode_app_quiz_scope_category},
              {'value': 'days', 'label': _strings.knode_app_quiz_scope_days},
            ],
            onChanged: (v) => setState(() => _dailyScope = v),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _save,
            child: Text(_strings.knode_app_quiz_save_settings),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final notifier = ref.read(settingsProvider.notifier);
    await notifier.set('quiz_daily_count', _dailyCount.toString());
    await notifier.set('quiz_daily_scope', _dailyScope);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_strings.knode_app_quiz_settings_saved)),
      );
      Navigator.of(context).pop();
    }
  }

  Widget _buildNumberTile({required String title, required int value, required int min, required int max, required ValueChanged<int> onChanged}) {
    return ListTile(
      title: Text(title),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: value > min ? () => onChanged(value - 1) : null),
        Text('$value', style: const TextStyle(fontSize: 16)),
        IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: value < max ? () => onChanged(value + 1) : null),
      ]),
    );
  }

  Widget _buildDropdownTile({required String title, required String value, required List<Map<String, String>> items, required ValueChanged<String> onChanged}) {
    return ListTile(
      title: Text(title),
      trailing: DropdownButton<String>(value: value, items: items.map((i) => DropdownMenuItem(value: i['value'], child: Text(i['label']!))).toList(), onChanged: (v) { if (v != null) onChanged(v); }),
    );
  }
}