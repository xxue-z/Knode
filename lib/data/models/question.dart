class Question {
  final int id;
  final String type;
  final String stem;
  final String? options;
  final String answer;
  final String? explanation;
  final String? sourceFileIds;
  final int difficulty;
  final String? tags;
  final String createdAt;

  const Question({
    required this.id,
    required this.type,
    required this.stem,
    this.options,
    required this.answer,
    this.explanation,
    this.sourceFileIds,
    required this.difficulty,
    this.tags,
    required this.createdAt,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] as int,
      type: map['type'] as String,
      stem: map['stem'] as String,
      options: map['options'] as String?,
      answer: map['answer'] as String,
      explanation: map['explanation'] as String?,
      sourceFileIds: map['sourceFileIds'] as String?,
      difficulty: map['difficulty'] as int,
      tags: map['tags'] as String?,
      createdAt: map['createdAt'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'stem': stem,
      'options': options,
      'answer': answer,
      'explanation': explanation,
      'sourceFileIds': sourceFileIds,
      'difficulty': difficulty,
      'tags': tags,
      'createdAt': createdAt,
    };
  }

  Question copyWith({
    int? id,
    String? type,
    String? stem,
    String? options,
    String? answer,
    String? explanation,
    String? sourceFileIds,
    int? difficulty,
    String? tags,
    String? createdAt,
  }) {
    return Question(
      id: id ?? this.id,
      type: type ?? this.type,
      stem: stem ?? this.stem,
      options: options ?? this.options,
      answer: answer ?? this.answer,
      explanation: explanation ?? this.explanation,
      sourceFileIds: sourceFileIds ?? this.sourceFileIds,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
