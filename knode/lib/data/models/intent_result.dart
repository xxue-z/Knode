class IntentResult {
  final String type;
  final String? suggestedCategory;
  final List<String> keywords;

  const IntentResult({
    required this.type,
    this.suggestedCategory,
    required this.keywords,
  });

  factory IntentResult.fromMap(Map<String, dynamic> map) {
    return IntentResult(
      type: map['type'] as String,
      suggestedCategory: map['suggestedCategory'] as String?,
      keywords: List<String>.from(map['keywords'] as List),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'suggestedCategory': suggestedCategory,
      'keywords': keywords,
    };
  }

  IntentResult copyWith({
    String? type,
    String? suggestedCategory,
    List<String>? keywords,
  }) {
    return IntentResult(
      type: type ?? this.type,
      suggestedCategory: suggestedCategory ?? this.suggestedCategory,
      keywords: keywords ?? this.keywords,
    );
  }
}
