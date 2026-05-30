/// 模型下载/加载状态。
enum ModelStatus {
  notDownloaded,
  downloading,
  downloaded,
  loaded,
  loadFailed,
}

/// 本地模型元数据，对应远程仓库 JSON 中的单个 model 对象。
class LocalModel {
  final String id;
  final String name;
  final String size; // "0.6 GB"
  final String minRam; // "2 GB"
  final String description;
  final String quantization; // "Q4_K_M"
  final Map<String, String> downloadUrls; // {global: "...", china_mirror: "..."}
  final String sha256;
  final ModelStatus status;
  final double downloadProgress; // 0.0 ~ 1.0
  final String? errorMessage;

  const LocalModel({
    required this.id,
    required this.name,
    required this.size,
    required this.minRam,
    required this.description,
    required this.quantization,
    required this.downloadUrls,
    this.sha256 = '',
    this.status = ModelStatus.notDownloaded,
    this.downloadProgress = 0.0,
    this.errorMessage,
  });

  LocalModel copyWith({
    String? id,
    String? name,
    String? size,
    String? minRam,
    String? description,
    String? quantization,
    Map<String, String>? downloadUrls,
    String? sha256,
    ModelStatus? status,
    double? downloadProgress,
    String? errorMessage,
  }) {
    return LocalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      size: size ?? this.size,
      minRam: minRam ?? this.minRam,
      description: description ?? this.description,
      quantization: quantization ?? this.quantization,
      downloadUrls: downloadUrls ?? this.downloadUrls,
      sha256: sha256 ?? this.sha256,
      status: status ?? this.status,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// 从远程 JSON 的单个 model 对象解析。
  ///
  /// JSON 格式示例：
  /// ```json
  /// {
  ///   "id": "llama-3.2-1b",
  ///   "name": "Llama-3.2-1B-Instruct",
  ///   "size": "0.6 GB",
  ///   "min_ram": "2 GB",
  ///   "description": "超轻量，响应快",
  ///   "quantization": "Q4_K_M",
  ///   "download_urls": {"global": "...", "china_mirror": "..."},
  ///   "sha256": "e3b0c44..."
  /// }
  /// ```
  factory LocalModel.fromJson(Map<String, dynamic> json) {
    final downloadUrls = <String, String>{};
    if (json['download_urls'] is Map) {
      (json['download_urls'] as Map).forEach((key, value) {
        downloadUrls[key.toString()] = value.toString();
      });
    }

    return LocalModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      size: json['size'] as String? ?? '',
      minRam: json['min_ram'] as String? ?? '',
      description: json['description'] as String? ?? '',
      quantization: json['quantization'] as String? ?? '',
      downloadUrls: downloadUrls,
      sha256: json['sha256'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'size': size,
      'min_ram': minRam,
      'description': description,
      'quantization': quantization,
      'download_urls': downloadUrls,
      'sha256': sha256,
    };
  }
}
