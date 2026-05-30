/// 知维核心包 - 数据模型、数据库、AI 抽象层
///
/// 此文件将作为 barrel export，导出 core 包的所有公共 API。
library core;

// ── AI 抽象层 ──────────────────────────────────────────────────────
export 'ai/ai_provider.dart';
export 'ai/ai_provider_factory.dart';
export 'ai/cloud_ai_provider.dart';
export 'ai/embedding_service.dart';
export 'ai/local_ai_provider.dart';
export 'ai/prompt_manager.dart';

// ── 常量 ────────────────────────────────────────────────────────────
export 'constants/app_constants.dart';
export 'constants/db_constants.dart';

// ── 数据库 ──────────────────────────────────────────────────────────
export 'database/database.dart' hide GradeResult;

// ── 扩展 ────────────────────────────────────────────────────────────
export 'extensions/string_extensions.dart';

// ── 数据模型 ────────────────────────────────────────────────────────
export 'models/models.dart';

// ── Provider 状态管理 ───────────────────────────────────────────────
export 'providers/database_provider.dart';
export 'providers/model_provider.dart';
export 'providers/service_providers.dart' hide localAiProviderRef;
export 'providers/settings_provider.dart';
export 'providers/stats_provider.dart';

// ── 业务服务 ────────────────────────────────────────────────────────
export 'services/backup_service.dart';
export 'services/background_service.dart';
export 'services/cloud_vendor_service.dart';
export 'services/embedding_fallback_service.dart';
export 'services/external_app_launcher.dart';
export 'services/file_service.dart';
export 'services/hybrid_search_service.dart';
export 'services/model_download_service.dart';
export 'services/model_repo_service.dart';
export 'services/notification_service.dart';
export 'services/prompt_remote_sync_service.dart';
export 'services/rag_service.dart';
export 'services/speech_service.dart';
export 'services/text_chunker.dart';
export 'services/tfidf_search_service.dart';
export 'services/tfidf_service.dart';
export 'services/tts_service.dart';
export 'services/vector_store_service.dart';

// ── 分词器 ──────────────────────────────────────────────────────────
export 'tokenizer/ngram_tokenizer.dart';
export 'tokenizer/stop_words.dart';
export 'tokenizer/tokenizer.dart';

// ── 主题 ────────────────────────────────────────────────────────────
export 'theme/app_theme.dart';
export 'theme/text_styles.dart';

// ── 工具类 ──────────────────────────────────────────────────────────
export 'utils/date_utils.dart';
export 'utils/device_utils.dart';
export 'utils/file_utils.dart';
export 'utils/hash_utils.dart';
export 'utils/json_utils.dart';
