/// 知维核心包 - 数据模型、数据库、AI 抽象层
///
/// 此文件将作为 barrel export，导出 core 包的所有公共 API。
library core;

// Data layer
export 'database/database.dart';
export 'models/models.dart';

// TODO: 在文件迁移完成后，添加以下导出
// export 'ai/ai_provider.dart';
// export 'services/services.dart';
// export 'providers/providers.dart';

export 'constants/app_constants.dart';
export 'constants/db_constants.dart';
export 'extensions/string_extensions.dart';
export 'utils/date_utils.dart';
export 'utils/device_utils.dart';
export 'utils/file_utils.dart';
export 'utils/hash_utils.dart';
export 'utils/json_utils.dart';
export 'tokenizer/tokenizer.dart';
export 'tokenizer/ngram_tokenizer.dart';
export 'tokenizer/stop_words.dart';
export 'theme/app_theme.dart';
export 'theme/text_styles.dart';
