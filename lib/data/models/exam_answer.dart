class ExamAnswer {
  final int id;
  final int examId;
  final int questionId;
  final String? userAnswer;
  final int? isCorrect;
  final double? score;
  final String? aiFeedback;

  const ExamAnswer({
    required this.id,
    required this.examId,
    required this.questionId,
    this.userAnswer,
    this.isCorrect,
    this.score,
    this.aiFeedback,
  });

  factory ExamAnswer.fromMap(Map<String, dynamic> map) {
    return ExamAnswer(
      id: map['id'] as int,
      examId: map['examId'] as int,
      questionId: map['questionId'] as int,
      userAnswer: map['userAnswer'] as String?,
      isCorrect: map['isCorrect'] as int?,
      score: map['score'] as double?,
      aiFeedback: map['aiFeedback'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'examId': examId,
      'questionId': questionId,
      'userAnswer': userAnswer,
      'isCorrect': isCorrect,
      'score': score,
      'aiFeedback': aiFeedback,
    };
  }

  ExamAnswer copyWith({
    int? id,
    int? examId,
    int? questionId,
    String? userAnswer,
    int? isCorrect,
    double? score,
    String? aiFeedback,
  }) {
    return ExamAnswer(
      id: id ?? this.id,
      examId: examId ?? this.examId,
      questionId: questionId ?? this.questionId,
      userAnswer: userAnswer ?? this.userAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
      score: score ?? this.score,
      aiFeedback: aiFeedback ?? this.aiFeedback,
    );
  }
}
