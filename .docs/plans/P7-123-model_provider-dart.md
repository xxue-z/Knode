# P7-123 - model_provider.dart

## 任务信息
- **文件路径**: `lib/providers/model_provider.dart`
- **文件职责**: Riverpod 状态管理，本地模型列表、下载、加载
- **依赖文件**: local_model.dart, model_repo_service.dart, model_download_service.dart, local_ai_provider.dart, settings_provider.dart
- **开发阶段**: P7 - 模型配置

## 任务上下文
统一管理本地模型的全生命周期状态：获取仓库 → 下载 → 校验 → 加载 → 删除。

## 需要实现的内容

### ModelListNotifier (AsyncNotifier<List<LocalModel>>)

- `fetchFromRepo(String url)` — 调用 ModelRepoService.fetchModels，更新列表
- `startDownload(LocalModel model, String mirrorKey)` — 调用 ModelDownloadService.downloadWithMirror，更新模型状态为 downloading → downloaded
- `cancelDownload()` — 调用 ModelDownloadService.cancelDownload
- `loadModel(LocalModel model)` — 调用 LocalAIProvider.loadModel，更新状态为 loaded，自动卸载上一个
- `deleteModel(LocalModel model)` — 删除文件，更新状态为 notDownloaded
- `importLocalModel(String filePath)` — 调用 ModelDownloadService.importLocalModel，添加到列表

### 辅助 Provider

- `modelRepoServiceProvider` — ModelRepoService 实例
- `modelDownloadServiceProvider` — ModelDownloadService 实例
- `localAiProviderRef` — LocalAIProvider 实例（需要在 main.dart 覆盖）

## 关键实现要点
- 下载进度通过 downloadProgress Stream 通知 UI
- loadModel 时先 unload 当前已加载模型（调用 dispose）
- 加载失败时更新状态为 loadFailed，记录 errorMessage
- 通过 settingsProvider 读写 local_model_id

## 实现要求
- 使用 Riverpod 2.x 语法
- 完整的异常处理（try-catch + 状态更新）
- 直接输出完整文件内容
