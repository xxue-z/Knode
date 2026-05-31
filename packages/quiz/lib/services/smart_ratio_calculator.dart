/// 智能比例计算器：根据阅读时长和错题数计算 AI/题库比例。
///
/// 算法逻辑：
/// - 阅读时长高且错题少 → AI 比例提高（探索新知识）
/// - 错题多 → AI 比例降低（优先巩固）
/// - 默认基准 AI 比例 0.3（30%）
class SmartRatioCalculator {
  /// 计算 AI 出题比例。
  ///
  /// [totalReadingMinutes] 最近 N 天的总阅读时长（分钟）。
  /// [wrongCount] 当前错题本中的题目数量。
  /// [totalQuestionCount] 题库总题目数。
  ///
  /// 返回 0.0 ~ 0.6 之间的 AI 出题比例。
  static double calculate({
    required int totalReadingMinutes,
    required int wrongCount,
    required int totalQuestionCount,
  }) {
    // 基准比例
    double ratio = 0.3;

    // 阅读时长因子：阅读越多，AI 比例越高（最高 +0.2）
    if (totalReadingMinutes > 300) {
      ratio += 0.2;
    } else if (totalReadingMinutes > 120) {
      ratio += 0.1;
    } else if (totalReadingMinutes > 30) {
      ratio += 0.05;
    }

    // 错题因子：错题越多，AI 比例越低（最低 -0.3）
    if (totalQuestionCount > 0) {
      final wrongRatio = wrongCount / totalQuestionCount;
      if (wrongRatio > 0.3) {
        ratio -= 0.3;
      } else if (wrongRatio > 0.15) {
        ratio -= 0.15;
      } else if (wrongRatio > 0.05) {
        ratio -= 0.05;
      }
    }

    // 题库不足时提高 AI 比例
    if (totalQuestionCount < 20) {
      ratio += 0.2;
    } else if (totalQuestionCount < 50) {
      ratio += 0.1;
    }

    // 限制在 [0.0, 0.6] 范围内
    return ratio.clamp(0.0, 0.6);
  }
}
