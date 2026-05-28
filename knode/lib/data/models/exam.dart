class Exam {
  final int id;
  final String examType;
  final String? title;
  final int? questionCount;
  final double? totalScore;
  final double? obtainedScore;
  final int? timeLimit;
  final String? startedAt;
  final String? finishedAt;
  final String status;
  final String? configJson;

  const Exam({
    required this.id,
    required this.examType,
    this.title,
    this.questionCount,
    this.totalScore,
    this.obtainedScore,
    this.timeLimit,
    this.startedAt,
    this.finishedAt,
    required this.status,
    this.configJson,
  });

  factory Exam.fromMap(Map<String, dynamic> map) {
    return Exam(
      id: map['id'] as int,
      examType: map['examType'] as String,
      title: map['title'] as String?,
      questionCount: map['questionCount'] as int?,
      totalScore: map['totalScore'] as double?,
      obtainedScore: map['obtainedScore'] as double?,
      timeLimit: map['timeLimit'] as int?,
      startedAt: map['startedAt'] as String?,
      finishedAt: map['finishedAt'] as String?,
      status: map['status'] as String,
      configJson: map['configJson'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'examType': examType,
      'title': title,
      'questionCount': questionCount,
      'totalScore': totalScore,
      'obtainedScore': obtainedScore,
      'timeLimit': timeLimit,
      'startedAt': startedAt,
      'finishedAt': finishedAt,
      'status': status,
      'configJson': configJson,
    };
  }

  Exam copyWith({
    int? id,
    String? examType,
    String? title,
    int? questionCount,
    double? totalScore,
    double? obtainedScore,
    int? timeLimit,
    String? startedAt,
    String? finishedAt,
    String? status,
    String? configJson,
  }) {
    return Exam(
      id: id ?? this.id,
      examType: examType ?? this.examType,
      title: title ?? this.title,
      questionCount: questionCount ?? this.questionCount,
      totalScore: totalScore ?? this.totalScore,
      obtainedScore: obtainedScore ?? this.obtainedScore,
      timeLimit: timeLimit ?? this.timeLimit,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      status: status ?? this.status,
      configJson: configJson ?? this.configJson,
    );
  }
}
