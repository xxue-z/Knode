# P7-119 - cloud_vendor.dart

## 任务信息
- **文件路径**: `lib/data/models/cloud_vendor.dart`
- **文件职责**: 云端厂商数据模型
- **依赖文件**: 无
- **开发阶段**: P7 - 模型配置

## 任务上下文
定义云端服务商的数据结构，用于解析 cloud_models.json 中的厂商配置。

## 需要实现的内容

- `CloudVendor` 类：
  - vendor (String) — 服务商名称
  - description (String)
  - supportedModes (List<String>) — ["openai"] 或 ["openai", "anthropic"]
  - baseUrls (Map<String, String>) — {openai: "...", anthropic: "..."}
  - keyUrl (String) — 获取 API Key 的链接
  - models (List<String>) — 支持的模型列表
  - fromJson 工厂方法
  - toJson 方法

## 关键实现要点
- supportedModes 决定 UI 上显示哪些协议选项
- baseUrls 的 key 对应 ApiSpec 枚举值
- keyUrl 为空时不显示「获取 Key」引导链接

## 实现要求
- 完整的 import 语句
- 直接输出完整文件内容
