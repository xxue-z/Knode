# P7-120 - model_repo_service.dart

## 任务信息
- **文件路径**: `lib/services/model_repo_service.dart`
- **文件职责**: 远程模型仓库 JSON 拉取与本地缓存
- **依赖文件**: local_model.dart
- **开发阶段**: P7 - 模型配置

## 任务上下文
从远程 URL 拉取模型列表 JSON，解析为 LocalModel 列表，支持本地缓存和失败回退。

## 需要实现的内容

- `ModelRepoService` 类：
  - `Future<List<LocalModel>> fetchModels(String url)` — 拉取远程 JSON
  - `Future<List<LocalModel>> getCachedModels()` — 读取本地缓存
  - 内部：Dio HTTP 客户端，**自动重试 3 次**（指数退避 2/4/8 秒）
  - 内部：缓存文件读写（models_cache.json）

## 关键实现要点
- 使用 `path_provider` 获取应用文档目录
- 缓存路径：`{appDocDir}/models_cache.json`
- fetchModels 成功后覆盖缓存；失败时尝试读取缓存，缓存也为空则抛异常
- JSON 格式异常时抛出明确错误信息
- 重试机制：捕获 DioException，非取消类错误自动重试，最多 3 次

## 实现要求
- 完整的 import 语句
- 使用 dio 发 HTTP 请求
- 必要的异常处理
- 直接输出完整文件内容
