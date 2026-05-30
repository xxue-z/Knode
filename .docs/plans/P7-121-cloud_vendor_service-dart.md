# P7-121 - cloud_vendor_service.dart

## 任务信息
- **文件路径**: `lib/services/cloud_vendor_service.dart`
- **文件职责**: 云端厂商 JSON 拉取与本地缓存
- **依赖文件**: cloud_vendor.dart
- **开发阶段**: P7 - 模型配置

## 任务上下文
与 ModelRepoService 对称，从远程 URL 拉取云端厂商配置 JSON，支持缓存。

## 需要实现的内容

- `CloudVendorService` 类：
  - `Future<List<CloudVendor>> fetchVendors(String url)` — 拉取远程 JSON
  - `Future<List<CloudVendor>> getCachedVendors()` — 读取本地缓存
  - 内部：Dio HTTP 客户端，**自动重试 3 次**（指数退避 2/4/8 秒）
  - 内部：缓存文件读写（cloud_models_cache.json）

## 关键实现要点
- 缓存路径：`{appDocDir}/cloud_models_cache.json`
- JSON 格式示例见设计方案 §4.1
- fetchVendors 成功后覆盖缓存；失败时尝试读取缓存

## 实现要求
- 完整的 import 语句
- 使用 dio 发 HTTP 请求
- 必要的异常处理
- 直接输出完整文件内容
