# P7-126 - ai_settings.dart（重构）

## 任务信息
- **文件路径**: `lib/ui/settings/ai_settings.dart`
- **文件职责**: AI 引擎主设置页面，整合本地模型和云端配置
- **依赖文件**: model_card_widget.dart, cloud_config_form.dart, model_provider.dart, settings_provider.dart
- **开发阶段**: P7 - 模型配置

## 任务上下文
重构现有 AiSettingsPage，从简单表单升级为 SegmentedButton 双 Tab 布局。

## 现有代码结构
```dart
class AiSettingsPage extends ConsumerStatefulWidget {
  // SwitchListTile 切换云端/本地
  // 云端：DropdownButtonFormField(apiSpec) + TextField(apiKey, baseUrl, model) + Wrap(preset chips)
  // 本地：占位 Card
}
```

## 需要重构为

- 顶部 `SegmentedButton`：「本地模型」「云端 API」
- 选中值持久化到 settings 表 `ai_type` 字段
- **本地 Tab**：
  - 仓库地址输入框（默认值来自参考文档 §3.1）+ 「获取」按钮
  - 导入本地模型按钮（file_picker 选 .gguf）
  - 模型列表（ListView + ModelCardWidget）
  - 空状态：图标 +「暂无模型，请获取仓库或导入本地文件」
- **云端 Tab**：
  - 嵌入 CloudConfigForm
  - 云模型仓库地址输入框 + 「获取」按钮

## 关键实现要点
- 仓库地址默认值：`https://cdn.jsdelivr.net/gh/xxue-z/Knode@master/.resource/models.json`
- 云端仓库默认值：`https://cdn.jsdelivr.net/gh/xxue-z/Knode@master/.resource/cloud_models.json`
- 获取按钮点击后：显示加载动画 → 调用 fetchFromRepo → 失败时 Toast 提示并保留旧缓存
- 导入调用 file_picker 选 .gguf 文件 → 调用 importLocalModel
- 使用 ref.watch(modelListProvider) 驱动列表更新

## 实现要求
- 保留现有 _presets 配置供 CloudConfigForm 使用
- 使用 Riverpod 2.x 语法
- 直接输出完整文件内容
