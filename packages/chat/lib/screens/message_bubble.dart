import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:core/models/message.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message, this.onCitationTap});
  final Message message;
  final ValueChanged<int>? onCitationTap;
  bool get isUser => message.role == 'user';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final citations = _parseCitations(message.citations);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4), bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownBody(
              data: message.content,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  color: isUser ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                  fontSize: 14, height: 1.5,
                ),
              ),
            ),
            // 引用列表（仅助手消息且有引用时显示）
            if (!isUser && citations.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: citations.asMap().entries.map((entry) {
                  final index = entry.key;
                  final cite = entry.value;
                  return InkWell(
                    onTap: () => onCitationTap?.call(cite['doc_id'] as int? ?? 0),
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '[${index + 1}] ${cite['title'] ?? ''}',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 解析 citations JSON 字符串。
  List<Map<String, dynamic>> _parseCitations(String? citationsJson) {
    if (citationsJson == null || citationsJson.isEmpty) return [];
    try {
      final list = jsonDecode(citationsJson) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }
}
