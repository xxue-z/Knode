import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/extensions/riverpod_compat.dart';
import 'package:core/providers/settings_provider.dart';
import 'package:knode_app/gen/strings.dart';

const _strings = L10nStringsMixin();

class WrongReviewSettingsPage extends ConsumerStatefulWidget {
  const WrongReviewSettingsPage({super.key});

  @override
  ConsumerState<WrongReviewSettingsPage> createState() => _WrongReviewSettingsPageState();
}

class _WrongReviewSettingsPageState extends ConsumerState<WrongReviewSettingsPage> {
  int _reviewCount = 10;
  double _reviewWrongRatio = 0.5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = ref.read(settingsProvider).valueOrNull ?? {};
      setState(() {
        _reviewCount = int.tryParse(s['quiz_review_count'] ?? '10') ?? 10;
        _reviewWrongRatio = double.tryParse(s['quiz_review_wrong_ratio'] ?? '0.5') ?? 0.5;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_strings.knode_app_wrong_review), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNumberTile(title: _strings.quiz_review_count, value: _reviewCount, min: 5, max: 30, onChanged: (v) => setState(() => _reviewCount = v)),
          ListTile(
            title: Text(_strings.quiz_review_wrong_ratio),
            subtitle: Slider(value: _reviewWrongRatio, min: 0, max: 1, divisions: 10, label: '${(_reviewWrongRatio * 100).round()}%', onChanged: (v) => setState(() => _reviewWrongRatio = v)),
            trailing: Text('${(_reviewWrongRatio * 100).round()}%', style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(height: 32),
          FilledButton(onPressed: _save, child: Text(_strings.quiz_save_settings)),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final notifier = ref.read(settingsProvider.notifier);
    await notifier.set('quiz_review_count', _reviewCount.toString());
    await notifier.set('quiz_review_wrong_ratio', _reviewWrongRatio.toString());
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