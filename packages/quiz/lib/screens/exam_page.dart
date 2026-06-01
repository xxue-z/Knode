import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz/gen/strings.dart';
import '../../../providers/exam_provider.dart';

import 'question_card.dart';
import 'timer_widget.dart';
import 'result_page.dart';

const _strings = L10nStringsMixin();

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
        title: Text(_strings.quiz_question_n_of_m.replaceAll('{n}', '${session.currentIndex + 1}').replaceAll('{m}', '${session.questions.length}')),
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
                    child: Text(_strings.quiz_previous_question),
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
                    session.currentIndex == session.questions.length - 1 ? _strings.quiz_submit_exam : _strings.quiz_next_question,
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
        title: Text(_strings.quiz_confirm_submit),
        content: Text(_strings.quiz_answered_n_of_m.replaceAll('{n}', '${ref.read(examSessionProvider).answeredCount}').replaceAll('{m}', '${ref.read(examSessionProvider).questions.length}')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(_strings.quiz_continue_answering)),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _finishExam();
            },
            child: Text(_strings.quiz_submit_exam),
          ),
        ],
      ),
    );
  }

  void _finishExam() {
    ref.read(examSessionProvider.notifier).finishExam();
  }
}
