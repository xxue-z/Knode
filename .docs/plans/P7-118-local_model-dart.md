# P7-118 - local_model.dart

## 任务信息
- **文件路径**: `lib/data/models/local_model.dart`
- **文件职责**: 本地模型元数据模型
- **依赖文件**: 无
- **开发阶段**: P7 - 模型配置

## 任务上下文
定义本地模型的数据结构，包括模型状态枚举、远程仓库 JSON 字段映射。

## 需要实现的内容

- `ModelStatus` 枚举：notDownloaded, downloading, downloaded, loaded, loadFailed
- `LocalModel` 类：
  - id, name, size, minRam, description, quantization
  - downloadUrls (Map<String, String>)
  - sha256
  - status, downloadProgress, errorMessage
  - copyWith 方法
  - fromJson 工厂方法（解析远程 JSON）
  - toJson 方法

## 关键实现要点
- downloadUrls 示例：`{"global": "https://...", "china_mirror": "https://..."}`
- size 格式："0.6 GB"，minRam 格式："2 GB"
- fromJson 解析 models.json 中的单个 model 对象

## 实现要求
- 完整的 import 语句
- 遵循 Flutter/Dart 最佳实践
- 直接输出完整文件内容
