import 'package:flutter/material.dart';
import 'package:core/models/question.dart';
import 'package:quiz/gen/strings.dart';
import 'dart:convert';

const _strings = L10nStringsMixin();

/// 单题展示组件，支持 5 种题型。
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.question,
    required this.questionIndex,
    this.selectedAnswer,
    this.onAnswer,
  });

  final Question question;
  final int questionIndex;
  final String? selectedAnswer;
  final ValueChanged<String>? onAnswer;

  List<String>? get _options {
    if (question.options == null) return null;
    try {
      return List<String>.from(jsonDecode(question.options!) as List);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 题干
          Text(question.stem, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 20),

          // 单选题
          if (question.type == 'single_choice' && _options != null)
            ..._options!.asMap().entries.map((e) {
              final letter = String.fromCharCode(65 + e.key);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RadioListTile<String>(
                  title: Text('$letter. ${e.value}'),
                  value: letter,
                  groupValue: selectedAnswer,
                  onChanged: (v) => v != null ? onAnswer?.call(v) : null,
                ),
              );
            }),

          // 多选题
          if (question.type == 'multi_choice' && _options != null) ...[
            Text('（${_strings.quiz_multiple_choice}）', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 8),
            ..._options!.asMap().entries.map((e) {
              final letter = String.fromCharCode(65 + e.key);
              final selected = selectedAnswer?.contains(letter) ?? false;
              return CheckboxListTile(
                title: Text('$letter. ${e.value}'),
                value: selected,
                onChanged: (v) {
                  final current = selectedAnswer ?? '';
                  final updated = v == true
                      ? '$current$letter'
                      : current.replaceAll(letter, '');
                  onAnswer?.call(updated);
                },
              );
            }),
          ],

          // 判断题
          if (question.type == 'true_false')
            ...[_strings.quiz_correct, _strings.quiz_wrong].map((v) => RadioListTile<String>(
                  title: Text(v),
                  value: v[0],
                  groupValue: selectedAnswer,
                  onChanged: (v) => v != null ? onAnswer?.call(v) : null,
                )),

          // 填空题
          if (question.type == 'fill_blank')
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '输入答案',
              ),
              onChanged: onAnswer,
              controller: TextEditingController(text: selectedAnswer),
            ),

          // 简答题
          if (question.type == 'short_answer')
            TextField(
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '输入你的回答...',
                alignLabelWithHint: true,
              ),
              onChanged: onAnswer,
              controller: TextEditingController(text: selectedAnswer),
            ),
        ],
      ),
    );
  }
}
