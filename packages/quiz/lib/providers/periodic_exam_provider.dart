import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/models/exam.dart';
import 'package:core/gen/strings.dart';
import 'package:quiz/services/periodic_exam_service.dart';

const _strings = L10nStringsMixin();

final periodicExamServiceProvider = Provider<PeriodicExamService>(
  (ref) => throw UnimplementedError(_strings.core_please_override_in_main_dart),
);

/// 阶段考试历史列表 Provider。
class PeriodicExamHistoryNotifier extends AsyncNotifier<List<Exam>> {
  String _examType = 'monthly';

  @override
  Future<List<Exam>> build() async {
    final service = ref.read(periodicExamServiceProvider);
    return service.getExamHistory(_examType);
  }

  Future<void> loadHistory(String examType) async {
    _examType = examType;
    ref.invalidateSelf();
  }
}

final periodicExamHistoryProvider =
    AsyncNotifierProvider<PeriodicExamHistoryNotifier, List<Exam>>(
  PeriodicExamHistoryNotifier.new,
);
