import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 阅读统计数据。
class ReadingStats {
  final int totalMinutes;
  final int totalDocuments;
  final int totalReadCount;
  final List<DocumentStat> topRead;
  final List<DocumentStat> bottomRead;

  const ReadingStats({
    required this.totalMinutes,
    required this.totalDocuments,
    required this.totalReadCount,
    required this.topRead,
    required this.bottomRead,
  });
}

/// 单篇文档阅读统计。
class DocumentStat {
  final int docId;
  final String title;
  final int readCount;
  final int durationSeconds;

  const DocumentStat({
    required this.docId,
    required this.title,
    required this.readCount,
    required this.durationSeconds,
  });
}

/// 测验统计数据。
class QuizStats {
  final int totalQuestions;
  final int totalExams;
  final int wrongQuestions;
  final double averageScore;

  const QuizStats({
    required this.totalQuestions,
    required this.totalExams,
    required this.wrongQuestions,
    required this.averageScore,
  });
}

/// 个人中心统计数据。
class PersonalStats {
  final ReadingStats reading;
  final QuizStats quiz;

  const PersonalStats({required this.reading, required this.quiz});
}

/// 个人中心统计数据 Provider。
///
/// 聚合阅读和测验数据，供个人中心页面展示。
class StatsNotifier extends AsyncNotifier<PersonalStats> {
  @override
  Future<PersonalStats> build() async {
    final readingStats = await _getReadingStats();
    final quizStats = await _getQuizStats();
    return PersonalStats(reading: readingStats, quiz: quizStats);
  }

  Future<ReadingStats> _getReadingStats() async {
    // TODO: 实现阅读统计查询
    return const ReadingStats(
      totalMinutes: 0,
      totalDocuments: 0,
      totalReadCount: 0,
      topRead: [],
      bottomRead: [],
    );
  }

  Future<QuizStats> _getQuizStats() async {
    // TODO: 实现测验统计查询
    return const QuizStats(
      totalQuestions: 0,
      totalExams: 0,
      wrongQuestions: 0,
      averageScore: 0.0,
    );
  }
}

final statsProvider = AsyncNotifierProvider<StatsNotifier, PersonalStats>(
  StatsNotifier.new,
);
