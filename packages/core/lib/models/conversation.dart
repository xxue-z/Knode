class Conversation {
  final int id;
  final String? title;
  final String status;
  final int? wikiFileId;
  final String createdAt;
  final String updatedAt;

  const Conversation({
    required this.id,
    this.title,
    required this.status,
    this.wikiFileId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'] as int,
      title: map['title'] as String?,
      status: map['status'] as String,
      wikiFileId: map['wikiFileId'] as int?,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'status': status,
      'wikiFileId': wikiFileId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Conversation copyWith({
    int? id,
    String? title,
    String? status,
    int? wikiFileId,
    String? createdAt,
    String? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      wikiFileId: wikiFileId ?? this.wikiFileId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
