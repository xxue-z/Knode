import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/extensions/riverpod_compat.dart';
import 'package:core/providers/settings_provider.dart';
import 'package:knode_app/gen/strings.dart';

const _strings = L10nStringsMixin();

class ExamSettingsPage extends ConsumerStatefulWidget {
  const ExamSettingsPage({super.key});

  @override
  ConsumerState<ExamSettingsPage> createState() => _ExamSettingsPageState();
}

class _ExamSettingsPageState extends ConsumerState<ExamSettingsPage> {
  int _monthlyCount = 50;
  int _quarterlyCount = 60;
  int _yearlyCount = 80;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = ref.read(settingsProvider).valueOrNull ?? {};
      setState(() {
        _monthlyCount = int.tryParse(s['quiz_monthly_count'] ?? '50') ?? 50;
        _quarterlyCount = int.tryParse(s['quiz_quarterly_count'] ?? '60') ?? 60;
        _yearlyCount = int.tryParse(s['quiz_yearly_count'] ?? '80') ?? 80;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_strings.knode_app_exam_settings), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle(_strings.quiz_monthly_exam_2),
          _buildNumberTile(title: _strings.quiz_monthly_count, value: _monthlyCount, min: 20, max: 100, onChanged: (v) => setState(() => _monthlyCount = v)),
          _buildNumberTile(title: _strings.quiz_quarterly_count, value: _quarterlyCount, min: 30, max: 100, onChanged: (v) => setState(() => _quarterlyCount = v)),
          _buildNumberTile(title: _strings.quiz_yearly_count, value: _yearlyCount, min: 40, max: 100, onChanged: (v) => setState(() => _yearlyCount = v)),
          const SizedBox(height: 32),
          FilledButton(onPressed: _save, child: Text(_strings.quiz_save_settings)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)));
  }

  Widget _buildNumberTile({required String title, required int value, required int min, required int max, required ValueChanged<int> onChanged}) {
    return ListTile(title: Text(title), trailing: Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: value > min ? () => onChanged(value - 1) : null),
      Text('$value', style: const TextStyle(fontSize: 16)),
      IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: value < max ? () => onChanged(value + 1) : null),
    ]));
  }

  Future<void> _save() async {
    final notifier = ref.read(settingsProvider.notifier);
    await notifier.set('quiz_monthly_count', _monthlyCount.toString());
    await notifier.set('quiz_quarterly_count', _quarterlyCount.toString());
    await notifier.set('quiz_yearly_count', _yearlyCount.toString());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_strings.quiz_settings_saved)));
      Navigator.of(context).pop();
    }
  }
}