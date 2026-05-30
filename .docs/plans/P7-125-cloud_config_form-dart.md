# P7-125 - cloud_config_form.dart

## 任务信息
- **文件路径**: `lib/ui/settings/cloud_config_form.dart`
- **文件职责**: 云端 API 配置表单
- **依赖文件**: cloud_vendor.dart, settings_provider.dart
- **开发阶段**: P7 - 模型配置

## 任务上下文
云端 API 配置表单，支持厂商预设自动填充、API Key 安全存储。

## 需要实现的内容

- `CloudConfigForm` — ConsumerStatefulWidget
- 服务商选择：下拉框（来自 CloudVendorService 缓存）+ 自定义输入
- API Key 引导：已知厂商显示「🔑 还没有 Key？点击获取」链接（用 url_launcher 打开 keyUrl）
- API 协议：已知厂商只读文本，自定义厂商下拉（OpenAI/Anthropic）
- API Key：密文输入 + 眼睛图标切换，使用 flutter_secure_storage 存储
- 接口地址：根据厂商+协议自动填充 baseUrls 对应值，可手动编辑
- 模型选择：下拉框（厂商 models 列表）+ 支持手动输入
- 测试连接按钮：发送轻量请求验证连通性，显示成功/失败及延迟

## 关键实现要点
- 服务商下拉增加「自定义」选项，选中后所有字段变为手动输入
- 已知厂商切换时自动填充 base_url 和 api_spec
- API Key 使用 flutter_secure_storage 的 key 为 `cloud_api_key`
- 测试连接：调用 AIProvider.generateEmbedding 或简单 chat 请求
- 配置变更后自动保存到 settingsProvider

## 实现要求
- 使用 flutter_secure_storage 加密存储
- url_launcher 打开外部链接
- 完整的表单验证
- 直接输出完整文件内容
