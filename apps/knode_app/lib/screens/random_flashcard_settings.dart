import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/extensions/riverpod_compat.dart';
import 'package:core/providers/settings_provider.dart';
import 'package:knode_app/gen/strings.dart';

const _strings = L10nStringsMixin();

class RandomFlashcardSettingsPage extends ConsumerStatefulWidget {
  const RandomFlashcardSettingsPage({super.key});

  @override
  ConsumerState<RandomFlashcardSettingsPage> createState() => _RandomFlashcardSettingsPageState();
}

class _RandomFlashcardSettingsPageState extends ConsumerState<RandomFlashcardSettingsPage> {
  int _randomCount = 10;
  int _randomDays = 7;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = ref.read(settingsProvider).valueOrNull ?? {};
      setState(() {
        _randomCount = int.tryParse(s['quiz_random_count'] ?? '10') ?? 10;
        _randomDays = int.tryParse(s['quiz_random_days'] ?? '7') ?? 7;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_strings.knode_app_random_flashcard), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNumberTile(title: _strings.quiz_random_count, value: _randomCount, min: 5, max: 30, onChanged: (v) => setState(() => _randomCount = v)),
          _buildNumberTile(title: _strings.quiz_random_days, value: _randomDays, min: 1, max: 30, onChanged: (v) => setState(() => _randomDays = v)),
          const SizedBox(height: 32),
          FilledButton(onPressed: _save, child: Text(_strings.quiz_save_settings)),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final notifier = ref.read(settingsProvider.notifier);
    await notifier.set('quiz_random_count', _randomCount.toString());
    await notifier.set('quiz_random_days', _randomDays.toString());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_strings.quiz_settings_saved)));
      Navigator.of(context).pop();
    }
  }

  Widget _buildNumberTile({required String title, required int value, required int min, required int max, required ValueChanged<int> onChanged}) {
    return ListTile(title: Text(title), trailing: Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: value > min ? () => onChanged(value - 1) : null),
      Text('$value', style: const TextStyle(fontSize: 16)),
      IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: value < max ? () => onChanged(value + 1) : null),
    ]));
  }
}