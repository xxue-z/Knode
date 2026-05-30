# AI 模型配置模块设计方案

## 1. 概述

在「设置 → AI 引擎」中提供统一的 AI 模型管理入口，支持：
- **本地模型**：远程 JSON 获取模型列表、断点续传下载、SHA256 校验、多镜像切换、导入本地 .gguf 文件、基于 llama_cpp_dart 加载运行
- **云端 API**：厂商预设自动填充、API Key 安全存储、OpenAI/Anthropic 双协议

所有配置统一存储在 SQLite settings 表，API Key 使用 flutter_secure_storage 加密。

## 2. 架构

服务分层架构，与现有 TfidfService、HybridSearchService 等模式一致：

```
UI 层 (ai_settings_page, model_card_widget, cloud_config_form, model_download_page)
    ↓
Provider 层 (model_provider, settings_provider)
    ↓
服务层 (ModelRepoService, ModelDownloadService, CloudVendorService)
    ↓
数据层 (settings_dao, flutter_secure_storage, 文件系统, HTTP/dio)
    ↓
已有 (LocalAIProvider, DeviceUtils — 不改动)
```

## 3. 文件清单

### 3.1 新增文件（7 个）

| 文件 | 职责 |
|------|------|
| `lib/data/models/local_model.dart` | 本地模型元数据（id, name, size, sha256, quantization, min_ram, download_urls, status） |
| `lib/data/models/cloud_vendor.dart` | 云端厂商数据（vendor, base_urls, key_url, models, supported_modes） |
| `lib/services/model_repo_service.dart` | 远程模型仓库 JSON 拉取/缓存 |
| `lib/services/cloud_vendor_service.dart` | 云端厂商 JSON 拉取/缓存 |
| `lib/providers/model_provider.dart` | Riverpod 状态管理（模型列表、下载状态、加载状态） |
| `lib/ui/settings/model_card_widget.dart` | 状态联动卡片组件 |
| `lib/ui/settings/cloud_config_form.dart` | 云端配置表单 |

### 3.2 增强文件（2 个，不重写）

| 文件 | 改动 |
|------|------|
| `lib/services/model_download_service.dart` | 新增多镜像下载、SHA256 校验、导入本地模型；移除 hardcoded availableModels |
| `lib/ui/settings/model_download_page.dart` | 用 ModelCardWidget 替换 _ModelTile，增加仓库地址输入框和导入按钮 |

### 3.3 依赖文件（无需改动，供参考）

| 文件 | 说明 |
|------|------|
| `lib/ai/local_ai_provider.dart` | 已有 loadModel/dispose，ModelLoaderService 委托此实现 |
| `lib/core/utils/device_utils.dart` | 已有 getAvailableMemory/isModelSupported，UI 层直接调用 |

### 3.3 改动文件（2 个）

| 文件 | 改动 |
|------|------|
| `lib/ui/settings/ai_settings.dart` | 重构为 SegmentedButton + 整合本地/云端两个 Tab |
| `pubspec.yaml` | 添加 dio, llama_cpp_dart, flutter_secure_storage, crypto, path_provider |

## 4. 数据模型

### 4.1 LocalModel

```dart
enum ModelStatus { notDownloaded, downloading, downloaded, loaded, loadFailed }

class LocalModel {
  final String id;
  final String name;
  final String size;         // "0.6 GB"
  final String minRam;       // "2 GB"
  final String description;
  final String quantization; // "Q4_K_M"
  final Map<String, String> downloadUrls; // {global: "...", china_mirror: "..."}
  final String sha256;
  final ModelStatus status;
  final double downloadProgress; // 0.0 ~ 1.0
  final String? errorMessage;
}
```

### 4.2 CloudVendor

```dart
class CloudVendor {
  final String vendor;
  final String description;
  final List<String> supportedModes; // ["openai"] or ["openai", "anthropic"]
  final Map<String, String> baseUrls; // {openai: "...", anthropic: "..."}
  final String keyUrl;
  final List<String> models;
}
```

## 5. 服务层

### 5.1 ModelRepoService

- `Future<List<LocalModel>> fetchModels(String url)` — 拉取远程 JSON，解析为模型列表
- `Future<List<LocalModel>> getCachedModels()` — 读取本地缓存 `models_cache.json`
- 缓存策略：成功覆盖旧缓存；失败保留旧缓存并提示

### 5.2 CloudVendorService

- `Future<List<CloudVendor>> fetchVendors(String url)` — 拉取云端厂商 JSON
- `Future<List<CloudVendor>> getCachedVendors()` — 读取 `cloud_models_cache.json`

### 5.3 ModelDownloadService（增强）

- `Future<void> downloadWithMirror(LocalModel model, String mirrorKey)` — 按镜像下载
- `Future<bool> verifySha256(String filePath, String expectedHash)` — SHA256 校验
- `Future<void> importLocalModel(String sourcePath)` — 导入本地 .gguf 到 models/ 目录
- 下载使用 `.download` 临时后缀，校验通过后重命名

### 5.4 ModelLoaderService

封装在 `model_provider.dart` 中（不单独建文件），作为 ModelListNotifier 的内部逻辑：

- `Future<void> loadModel(String path)` — 委托 LocalAIProvider.loadModel
- `void unloadCurrent()` — 卸载当前模型（调用 LocalAIProvider.dispose）
- 加载成功后自动释放上一个已加载模型

## 6. Provider 层

### 6.1 model_provider

- `ModelListNotifier` — 管理 `List<LocalModel>` 状态
  - `fetchFromRepo(String url)` — 拉取远程仓库
  - `startDownload(LocalModel model, String mirrorKey)` — 开始下载
  - `cancelDownload()` — 取消下载
  - `loadModel(LocalModel model)` — 加载模型
  - `deleteModel(LocalModel model)` — 删除模型文件
  - `importLocalModel(String path)` — 导入本地文件

### 6.2 cloud_config_provider

- 复用现有 `settingsProvider` 存取云端配置

## 7. UI 设计

### 7.1 主页面 ai_settings.dart

- 顶部 `SegmentedButton`：「本地模型」「云端 API」
- 选中值持久化到 `ai_type` 字段
- 本地 Tab：仓库地址输入框 + 获取按钮 + 模型列表（ModelCardWidget）
- 云端 Tab：CloudConfigForm

### 7.2 ModelCardWidget 状态联动

| 状态 | 背景色 | 操作区 |
|------|--------|--------|
| 未下载 | 浅灰 #F5F5F5 | 「国际」「国内」按钮（或单镜像时「下载」） |
| 下载中 | 绿色进度条动画填充 | 百分比白字 + 「取消」 |
| 已下载 | 浅绿 #E8F5E9 | 「加载」+「删除」 |
| 已加载 | 深绿 #C8E6C9 + 「使用中」徽章 | 加载置灰，删除隐藏 |
| 加载失败 | 浅红 #FFEBEE + 错误文字 | 「重试」+「删除」 |

暗黑模式：灰 #2C2C2C，深绿 #1B5E20/#2E7D32，深红 #B71C1C。

### 7.3 CloudConfigForm

- 服务商下拉（来自缓存 JSON）+ 自定义输入
- API Key 引导链接（已知厂商显示）
- API 协议：已知厂商只读，自定义下拉
- API Key：密文 + 眼睛图标，flutter_secure_storage 存储
- 接口地址：自动填充，可编辑
- 模型下拉 + 手动输入
- 测试连接按钮

## 8. 存储键值（SQLite settings 表）

| Key | 说明 |
|-----|------|
| `ai_type` | local / cloud |
| `model_repo_url` | 模型仓库 JSON 地址 |
| `cloud_vendor_repo_url` | 云端仓库 JSON 地址 |
| `cloud_vendor` | 选中的服务商名称 |
| `cloud_base_url` | 接口地址 |
| `cloud_api_spec` | openai / anthropic |
| `cloud_model` | 模型 ID |
| `local_model_id` | 当前加载的模型 ID |
| API Key | flutter_secure_storage（key: `cloud_api_key`） |

## 9. 依赖变更（pubspec.yaml）

```yaml
dio: ^5.4.0
llama_cpp_dart: ^0.1.0
flutter_secure_storage: ^9.0.0
crypto: ^3.0.0
path_provider: ^2.1.0
```

## 10. 异常处理

- 网络失败：不清除旧缓存，Toast 提示「获取失败，使用已缓存数据」
- SHA256 校验失败：删除文件，提示重新下载
- 内存不足：捕获加载错误，引导选用更小模型
- 导入失败：权限不足或存储满时明确引导
- JSON 格式错误：提示「仓库配置异常，已使用旧数据」

## 11. 实施范围

7 个新文件 + 2 个增强文件 + 2 个改动文件 + 2 个依赖文件（不改动），总计 13 个文件。
