import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/exam_provider.dart';
import 'question_card.dart';
import 'timer_widget.dart';
import 'result_page.dart';

/// 答题页面，使用 PageView 逐题展示，底部显示进度条和交卷按钮。
class ExamPage extends ConsumerStatefulWidget {
  const ExamPage({super.key, required this.examId});
  final int examId;

  @override
  ConsumerState<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends ConsumerState<ExamPage> {
  @override
  Widget build(BuildContext context) {
    final session = ref.watch(examSessionProvider);

    // 已完成 → 显示结果
    if (session.isFinished && session.result != null) {
      return ResultPage(
        correctCount: session.result!.correctCount,
        total: session.result!.questionCount,
        answers: session.answers,
        questions: session.questions,
      );
    }

    // 加载中
    if (session.questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = session.currentQuestion!;

    return Scaffold(
      appBar: AppBar(
        title: Text('第 ${session.currentIndex + 1}/${session.questions.length} 题'),
        centerTitle: true,
        actions: [
          if (session.exam?.timeLimit != null)
            TimerWidget(
              duration: session.remainingSeconds,
              onTimeUp: () => _finishExam(),
              onTick: (remaining) {
                ref.read(examSessionProvider.notifier).tick();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // 进度条
          LinearProgressIndicator(
            value: session.progress,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          Expanded(
            child: QuestionCard(
              question: question,
              questionIndex: session.currentIndex,
              selectedAnswer: session.answers[question.id],
              onAnswer: (answer) {
                ref.read(examSessionProvider.notifier).submitAnswer(answer);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 上一题
              if (session.currentIndex > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => ref.read(examSessionProvider.notifier).previous(),
                    child: const Text('上一题'),
                  ),
                ),
              if (session.currentIndex > 0) const SizedBox(width: 12),
              // 下一题 / 交卷
              Expanded(
                child: FilledButton(
                  onPressed: session.answers.containsKey(question.id)
                      ? () {
                          if (session.currentIndex < session.questions.length - 1) {
                            ref.read(examSessionProvider.notifier).next();
                          } else {
                            _showSubmitDialog();
                          }
                        }
                      : null,
                  child: Text(
                    session.currentIndex == session.questions.length - 1 ? '交卷' : '下一题',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSubmitDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('确认交卷'),
        content: Text('已答 ${ref.read(examSessionProvider).answeredCount}/${ref.read(examSessionProvider).questions.length} 题'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('继续答题')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _finishExam();
            },
            child: const Text('交卷'),
          ),
        ],
      ),
    );
  }

  void _finishExam() {
    ref.read(examSessionProvider.notifier).finishExam();
  }
}
