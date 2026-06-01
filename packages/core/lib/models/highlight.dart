
import 'highlight_style.dart';

/// 高亮/笔记数据模型。
class Highlight {
  final int? id;
  final int docId;
  final int startPos;
  final int endPos;
  final String selectedText;
  final HighlightStyle style;
  final String? noteText;
  final int? noteDocId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Highlight({
    this.id,
    required this.docId,
    required this.startPos,
    required this.endPos,
    required this.selectedText,
    required this.style,
    this.noteText,
    this.noteDocId,
    required this.createdAt,
    required this.updatedAt,
  });

  Highlight copyWith({
    int? id,
    int? docId,
    int? startPos,
    int? endPos,
    String? selectedText,
    HighlightStyle? style,
    String? noteText,
    int? noteDocId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Highlight(
      id: id ?? this.id,
      docId: docId ?? this.docId,
      startPos: startPos ?? this.startPos,
      endPos: endPos ?? this.endPos,
      selectedText: selectedText ?? this.selectedText,
      style: style ?? this.style,
      noteText: noteText ?? this.noteText,
      noteDocId: noteDocId ?? this.noteDocId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
