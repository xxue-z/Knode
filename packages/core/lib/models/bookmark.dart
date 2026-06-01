
/// 书签数据模型。
class Bookmark {
  final int? id;
  final int docId;
  final int position;
  final int endPosition;
  final String selectedText;
  final String? label;
  final DateTime createdAt;

  const Bookmark({
    this.id,
    required this.docId,
    required this.position,
    required this.endPosition,
    required this.selectedText,
    this.label,
    required this.createdAt,
  });

  Bookmark copyWith({
    int? id,
    int? docId,
    int? position,
    int? endPosition,
    String? selectedText,
    String? label,
    DateTime? createdAt,
  }) {
    return Bookmark(
      id: id ?? this.id,
      docId: docId ?? this.docId,
      position: position ?? this.position,
      endPosition: endPosition ?? this.endPosition,
      selectedText: selectedText ?? this.selectedText,
      label: label ?? this.label,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
