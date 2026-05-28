class WrongQuestionLog {
  final int id;
  final int questionId;
  final int wrongCount;
  final String? lastWrongAt;

  const WrongQuestionLog({
    required this.id,
    required this.questionId,
    required this.wrongCount,
    this.lastWrongAt,
  });

  factory WrongQuestionLog.fromMap(Map<String, dynamic> map) {
    return WrongQuestionLog(
      id: map['id'] as int,
      questionId: map['questionId'] as int,
      wrongCount: map['wrongCount'] as int,
      lastWrongAt: map['lastWrongAt'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionId': questionId,
      'wrongCount': wrongCount,
      'lastWrongAt': lastWrongAt,
    };
  }

  WrongQuestionLog copyWith({
    int? id,
    int? questionId,
    int? wrongCount,
    String? lastWrongAt,
  }) {
    return WrongQuestionLog(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      wrongCount: wrongCount ?? this.wrongCount,
      lastWrongAt: lastWrongAt ?? this.lastWrongAt,
    );
  }
}
