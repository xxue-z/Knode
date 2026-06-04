import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/providers/theme_provider.dart';
import 'package:quiz/gen/strings.dart';
import 'package:quiz/theme/quiz_theme.dart';
import '../../providers/exam_provider.dart';
import 'exam_page.dart';

const _strings = L10nStringsMixin();

/// 测验页面骨架
///
/// 占位页面，后续 P3 阶段会填充测验入口卡片（每日一测、随机速记、月考等）。
class QuizPage extends ConsumerWidget {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final isDark = themeMode == ThemeMode.dark;
    final theme = QuizTheme.of(isDark: isDark);

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: theme.primaryColor,
          surface: theme.backgroundColor,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_strings.quiz_quiz),
        ),
        body: const _QuizBody(),
      ),
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
                _strings.quiz_quiz_types,
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
              label: _strings.quiz_completed,
              value: '--',
              color: colorScheme.primary,
            ),
            _StatItem(
              icon: Icons.local_fire_department_outlined,
              label: _strings.quiz_streak_days,
              value: '--',
              color: colorScheme.tertiary,
            ),
            _StatItem(
              icon: Icons.trending_up_outlined,
              label: _strings.quiz_accuracy,
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

  static final _quizTypes = [
    _QuizTypeData(
      icon: Icons.wb_sunny_outlined,
      label: _strings.quiz_daily_quiz,
      description: _strings.quiz_ten_questions_per_day,
      examType: 'daily',
    ),
    _QuizTypeData(
      icon: Icons.shuffle_outlined,
      label: _strings.quiz_random_quiz,
      description: _strings.quiz_random_quick_review,
      examType: 'random',
    ),
    _QuizTypeData(
      icon: Icons.calendar_month_outlined,
      label: _strings.quiz_monthly_exam,
      description: _strings.quiz_monthly_comprehensive_quiz,
      examType: 'monthly',
    ),
    _QuizTypeData(
      icon: Icons.date_range_outlined,
      label: _strings.quiz_quarterly_exam,
      description: _strings.quiz_quarterly_comprehensive_quiz,
      examType: 'quarterly',
    ),
    _QuizTypeData(
      icon: Icons.event_outlined,
      label: _strings.quiz_yearly_exam,
      description: _strings.quiz_yearly_comprehensive_quiz,
      examType: 'yearly',
    ),
    _QuizTypeData(
      icon: Icons.replay_outlined,
      label: _strings.quiz_wrong_question_review,
      description: _strings.quiz_consolidate_weak_knowledge_points,
      examType: 'review',
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

  Future<void> _navigateToExam(BuildContext context, WidgetRef ref) async {
    try {
      // 通过 examProvider 创建考试记录
      final exam = await ref.read(examListProvider.notifier).createExam(
        examType: data.examType,
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
          MaterialPageRoute<void>(
            builder: (_) => ExamPage(examId: exam.id),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_strings.quiz_create_exam_failed}: $e')),
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
    required this.examType,
  });

  final IconData icon;
  final String label;
  final String description;
  final String examType;
}
