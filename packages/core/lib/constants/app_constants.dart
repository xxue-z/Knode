/// 全局应用常量。
class AppConstants {
  AppConstants._();

  // ── 服务器 ──────────────────────────────────────────────────────

  /// 微服务默认端口。
  static const int defaultPort = 8080;

  /// 服务器绑定地址。
  static const String defaultHost = '0.0.0.0';

  // ── 文件路径 ─────────────────────────────────────────────────────

  /// Wiki 根目录名称。
  static const String wikiRootDir = 'wiki_root';

  /// 模型存储目录名称。
  static const String modelsDir = 'models';

  /// WebDAV 备份目录名称。
  static const String backupDir = 'knode_backup';

  // ── 数据库 ──────────────────────────────────────────────────────

  /// 数据库文件名。
  static const String dbName = 'knode.db';

  /// 数据库版本号。
  static const int dbVersion = 1;

  // ── AI 配置 ─────────────────────────────────────────────────────

  /// 默认 AI 提供商类型。
  static const String defaultAiType = 'cloud';

  /// 默认模型仓库 URL。
  static const String defaultModelRepoUrl =
      'https://cdn.jsdelivr.net/gh/xxue-z/Knode@master/.resource/models.json';

  /// 默认云端厂商仓库 URL。
  static const String defaultCloudVendorRepoUrl =
      'https://cdn.jsdelivr.net/gh/xxue-z/Knode@master/.resource/cloud_vendors.json';

  // ── 测验 ────────────────────────────────────────────────────────

  /// 每日一测默认题目数量。
  static const int defaultDailyQuestionCount = 10;

  /// 随机速记默认题目数量。
  static const int defaultRandomQuestionCount = 5;

  /// 温故知新默认错题比例。
  static const double defaultWrongRatio = 0.5;
}
