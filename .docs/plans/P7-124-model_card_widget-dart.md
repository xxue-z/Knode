# P7-124 - model_card_widget.dart

## 任务信息
- **文件路径**: `lib/ui/settings/model_card_widget.dart`
- **文件职责**: 状态联动的模型卡片组件
- **依赖文件**: local_model.dart
- **开发阶段**: P7 - 模型配置

## 任务上下文
根据模型当前状态动态渲染卡片背景色、操作按钮、进度动画。

## 需要实现的内容

- `ModelCardWidget` — StatelessWidget，接收 LocalModel + 回调
- 状态联动背景色：
  - notDownloaded: #F5F5F5（暗黑 #2C2C2C）
  - downloading: 绿色进度条动画填充
  - downloaded: #E8F5E9（暗黑 #2E7D32）
  - loaded: #C8E6C9（暗黑 #1B5E20）+ 「使用中」徽章
  - loadFailed: #FFEBEE（暗黑 #B71C1C）+ 错误文字
- 底部操作区按钮：
  - notDownloaded: 「国际」「国内」（根据 downloadUrls 键自动生成）
  - downloading: 百分比白字 + 「取消」
  - downloaded: 「加载」「删除」
  - loaded: 加载置灰，删除隐藏
  - loadFailed: 「重试」「删除」
- 标签行：量化 · 大小 · 最低内存（圆角小标签）

## 关键实现要点
- 下载中状态用 Stack + AnimatedContainer 实现进度条背景
- 百分比文字绝对居中，白色加粗 14sp
- 单镜像时只显示一个「下载」按钮
- 暗黑模式通过 Theme.of(context).brightness 判断

## 实现要求
- 纯 UI 组件，不含业务逻辑
- 回调：onDownload(mirrorKey), onCancel, onLoad, onDelete, onRetry
- 直接输出完整文件内容
