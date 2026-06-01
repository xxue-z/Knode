import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/models/question.dart';
import 'package:quiz/gen/strings.dart';

const _strings = L10nStringsMixin();

/// 成绩展示页面，显示总分、每题得分，可点击查看源文档。
class ResultPage extends ConsumerWidget {
  const ResultPage({
    super.key,
    required this.correctCount,
    required this.total,
    required this.answers,
    required this.questions,
    this.onSourceDocumentTap,
  });

  final int correctCount, total;
  final Map<int, String> answers;
  final List<Question> questions;

  /// Callback when user taps to view a source document. Receives the document ID.
  final void Function(int docId)? onSourceDocumentTap;

  double get score => total == 0 ? 0 : (correctCount / total * 100);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(_strings.quiz_exam_result), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 总分卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    '${score.toStringAsFixed(0)}分',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: score >= 60 ? colorScheme.primary : colorScheme.error,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '答对 $correctCount / $total 题',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    score >= 60 ? _strings.quiz_congratulations_passed : _strings.quiz_keep_going,
                    style: TextStyle(
                      color: score >= 60 ? colorScheme.primary : colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 题目列表
          ...questions.asMap().entries.map((e) {
            final i = e.key;
            final q = e.value;
            final userAnswer = answers[q.id] ?? answers[i];
            final isCorrect = userAnswer == q.answer;

            return Card(
              child: ListTile(
                leading: Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
                title: Text(q.stem, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${_strings.quiz_your_answer}: ${userAnswer ?? _strings.quiz_not_answered}'),
                    Text('${_strings.quiz_correct_answer}: ${q.answer}'),
                    if (q.explanation != null && q.explanation!.isNotEmpty)
                      Text(
                        '${_strings.quiz_explanation}: ${q.explanation}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                  ],
                ),
                isThreeLine: true,
                onTap: () => _showDetail(context, q, userAnswer, isCorrect),
                // 如果有关联文档，显示跳转按钮
                trailing: q.sourceFileIds != null
                    ? IconButton(
                        icon: const Icon(Icons.open_in_new),
                        tooltip: _strings.quiz_view_source_document,
                        onPressed: () {
                          // 解析第一个关联文档 ID
                          final ids = q.sourceFileIds!.split(',').map(int.tryParse).whereType<int>().toList();
                          if (ids.isNotEmpty && onSourceDocumentTap != null) {
                            onSourceDocumentTap!(ids.first);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(_strings.quiz_no_associated_document)),
                            );
                          }
                        },
                      )
                    : null,
              ),
            );
          }),

          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_strings.quiz_return),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, Question q, String? userAnswer, bool isCorrect) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(q.stem, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (q.options != null) Text('${_strings.quiz_options}: ${q.options}'),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(isCorrect ? Icons.check : Icons.close,
                    color: isCorrect ? Colors.green : Colors.red, size: 18),
                const SizedBox(width: 8),
                Text('${_strings.quiz_your_answer}: ${userAnswer ?? _strings.quiz_not_answered}'),
              ],
            ),
            const SizedBox(height: 8),
            Text('${_strings.quiz_correct_answer}: ${q.answer}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            if (q.explanation != null) ...[
              const SizedBox(height: 12),
              Text('${_strings.quiz_explanation}: ${q.explanation}'),
            ],
          ],
        ),
      ),
    );
  }
}
