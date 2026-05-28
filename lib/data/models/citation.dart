class Citation {
  final int docId;
  final String title;
  final String snippet;

  const Citation({
    required this.docId,
    required this.title,
    required this.snippet,
  });

  factory Citation.fromMap(Map<String, dynamic> map) {
    return Citation(
      docId: map['docId'] as int,
      title: map['title'] as String,
      snippet: map['snippet'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'docId': docId,
      'title': title,
      'snippet': snippet,
    };
  }

  Citation copyWith({
    int? docId,
    String? title,
    String? snippet,
  }) {
    return Citation(
      docId: docId ?? this.docId,
      title: title ?? this.title,
      snippet: snippet ?? this.snippet,
    );
  }
}
