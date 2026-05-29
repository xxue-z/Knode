import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/exam.dart';
import '../data/models/exam_answer.dart';
import '../data/models/question.dart';
import '../data/repositories/exam_repository.dart';

final examRepositoryProvider = Provider<ExamRepository>(
  (ref) => throw UnimplementedError('请在 main.dart 中覆盖'),
);

// ── 考试列表 Provider ──────────────────────────────────────────────

class ExamListNotifier extends AsyncNotifier<List<Exam>> {
  @override
  Future<List<Exam>> build() async =>
      ref.read(examRepositoryProvider).getAll();

  Future<Exam> createExam({
    required String examType,
    required int questionCount,
    String? title,
  }) async {
    final exam = Exam(
      id: 0,
      title: title,
      examType: examType,
      questionCount: questionCount,
      status: 'in_progress',
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    final id = await ref.read(examRepositoryProvider).createExam(exam);
    ref.invalidateSelf();
    return exam.copyWith(id: id);
  }
}

final examListProvider =
    AsyncNotifierProvider<ExamListNotifier, List<Exam>>(ExamListNotifier.new);

// ── 答题状态 Provider ──────────────────────────────────────────────

/// 答题进行中状态，管理当前题目索引、用户答案、计时、交卷逻辑。
class ExamSessionState {
  final Exam? exam;
  final List<Question> questions;
  final int currentIndex;
  final Map<int, String> answers; // questionId -> userAnswer
  final int remainingSeconds;
  final bool isFinished;
  final ExamResult? result;

  const ExamSessionState({
    this.exam,
    this.questions = const [],
    this.currentIndex = 0,
    this.answers = const {},
    this.remainingSeconds = 0,
    this.isFinished = false,
    this.result,
  });

  ExamSessionState copyWith({
    Exam? exam,
    List<Question>? questions,
    int? currentIndex,
    Map<int, String>? answers,
    int? remainingSeconds,
    bool? isFinished,
    ExamResult? result,
  }) =>
      ExamSessionState(
        exam: exam ?? this.exam,
        questions: questions ?? this.questions,
        currentIndex: currentIndex ?? this.currentIndex,
        answers: answers ?? this.answers,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        isFinished: isFinished ?? this.isFinished,
        result: result ?? this.result,
      );

  Question? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  int get answeredCount => answers.length;

  double get progress =>
      questions.isEmpty ? 0 : answeredCount / questions.length;
}

class ExamSessionNotifier extends StateNotifier<ExamSessionState> {
  final ExamRepository _repo;
  ExamSessionNotifier(this._repo) : super(const ExamSessionState());

  /// 开始考试，加载题目并初始化计时。
  Future<void> startExam(Exam exam, List<Question> questions) async {
    state = ExamSessionState(
      exam: exam,
      questions: questions,
      remainingSeconds: exam.timeLimit ?? questions.length * 60,
    );
  }

  /// 提交当前题目的答案。
  Future<void> submitAnswer(String userAnswer) async {
    final question = state.currentQuestion;
    if (question == null || state.exam == null) return;

    await _repo.submitAnswer(state.exam!.id, question.id, userAnswer);
    state = state.copyWith(
      answers: {...state.answers, question.id: userAnswer},
    );
  }

  /// 跳转到下一题。
  void next() {
    if (state.currentIndex < state.questions.length - 1) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  /// 跳转到上一题。
  void previous() {
    if (state.currentIndex > 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  /// 跳转到指定题目。
  void goTo(int index) {
    if (index >= 0 && index < state.questions.length) {
      state = state.copyWith(currentIndex: index);
    }
  }

  /// 每秒递减计时。
  void tick() {
    if (state.remainingSeconds > 0 && !state.isFinished) {
      state = state.copyWith(
        remainingSeconds: state.remainingSeconds - 1,
      );
    }
  }

  /// 交卷，完成考试。
  Future<void> finishExam() async {
    if (state.exam == null || state.isFinished) return;
    final result = await _repo.finishExam(state.exam!.id);
    state = state.copyWith(isFinished: true, result: result);
  }

  /// 重置状态。
  void reset() {
    state = const ExamSessionState();
  }
}

final examSessionProvider =
    StateNotifierProvider<ExamSessionNotifier, ExamSessionState>(
  (ref) => ExamSessionNotifier(ref.read(examRepositoryProvider)),
);
