class ReadingLog {
  final int id;
  final int docId;
  final String? startTime;
  final String? endTime;
  final int? durationSeconds;

  const ReadingLog({
    required this.id,
    required this.docId,
    this.startTime,
    this.endTime,
    this.durationSeconds,
  });

  factory ReadingLog.fromMap(Map<String, dynamic> map) {
    return ReadingLog(
      id: map['id'] as int,
      docId: map['docId'] as int,
      startTime: map['startTime'] as String?,
      endTime: map['endTime'] as String?,
      durationSeconds: map['durationSeconds'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'docId': docId,
      'startTime': startTime,
      'endTime': endTime,
      'durationSeconds': durationSeconds,
    };
  }

  ReadingLog copyWith({
    int? id,
    int? docId,
    String? startTime,
    String? endTime,
    int? durationSeconds,
  }) {
    return ReadingLog(
      id: id ?? this.id,
      docId: docId ?? this.docId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }
}
