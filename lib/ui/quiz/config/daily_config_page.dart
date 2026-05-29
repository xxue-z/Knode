import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/daily_task_config.dart';
import '../../../providers/quiz_provider.dart';

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
        title: const Text('每日一测设置'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 启用开关
          SwitchListTile(
            title: const Text('启用每日一测'),
            subtitle: const Text('每天定时生成测验题目'),
            value: _isEnabled,
            onChanged: (v) => setState(() {
              _isEnabled = v;
              _hasChanges = true;
            }),
          ),
          const Divider(),

          // 出题范围
          ListTile(
            title: const Text('出题范围'),
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
                const Text('题目数量: '),
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
            title: const Text('提醒时间'),
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
            child: const Text('保存设置'),
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
              title: const Text('全部知识库'),
              leading: Radio<String>(
                value: 'all',
                groupValue: _scopeType,
                onChanged: (v) => _setScope(v!),
              ),
            ),
            ListTile(
              title: const Text('指定类目'),
              leading: Radio<String>(
                value: 'category',
                groupValue: _scopeType,
                onChanged: (v) => _setScope(v!),
              ),
            ),
            ListTile(
              title: const Text('最近 N 天阅读'),
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
        const SnackBar(content: Text('设置已保存')),
      );
      Navigator.pop(context);
    }
  }

  String _scopeTypeLabel(String type) {
    switch (type) {
      case 'all':
        return '全部知识库';
      case 'category':
        return '指定类目';
      case 'days':
        return '最近阅读文档';
      default:
        return type;
    }
  }
}
