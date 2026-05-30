/// 云端服务商数据，对应 cloud_models.json 中的单个 vendor 对象。
class CloudVendor {
  final String vendor;
  final String description;
  final List<String> supportedModes; // ["openai"] 或 ["openai", "anthropic"]
  final Map<String, String> baseUrls; // {openai: "...", anthropic: "..."}
  final String keyUrl; // 获取 API Key 的链接
  final List<String> models;

  const CloudVendor({
    required this.vendor,
    required this.description,
    required this.supportedModes,
    required this.baseUrls,
    this.keyUrl = '',
    this.models = const [],
  });

  /// 从远程 JSON 的单个 vendor 对象解析。
  ///
  /// JSON 格式示例：
  /// ```json
  /// {
  ///   "vendor": "小米 Token 版",
  ///   "description": "按量付费",
  ///   "supported_modes": ["openai"],
  ///   "base_urls": {"openai": "https://..."},
  ///   "key_url": "https://...",
  ///   "models": ["mimo-v2.5", "mimo-v2.5-pro"]
  /// }
  /// ```
  factory CloudVendor.fromJson(Map<String, dynamic> json) {
    final baseUrls = <String, String>{};
    if (json['base_urls'] is Map) {
      (json['base_urls'] as Map).forEach((key, value) {
        baseUrls[key.toString()] = value.toString();
      });
    }

    final supportedModes = <String>[];
    if (json['supported_modes'] is List) {
      supportedModes.addAll(
        (json['supported_modes'] as List).map((e) => e.toString()),
      );
    }

    final models = <String>[];
    if (json['models'] is List) {
      models.addAll(
        (json['models'] as List).map((e) => e.toString()),
      );
    }

    return CloudVendor(
      vendor: json['vendor'] as String? ?? '',
      description: json['description'] as String? ?? '',
      supportedModes: supportedModes,
      baseUrls: baseUrls,
      keyUrl: json['key_url'] as String? ?? '',
      models: models,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendor': vendor,
      'description': description,
      'supported_modes': supportedModes,
      'base_urls': baseUrls,
      'key_url': keyUrl,
      'models': models,
    };
  }
}
