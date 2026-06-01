import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz/gen/strings.dart';
import 'package:core/providers/settings_provider.dart';

const _strings = L10nStringsMixin();

/// 统一出题配置页面。
///
/// 包含每日一测、随机速记、温故知新、阶段考试的配置。
class QuizConfigPage extends ConsumerStatefulWidget {
  const QuizConfigPage({super.key});

  @override
  ConsumerState<QuizConfigPage> createState() => _QuizConfigPageState();
}

class _QuizConfigPageState extends ConsumerState<QuizConfigPage> {
  // 每日一测
  int _dailyCount = 10;
  String _dailyScope = 'all';

  // 随机速记
  int _randomCount = 10;
  int _randomDays = 7;

  // 温故知新
  int _reviewCount = 10;
  double _reviewWrongRatio = 0.5;

  // AI 出题
  bool _aiEnabled = true;
  String _aiRatioMode = 'smart';
  double _aiFixedRatio = 0.3;
  bool _variantEnabled = false;

  // 阶段考试
  int _monthlyCount = 50;
  int _quarterlyCount = 60;
  int _yearlyCount = 80;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_strings.quiz_quiz_config),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 每日一测 ──
          _buildSectionTitle(_strings.quiz_daily_quiz),
          _buildNumberTile(
            title: _strings.quiz_daily_count,
            value: _dailyCount,
            min: 5,
            max: 30,
            onChanged: (v) => setState(() => _dailyCount = v),
          ),
          _buildDropdownTile(
            title: _strings.quiz_daily_scope,
            value: _dailyScope,
            items: [
              {'value': 'all', 'label': _strings.quiz_scope_all},
              {'value': 'category', 'label': _strings.quiz_scope_category},
              {'value': 'days', 'label': _strings.quiz_scope_days},
            ],
            onChanged: (v) => setState(() => _dailyScope = v),
          ),

          const Divider(height: 32),

          // ── 随机速记 ──
          _buildSectionTitle(_strings.quiz_random_quick_review),
          _buildNumberTile(
            title: _strings.quiz_random_count,
            value: _randomCount,
            min: 5,
            max: 30,
            onChanged: (v) => setState(() => _randomCount = v),
          ),
          _buildNumberTile(
            title: _strings.quiz_random_days,
            value: _randomDays,
            min: 1,
            max: 30,
            onChanged: (v) => setState(() => _randomDays = v),
          ),

          const Divider(height: 32),

          // ── 温故知新 ──
          _buildSectionTitle(_strings.quiz_wrong_question_review),
          _buildNumberTile(
            title: _strings.quiz_review_count,
            value: _reviewCount,
            min: 5,
            max: 30,
            onChanged: (v) => setState(() => _reviewCount = v),
          ),
          _buildSliderTile(
            title: _strings.quiz_review_wrong_ratio,
            value: _reviewWrongRatio,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            label: '${(_reviewWrongRatio * 100).round()}%',
            onChanged: (v) => setState(() => _reviewWrongRatio = v),
          ),

          const Divider(height: 32),

          // ── AI 出题 ──
          _buildSectionTitle(_strings.quiz_ai_enabled),
          SwitchListTile(
            title: Text(_strings.quiz_ai_enabled),
            value: _aiEnabled,
            onChanged: (v) => setState(() => _aiEnabled = v),
          ),
          if (_aiEnabled) ...[
            _buildDropdownTile(
              title: _strings.quiz_ai_ratio_mode,
              value: _aiRatioMode,
              items: [
                {'value': 'smart', 'label': _strings.quiz_ai_ratio_smart},
                {'value': 'fixed', 'label': _strings.quiz_ai_ratio_fixed},
              ],
              onChanged: (v) => setState(() => _aiRatioMode = v),
            ),
            if (_aiRatioMode == 'fixed')
              _buildSliderTile(
                title: _strings.quiz_ai_fixed_ratio,
                value: _aiFixedRatio,
                min: 0.0,
                max: 0.6,
                divisions: 12,
                label: '${(_aiFixedRatio * 100).round()}%',
                onChanged: (v) => setState(() => _aiFixedRatio = v),
              ),
            SwitchListTile(
              title: Text(_strings.quiz_variant_enabled),
              value: _variantEnabled,
              onChanged: (v) => setState(() => _variantEnabled = v),
            ),
          ],

          const Divider(height: 32),

          // ── 阶段考试 ──
          _buildSectionTitle(_strings.quiz_monthly_exam_2),
          _buildNumberTile(
            title: _strings.quiz_monthly_count,
            value: _monthlyCount,
            min: 20,
            max: 100,
            onChanged: (v) => setState(() => _monthlyCount = v),
          ),
          _buildNumberTile(
            title: _strings.quiz_quarterly_count,
            value: _quarterlyCount,
            min: 30,
            max: 100,
            onChanged: (v) => setState(() => _quarterlyCount = v),
          ),
          _buildNumberTile(
            title: _strings.quiz_yearly_count,
            value: _yearlyCount,
            min: 40,
            max: 100,
            onChanged: (v) => setState(() => _yearlyCount = v),
          ),

          const SizedBox(height: 32),

          // ── 保存按钮 ──
          FilledButton(
            onPressed: () => _saveSettings(),
            child: Text(_strings.quiz_save_settings),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildNumberTile({
    required String title,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: value > min ? () => onChanged(value - 1) : null,
          ),
          Text('$value', style: const TextStyle(fontSize: 16)),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String value,
    required List<Map<String, String>> items,
    required ValueChanged<String> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        items: items
            .map((item) => DropdownMenuItem(
                  value: item['value'],
                  child: Text(item['label']!),
                ))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        label: label,
        onChanged: onChanged,
      ),
      trailing: Text(label, style: const TextStyle(fontSize: 14)),
    );
  }

  Future<void> _saveSettings() async {
    final notifier = ref.read(settingsProvider.notifier);
    await notifier.set('quiz_daily_count', _dailyCount.toString());
    await notifier.set('quiz_daily_scope', _dailyScope);
    await notifier.set('quiz_random_count', _randomCount.toString());
    await notifier.set('quiz_random_days', _randomDays.toString());
    await notifier.set('quiz_review_count', _reviewCount.toString());
    await notifier.set('quiz_review_wrong_ratio', _reviewWrongRatio.toString());
    await notifier.set('quiz_monthly_count', _monthlyCount.toString());
    await notifier.set('quiz_quarterly_count', _quarterlyCount.toString());
    await notifier.set('quiz_yearly_count', _yearlyCount.toString());
    await notifier.set('quiz_ai_enabled', _aiEnabled.toString());
    await notifier.set('quiz_ai_ratio_mode', _aiRatioMode);
    await notifier.set('quiz_ai_fixed_ratio', _aiFixedRatio.toString());
    await notifier.set('quiz_variant_enabled', _variantEnabled.toString());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_strings.quiz_settings_saved)),
      );
      Navigator.of(context).pop();
    }
  }
}
