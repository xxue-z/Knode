class Citation {
  final int docId;
  final String title;
  final String snippet;
  final String sourceType;  // 'local' or 'web'

  const Citation({
    required this.docId,
    required this.title,
    required this.snippet,
    this.sourceType = 'local',
  });

  factory Citation.fromMap(Map<String, dynamic> map) {
    return Citation(
      docId: map['docId'] as int,
      title: map['title'] as String,
      snippet: map['snippet'] as String,
      sourceType: map['sourceType'] as String? ?? 'local',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'docId': docId,
      'title': title,
      'snippet': snippet,
      'sourceType': sourceType,
    };
  }

  Citation copyWith({
    int? docId,
    String? title,
    String? snippet,
    String? sourceType,
  }) {
    return Citation(
      docId: docId ?? this.docId,
      title: title ?? this.title,
      snippet: snippet ?? this.snippet,
      sourceType: sourceType ?? this.sourceType,
    );
  }
}
