/// 知维 Quiz 包 - 题库、测验、阅卷
///
/// 此文件将作为 barrel export，导出 quiz 包的所有公共 API。
library quiz;

// ── Agent ────────────────────────────────────────────────────────────
export 'agents/grader_agent.dart';
export 'agents/quiz_agent.dart';

// ── Provider 状态管理 ───────────────────────────────────────────────
export 'providers/exam_provider.dart' hide examRepositoryProvider;
export 'providers/quiz_provider.dart';

// ── 业务服务 ────────────────────────────────────────────────────────
export 'services/periodic_exam_service.dart';

// ── 页面 ────────────────────────────────────────────────────────────
export 'screens/quiz_page.dart';
export 'screens/daily_config_page.dart';
export 'screens/exam_page.dart';
export 'screens/question_card.dart';
export 'screens/result_page.dart';
export 'screens/timer_widget.dart';
export 'screens/wrong_list.dart';
export 'screens/wrong_detail.dart';
// ── 配置页面 ──
export 'screens/quiz_config_page.dart';
export 'screens/periodic_exam_history_page.dart';

// ── 服务 ──
export 'services/question_mixer.dart';
export 'services/smart_ratio_calculator.dart';

// ── Provider ──
export 'providers/periodic_exam_provider.dart';

