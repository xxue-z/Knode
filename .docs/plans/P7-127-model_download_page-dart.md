# P7-127 - model_download_page.dart（增强）

## 任务信息
- **文件路径**: `lib/ui/settings/model_download_page.dart`
- **文件职责**: 模型下载管理页面
- **依赖文件**: model_card_widget.dart, model_provider.dart, model_download_service.dart
- **开发阶段**: P7 - 模型配置

## 任务上下文
用 ModelCardWidget 替换现有 _ModelTile，增加仓库地址输入框和导入按钮。

## 现有代码结构
```dart
class _ModelDownloadPageState extends ConsumerState<ModelDownloadPage> {
  // 从 ModelDownloadService.availableModels 读取硬编码列表
  // 使用 _ModelTile 渲染每个模型
}
```

## 需要增强为

- 顶部仓库地址输入框 + 「获取」按钮（从 settings 读取 model_repo_url）
- 「导入本地模型」按钮
- 使用 ModelCardWidget 替换 _ModelTile
- 数据源改为 modelProvider（而非 ModelDownloadService.availableModels）
- 空状态：图标 +「暂无模型，请获取仓库或导入本地文件」

## 关键实现要点
- 移除对 ModelDownloadService.availableModels 的依赖
- 通过 ref.watch(modelListProvider) 获取模型列表
- 下载/加载/删除操作通过 modelProvider.notifier 调用
- 保留设备内存信息显示

## 实现要求
- 不重写，增量修改
- 使用 Riverpod 2.x 语法
- 直接输出完整文件内容
