import 'package:core/models/question.dart';
import 'package:core/database/dao/question_dao.dart';
import 'package:quiz/services/smart_ratio_calculator.dart';

/// 出题混合器：按比例组合 AI 出题 + 题库抽取 + 变种出题。
///
/// [aiGenerateFn] 由外部注入，负责 AI 生成题目。
/// [variantFn] 由外部注入，负责基于已有题目生成变种。
class QuestionMixer {
  final QuestionDao _questionDao;

  /// AI 生成函数：传入文档内容列表，返回生成的题目。
  final Future<List<Question>> Function(List<String> contents)? aiGenerateFn;

  /// 变种生成函数：传入原始题目列表，返回变种题目。
  final Future<List<Question>> Function(List<Question> originals)? variantFn;

  QuestionMixer({
    required QuestionDao questionDao,
    this.aiGenerateFn,
    this.variantFn,
  }) : _questionDao = questionDao;

  /// 按指定范围和比例混合题目。
  ///
  /// [docIds] 关联的文档 ID 列表（用于题库抽取范围）。
  /// [totalCount] 总题目数。
  /// [aiRatio] AI 出题比例（0.0~1.0），为 null 时使用智能比例。
  /// [wrongCount] 错题数量（用于智能比例计算）。
  /// [totalQuestionCount] 题库总题目数（用于智能比例计算）。
  /// [totalReadingMinutes] 阅读时长（用于智能比例计算）。
  /// [enableVariant] 是否启用变种出题。
  Future<List<Question>> mix({
    required List<int> docIds,
    required int totalCount,
    double? aiRatio,
    int wrongCount = 0,
    int totalQuestionCount = 0,
    int totalReadingMinutes = 0,
    bool enableVariant = false,
  }) async {
    // 计算 AI 比例
    final effectiveAiRatio = aiRatio ?? SmartRatioCalculator.calculate(
      totalReadingMinutes: totalReadingMinutes,
      wrongCount: wrongCount,
      totalQuestionCount: totalQuestionCount,
    );

    final aiCount = (totalCount * effectiveAiRatio).round();
    final variantCount = enableVariant ? (totalCount * 0.15).round() : 0;
    final bankCount = totalCount - aiCount - variantCount;

    // 从题库抽取
    List<Question> bankQuestions;
    if (docIds.isNotEmpty) {
      bankQuestions = await _questionDao.getByDocIds(docIds);
      if (bankQuestions.length < bankCount) {
        // 不足时补充随机题目
        final extra = await _questionDao.getRandom(limit: bankCount - bankQuestions.length);
        bankQuestions = [...bankQuestions, ...extra];
      }
      bankQuestions = bankQuestions.take(bankCount).toList()..shuffle();
    } else {
      bankQuestions = await _questionDao.getRandom(limit: bankCount);
    }

    // AI 生成
    List<Question> aiQuestions = [];
    if (aiCount > 0 && aiGenerateFn != null) {
      try {
        aiQuestions = await aiGenerateFn!([]);
      } catch (_) {
        // AI 失败时降级为题库抽取
        final extra = await _questionDao.getRandom(limit: aiCount);
        bankQuestions = [...bankQuestions, ...extra];
      }
    }

    // 变种出题
    List<Question> variantQuestions = [];
    if (variantCount > 0 && variantFn != null && bankQuestions.isNotEmpty) {
      try {
        variantQuestions = await variantFn!(bankQuestions.take(5).toList());
        variantQuestions = variantQuestions.take(variantCount).toList();
      } catch (_) {
        // 变种失败时降级
      }
    }

    // 合并并去重
    final allQuestions = [...bankQuestions, ...aiQuestions, ...variantQuestions];
    final seen = <String>{};
    final result = <Question>[];
    for (final q in allQuestions) {
      final key = q.stem.hashCode.toString();
      if (!seen.contains(key)) {
        seen.add(key);
        result.add(q);
      }
    }

    return result.take(totalCount).toList()..shuffle();
  }
}
