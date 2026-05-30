import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/exam_provider.dart';
import 'exam/exam_page.dart';

/// 测验页面骨架
///
/// 占位页面，后续 P3 阶段会填充测验入口卡片（每日一测、随机速记、月考等）。
class QuizPage extends StatelessWidget {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('测验'),
      ),
      body: const _QuizBody(),
    );
  }
}

class _QuizBody extends StatelessWidget {
  const _QuizBody();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final crossAxisCount = isWide ? 3 : 2;
        final padding = isWide ? 24.0 : 16.0;

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部统计区域占位
              const _StatsCard(),
              SizedBox(height: padding),
              // 测验类型卡片网格
              Text(
                '测验类型',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _QuizGrid(crossAxisCount: crossAxisCount),
            ],
          ),
        );
      },
    );
  }
}

/// 顶部统计卡片占位
class _StatsCard extends StatelessWidget {
  const _StatsCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              icon: Icons.check_circle_outline,
              label: '已完成',
              value: '--',
              color: colorScheme.primary,
            ),
            _StatItem(
              icon: Icons.local_fire_department_outlined,
              label: '连续天数',
              value: '--',
              color: colorScheme.tertiary,
            ),
            _StatItem(
              icon: Icons.trending_up_outlined,
              label: '正确率',
              value: '--',
              color: colorScheme.secondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: textTheme.bodySmall),
      ],
    );
  }
}

/// 测验类型卡片网格
class _QuizGrid extends StatelessWidget {
  const _QuizGrid({required this.crossAxisCount});

  final int crossAxisCount;

  static const _quizTypes = [
    _QuizTypeData(
      icon: Icons.wb_sunny_outlined,
      label: '每日一测',
      description: '每天 10 道题',
    ),
    _QuizTypeData(
      icon: Icons.shuffle_outlined,
      label: '随机速记',
      description: '随机抽取快速复习',
    ),
    _QuizTypeData(
      icon: Icons.calendar_month_outlined,
      label: '月考',
      description: '每月综合测验',
    ),
    _QuizTypeData(
      icon: Icons.date_range_outlined,
      label: '季考',
      description: '季度综合测验',
    ),
    _QuizTypeData(
      icon: Icons.event_outlined,
      label: '年考',
      description: '年度综合测验',
    ),
    _QuizTypeData(
      icon: Icons.replay_outlined,
      label: '错题重练',
      description: '巩固薄弱知识点',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: _quizTypes.length,
      itemBuilder: (context, index) {
        return _QuizTypeCard(data: _quizTypes[index]);
      },
    );
  }
}

class _QuizTypeCard extends ConsumerWidget {
  const _QuizTypeCard({required this.data});

  final _QuizTypeData data;

  String _getExamType() {
    switch (data.label) {
      case '每日一测':
        return 'daily';
      case '随机速记':
        return 'random';
      case '月考':
        return 'monthly';
      case '季考':
        return 'quarterly';
      case '年考':
        return 'yearly';
      case '错题重练':
        return 'review';
      default:
        return 'random';
    }
  }

  Future<void> _navigateToExam(BuildContext context, WidgetRef ref) async {
    final examType = _getExamType();

    try {
      // 通过 examProvider 创建考试记录
      final exam = await ref.read(examListProvider.notifier).createExam(
        examType: examType,
        questionCount: 10,
        title: data.label,
      );

      // 初始化答题会话
      ref.read(examSessionProvider.notifier).startExam(
        exam,
        [], // 题目会在 ExamPage 内部加载
      );

      // 导航到答题页面
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExamPage(examId: exam.id),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建考试失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToExam(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                data.icon,
                size: 36,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                data.label,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                data.description,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizTypeData {
  const _QuizTypeData({
    required this.icon,
    required this.label,
    required this.description,
  });

  final IconData icon;
  final String label;
  final String description;
}
