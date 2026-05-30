import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/models/question.dart';
import 'package:core/database/dao/wrong_question_dao.dart';
import 'package:quiz/gen/strings.dart';

const _strings = L10nStringsMixin();

/// 错题详情页面，展示题目、用户答案对比、AI 讲解，支持"掌握"移除。
class WrongDetailPage extends ConsumerStatefulWidget {
  const WrongDetailPage({
    super.key,
    required this.question,
    this.userAnswer,
    this.aiFeedback,
  });

  final Question question;
  final String? userAnswer;
  final String? aiFeedback;

  @override
  ConsumerState<WrongDetailPage> createState() => _WrongDetailPageState();
}

class _WrongDetailPageState extends ConsumerState<WrongDetailPage> {
  bool _isMastered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final q = widget.question;
    final isObjective = q.type == 'single_choice' ||
        q.type == 'multi_choice' ||
        q.type == 'true_false' ||
        q.type == 'fill_blank';

    return Scaffold(
      appBar: AppBar(
        title: Text(_strings.quiz_wrong_question_detail),
        centerTitle: true,
        actions: [
          // 掌握按钮
          TextButton.icon(
            onPressed: _isMastered ? null : _markAsMastered,
            icon: Icon(
              _isMastered ? Icons.check_circle : Icons.check_circle_outline,
              color: _isMastered ? colorScheme.primary : null,
            ),
            label: Text(_strings.quiz_mastered),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 题型标签
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _typeLabel(q.type),
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 题干
          Text(q.stem, style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),

          // 选项（如有）
          if (q.options != null && q.options!.isNotEmpty) ...[
            Text('选项:', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            ...(jsonDecode(q.options!) as List).asMap().entries.map((entry) {
              final optLabel = String.fromCharCode(65 + entry.key);
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('$optLabel. ${entry.value}'),
              );
            }),
            const SizedBox(height: 16),
          ],

          // 用户答案 vs 正确答案（客观题）
          if (isObjective && widget.userAnswer != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.close, color: colorScheme.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_strings.quiz_your_answer}: ${widget.userAnswer}',
                      style: TextStyle(color: colorScheme.onErrorContainer),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          // 正确答案
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check, color: colorScheme.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_strings.quiz_correct_answer}: ${q.answer}',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 解析
          if (q.explanation != null && q.explanation!.isNotEmpty) ...[
            Text('${_strings.quiz_explanation}:', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(q.explanation!, style: theme.textTheme.bodyMedium),
            ),
            const SizedBox(height: 16),
          ],

          // AI 讲解区域
          if (widget.aiFeedback != null && widget.aiFeedback!.isNotEmpty) ...[
            Text('${_strings.quiz_ai_explanation}:', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.tertiary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                widget.aiFeedback!,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 操作按钮
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(_strings.quiz_return),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isMastered ? null : _markAsMastered,
                  icon: Icon(_isMastered ? Icons.check : Icons.school),
                  label: Text(_isMastered ? _strings.quiz_mastered : _strings.quiz_mark_as_mastered),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _markAsMastered() async {
    setState(() => _isMastered = true);
    try {
      final dao = WrongQuestionDao();
      await dao.clear(widget.question.id);
    } catch (_) {
      // 忽略数据库错误，UI 已更新
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_strings.quiz_mastered_will_no_longer_appear)),
      );
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'single_choice':
        return _strings.quiz_single_choice;
      case 'multi_choice':
        return _strings.quiz_multiple_choice;
      case 'true_false':
        return _strings.quiz_true_false;
      case 'fill_blank':
        return _strings.quiz_fill_in_the_blank;
      case 'short_answer':
        return _strings.quiz_short_answer;
      default:
        return type;
    }
  }
}
