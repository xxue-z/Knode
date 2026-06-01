import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/models/exam.dart';
import 'package:quiz/gen/strings.dart';
import 'package:quiz/providers/periodic_exam_provider.dart';
import 'package:quiz/screens/exam_page.dart';

const _strings = L10nStringsMixin();

/// 阶段考试历史列表页面。
///
/// 显示所有阶段考试记录，支持补考入口。
class PeriodicExamHistoryPage extends ConsumerStatefulWidget {
  const PeriodicExamHistoryPage({super.key});

  @override
  ConsumerState<PeriodicExamHistoryPage> createState() =>
      _PeriodicExamHistoryPageState();
}

class _PeriodicExamHistoryPageState
    extends ConsumerState<PeriodicExamHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _currentType = 'monthly';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final types = ['monthly', 'quarterly', 'yearly'];
    setState(() => _currentType = types[_tabController.index]);
    ref
        .read(periodicExamHistoryProvider.notifier)
        .loadHistory(_currentType);
  }

  @override
  Widget build(BuildContext context) {
    final examsAsync = ref.watch(periodicExamHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_strings.quiz_exam_history),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: _strings.quiz_monthly_exam_2),
            Tab(text: _strings.quiz_quarterly_exam_2),
            Tab(text: _strings.quiz_yearly_exam_2),
          ],
        ),
      ),
      body: examsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (exams) {
          if (exams.isEmpty) {
            return Center(
              child: Text(_strings.quiz_no_exam_records),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: exams.length,
            itemBuilder: (context, index) => _buildExamCard(exams[index]),
          );
        },
      ),
    );
  }

  Widget _buildExamCard(Exam exam) {
    final isCompleted = exam.status == 'completed';
    final isPending = exam.status == 'pending';
    final score = exam.totalScore;
    final isPassed = score != null && score >= 60;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCompleted
              ? (isPassed ? Colors.green.shade100 : Colors.red.shade100)
              : Colors.blue.shade100,
          child: Icon(
            isCompleted
                ? (isPassed ? Icons.check : Icons.close)
                : Icons.pending,
            color: isCompleted
                ? (isPassed ? Colors.green : Colors.red)
                : Colors.blue,
          ),
        ),
        title: Text(exam.title ?? _strings.quiz_exam),
        subtitle: Text(
          isCompleted && score != null
              ? '${_strings.quiz_score}: ${score.toStringAsFixed(1)}'
              : _strings.quiz_completed,
        ),
        trailing: isPending
            ? FilledButton.tonal(
                onPressed: () => _startMakeupExam(exam),
                child: Text(_strings.quiz_makeup_exam),
              )
            : null,
      ),
    );
  }

  void _startMakeupExam(Exam exam) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ExamPage(examId: exam.id),
      ),
    );
  }
}
