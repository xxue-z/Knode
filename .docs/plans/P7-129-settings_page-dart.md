# P7-129 - settings_page.dart（导航更新）

## 任务信息
- **文件路径**: `lib/ui/settings/settings_page.dart`
- **文件职责**: 设置主页，更新 AI 设置入口导航
- **依赖文件**: 无
- **开发阶段**: P7 - 模型配置

## 任务上下文
确保 settings_page.dart 中「AI 模型配置」入口指向重构后的 AiSettingsPage。

## 现有代码
```dart
_SettingsTile(
  icon: Icons.smart_toy_outlined,
  title: 'AI 模型配置',
  subtitle: '切换云端/本地模式，配置 API Key',
  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiSettingsPage())),
),
```

## 需要修改
- subtitle 更新为「本地模型管理、云端 API 配置」（更准确描述新功能）
- 其他无需改动，导航目标 AiSettingsPage 不变

## 操作步骤

1. 修改 subtitle 文案
2. 确认 AiSettingsPage 导入路径不变
