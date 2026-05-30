import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/models/daily_task_config.dart';
import 'package:quiz/gen/strings.dart';
import 'package:quiz/providers/quiz_provider.dart';

const _strings = L10nStringsMixin();

/// 每日一测配置页面，可设置启用/禁用、出题范围、题目数量、提醒时间。
class DailyConfigPage extends ConsumerStatefulWidget {
  const DailyConfigPage({super.key});

  @override
  ConsumerState<DailyConfigPage> createState() => _DailyConfigPageState();
}

class _DailyConfigPageState extends ConsumerState<DailyConfigPage> {
  bool _isEnabled = true;
  String _scopeType = 'all'; // all / category / days
  int _questionCount = 10;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // 加载现有配置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final configAsync = ref.read(dailyConfigProvider);
      configAsync.whenData((config) {
        if (config != null) {
          setState(() {
            _isEnabled = config.isEnabled == 1;
            _scopeType = config.scopeType;
            _questionCount = config.questionCount;
            if (config.reminderTime != null) {
              final parts = config.reminderTime!.split(':');
              if (parts.length == 2) {
                _reminderTime = TimeOfDay(
                  hour: int.tryParse(parts[0]) ?? 20,
                  minute: int.tryParse(parts[1]) ?? 0,
                );
              }
            }
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_strings.quiz_daily_quiz_settings),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 启用开关
          SwitchListTile(
            title: Text(_strings.quiz_enable_daily_quiz),
            subtitle: Text(_strings.quiz_generate_quiz_questions_daily),
            value: _isEnabled,
            onChanged: (v) => setState(() {
              _isEnabled = v;
              _hasChanges = true;
            }),
          ),
          const Divider(),

          // 出题范围
          ListTile(
            title: Text(_strings.quiz_question_scope),
            subtitle: Text(_scopeTypeLabel(_scopeType)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showScopeSelector(),
          ),
          const Divider(),

          // 题目数量
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Text('${_strings.quiz_question_count}: '),
                Expanded(
                  child: Slider(
                    value: _questionCount.toDouble(),
                    min: 5,
                    max: 50,
                    divisions: 9,
                    label: _questionCount.toString(),
                    onChanged: (v) => setState(() {
                      _questionCount = v.round();
                      _hasChanges = true;
                    }),
                  ),
                ),
                Text('$_questionCount', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
          const Divider(),

          // 提醒时间
          ListTile(
            title: Text(_strings.quiz_reminder_time),
            subtitle: Text(_reminderTime.format(context)),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final t = await showTimePicker(context: context, initialTime: _reminderTime);
              if (t != null) setState(() {
                _reminderTime = t;
                _hasChanges = true;
              });
            },
          ),
          const SizedBox(height: 32),

          // 保存按钮
          FilledButton(
            onPressed: _hasChanges ? _save : null,
            child: Text(_strings.quiz_save_settings),
          ),
        ],
      ),
    );
  }

  void _showScopeSelector() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(_strings.quiz_all_knowledge_base),
              leading: Radio<String>(
                value: 'all',
                groupValue: _scopeType,
                onChanged: (v) => _setScope(v!),
              ),
            ),
            ListTile(
              title: Text(_strings.quiz_specific_category),
              leading: Radio<String>(
                value: 'category',
                groupValue: _scopeType,
                onChanged: (v) => _setScope(v!),
              ),
            ),
            ListTile(
              title: Text(_strings.quiz_recent_reading_documents),
              leading: Radio<String>(
                value: 'days',
                groupValue: _scopeType,
                onChanged: (v) => _setScope(v!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setScope(String scope) {
    setState(() {
      _scopeType = scope;
      _hasChanges = true;
    });
    Navigator.pop(context);
  }

  Future<void> _save() async {
    final config = DailyTaskConfig(
      id: 1,
      isEnabled: _isEnabled ? 1 : 0,
      scopeType: _scopeType,
      questionCount: _questionCount,
      reminderTime: '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    await ref.read(dailyConfigProvider.notifier).save(config);

    if (mounted) {
      setState(() => _hasChanges = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_strings.quiz_settings_saved)),
      );
      Navigator.pop(context);
    }
  }

  String _scopeTypeLabel(String type) {
    switch (type) {
      case 'all':
        return _strings.quiz_all_knowledge_base;
      case 'category':
        return _strings.quiz_specific_category;
      case 'days':
        return _strings.quiz_recent_reading_documents;
      default:
        return type;
    }
  }
}
