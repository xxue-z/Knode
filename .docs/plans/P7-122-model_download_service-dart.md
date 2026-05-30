# P7-122 - model_download_service.dart（增强）

## 任务信息
- **文件路径**: `lib/services/model_download_service.dart`
- **文件职责**: 模型下载、SHA256 校验、导入本地模型
- **依赖文件**: local_model.dart
- **开发阶段**: P7 - 模型配置

## 任务上下文
在现有 ModelDownloadService 基础上增强，不重写。新增多镜像下载、SHA256 校验、导入本地模型。移除 hardcoded availableModels。

## 现有代码结构
```dart
class ModelInfo { name, url, sizeMB, description }
class DownloadProgress { percent, receivedBytes, totalBytes }
class ModelDownloadService {
  static const List<ModelInfo> availableModels = [...]; // 需移除
  Future<void> downloadModel(String url, String name)
  void cancelDownload()
  Future<void> deleteModel(String name)
  Future<List<String>> getDownloadedModels()
}
```

## 需要新增的功能

1. **移除** `static const List<ModelInfo> availableModels` 硬编码列表
2. **新增** `downloadWithMirror(LocalModel model, String mirrorKey)` 方法：
   - 使用临时文件名 `{model.id}.gguf.download` 下载
   - 下载完成后调用 verifySha256 校验
   - 校验通过：重命名为 `{model.id}.gguf`
   - 校验失败：删除临时文件，抛出异常
3. **新增** `verifySha256(String filePath, String expectedHash)` 方法：
   - 使用 `crypto` 包计算文件 SHA256
   - 与 expectedHash 比对
   - expectedHash 为空时跳过校验（导入的本地模型）
4. **新增** `importLocalModel(String sourcePath)` 方法：
   - 复制 .gguf 文件到 _modelsDir
   - 同名文件询问覆盖或重命名
   - 返回目标文件名

## 关键实现要点
- downloadModel 的现有逻辑保留，downloadWithMirror 是新增方法
- 下载进度 Stream 保持不变
- 使用 `dart:crypto` 或 `package:crypto` 做 SHA256

## 实现要求
- 不破坏现有接口
- 完整的异常处理
- 直接输出完整文件内容
