import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/models/question.dart';
import 'package:core/models/exam.dart';
import 'package:core/models/daily_task_config.dart';
import 'package:core/database/repositories/question_repository.dart';
import 'package:core/database/repositories/exam_repository.dart';
import 'package:core/database/dao/daily_task_dao.dart';

final questionRepositoryProvider = Provider<QuestionRepository>(
  (ref) => throw UnimplementedError('请在 main.dart 中覆盖'),
);

final examRepositoryProvider = Provider<ExamRepository>(
  (ref) => throw UnimplementedError('请在 main.dart 中覆盖'),
);

final dailyTaskDaoProvider = Provider<DailyTaskDao>(
  (ref) => throw UnimplementedError('请在 main.dart 中覆盖'),
);

// ── 答题状态 Provider（StateNotifier 适合同步内存状态） ─────────────

class QuizState {
  final List<Question> questions;
  final int currentIndex;
  final Map<int, String> answers;
  final bool isFinished;
  const QuizState({
    this.questions = const [],
    this.currentIndex = 0,
    this.answers = const {},
    this.isFinished = false,
  });
  QuizState copyWith({
    List<Question>? questions,
    int? currentIndex,
    Map<int, String>? answers,
    bool? isFinished,
  }) =>
      QuizState(
        questions: questions ?? this.questions,
        currentIndex: currentIndex ?? this.currentIndex,
        answers: answers ?? this.answers,
        isFinished: isFinished ?? this.isFinished,
      );
  Question? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;
  int get correctCount =>
      answers.entries.where((e) => questions[e.key].answer == e.value).length;
}

class QuizNotifier extends StateNotifier<QuizState> {
  final QuestionRepository _repo;
  QuizNotifier(this._repo) : super(const QuizState());

  Future<void> startQuiz({int count = 10, List<int>? questionIds}) async {
    final questions = questionIds != null
        ? await _repo.getByIds(questionIds)
        : await _repo.getRandom(limit: count);
    state = QuizState(questions: questions);
  }

  void answer(int questionIndex, String answer) {
    state = state.copyWith(
      answers: {...state.answers, questionIndex: answer},
    );
  }

  void next() {
    if (state.currentIndex < state.questions.length - 1) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    } else {
      state = state.copyWith(isFinished: true);
    }
  }

  void markWrong(int questionId) => _repo.markWrong(questionId);

  void reset() => state = const QuizState();
}

final quizProvider =
    StateNotifierProvider<QuizNotifier, QuizState>(
  (ref) => QuizNotifier(ref.read(questionRepositoryProvider)),
);

// ── 每日一测配置 Provider（AsyncNotifier 适合 DB 异步操作） ────────

class DailyConfigNotifier extends AsyncNotifier<DailyTaskConfig?> {
  @override
  Future<DailyTaskConfig?> build() async {
    return ref.read(dailyTaskDaoProvider).getConfig();
  }

  Future<void> save(DailyTaskConfig config) async {
    await ref.read(dailyTaskDaoProvider).saveConfig(config);
    ref.invalidateSelf();
  }
}

final dailyConfigProvider =
    AsyncNotifierProvider<DailyConfigNotifier, DailyTaskConfig?>(
  DailyConfigNotifier.new,
);

// ── 最近考试列表 Provider ─────────────────────────────────────────

class RecentExamsNotifier extends AsyncNotifier<List<Exam>> {
  @override
  Future<List<Exam>> build() async {
    return ref.read(examRepositoryProvider).getAll(limit: 10);
  }

  Future<void> refresh() async => ref.invalidateSelf();
}

final recentExamsProvider =
    AsyncNotifierProvider<RecentExamsNotifier, List<Exam>>(
  RecentExamsNotifier.new,
);
