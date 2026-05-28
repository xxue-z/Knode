class DailyTaskConfig {
  final int id;
  final int isEnabled;
  final String scopeType;
  final String? scopeValue;
  final int questionCount;
  final String? reminderTime;
  final String? reminderMethods;
  final String createdAt;
  final String updatedAt;

  const DailyTaskConfig({
    required this.id,
    required this.isEnabled,
    required this.scopeType,
    this.scopeValue,
    required this.questionCount,
    this.reminderTime,
    this.reminderMethods,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DailyTaskConfig.fromMap(Map<String, dynamic> map) {
    return DailyTaskConfig(
      id: map['id'] as int,
      isEnabled: map['isEnabled'] as int,
      scopeType: map['scopeType'] as String,
      scopeValue: map['scopeValue'] as String?,
      questionCount: map['questionCount'] as int,
      reminderTime: map['reminderTime'] as String?,
      reminderMethods: map['reminderMethods'] as String?,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isEnabled': isEnabled,
      'scopeType': scopeType,
      'scopeValue': scopeValue,
      'questionCount': questionCount,
      'reminderTime': reminderTime,
      'reminderMethods': reminderMethods,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  DailyTaskConfig copyWith({
    int? id,
    int? isEnabled,
    String? scopeType,
    String? scopeValue,
    int? questionCount,
    String? reminderTime,
    String? reminderMethods,
    String? createdAt,
    String? updatedAt,
  }) {
    return DailyTaskConfig(
      id: id ?? this.id,
      isEnabled: isEnabled ?? this.isEnabled,
      scopeType: scopeType ?? this.scopeType,
      scopeValue: scopeValue ?? this.scopeValue,
      questionCount: questionCount ?? this.questionCount,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderMethods: reminderMethods ?? this.reminderMethods,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
