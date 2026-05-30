class Message {
  final int id;
  final int conversationId;
  final String role;
  final String content;
  final String contentType;
  final String? mediaPath;
  final String? citations;
  final String createdAt;

  const Message({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.contentType,
    this.mediaPath,
    this.citations,
    required this.createdAt,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as int,
      conversationId: map['conversationId'] as int,
      role: map['role'] as String,
      content: map['content'] as String,
      contentType: map['contentType'] as String,
      mediaPath: map['mediaPath'] as String?,
      citations: map['citations'] as String?,
      createdAt: map['createdAt'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'role': role,
      'content': content,
      'contentType': contentType,
      'mediaPath': mediaPath,
      'citations': citations,
      'createdAt': createdAt,
    };
  }

  Message copyWith({
    int? id,
    int? conversationId,
    String? role,
    String? content,
    String? contentType,
    String? mediaPath,
    String? citations,
    String? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      contentType: contentType ?? this.contentType,
      mediaPath: mediaPath ?? this.mediaPath,
      citations: citations ?? this.citations,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
