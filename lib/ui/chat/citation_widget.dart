import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:core/models/citation.dart';

class CitationWidget extends StatelessWidget {
  const CitationWidget({super.key, required this.citationsJson, this.onTapDoc});
  final String? citationsJson;
  final ValueChanged<int>? onTapDoc;

  List<Citation> _parse() {
    if (citationsJson == null || citationsJson!.isEmpty) return [];
    try {
      final list = jsonDecode(citationsJson!) as List;
      return list.map((e) => Citation.fromMap(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final citations = _parse();
    if (citations.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('引用来源', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          ...citations.asMap().entries.map((e) {
            final i = e.key + 1;
            final c = e.value;
            return InkWell(
              onTap: () => onTapDoc?.call(c.docId),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('[$i] ', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: 12)),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                        Text(c.snippet, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ],
                    )),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}