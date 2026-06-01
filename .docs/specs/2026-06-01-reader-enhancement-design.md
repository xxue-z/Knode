# 阅读器增强功能设计

> 日期：2026-06-01
> 状态：设计完成，待实施

## 1. 功能概述

在沉浸式阅读界面中，将现有只读 `TextField`（原始 Markdown 文本）升级为 `flutter_markdown` 渲染的富文本阅读器，并在此基础上实现：文本选择、上下文操作栏（9 项）、书签、高亮标注、笔记、字典查询、TTS 朗读选中文本、全文搜索、知识库搜索、AI 提问。

## 2. 整体架构

```
UI 层
├── ReaderPage（改造：flutter_markdown + 高亮渲染）
├── ContextToolbar（新建：浮动操作栏，9 个菜单项）
├── BookmarkListPage（新建：书签管理）
├── HighlightListPage（新建：高亮/笔记列表）
├── DictSheet（新建：字典查询底部弹窗，Tab 布局）
├── NoteEditorSheet（新建：笔记输入弹窗）
└── Settings（改造：模块化导航结构）

Provider 层（Riverpod）
├── readerProvider（当前文档、高亮列表、书签列表、阅读设置）
├── bookmarkProvider（书签 CRUD）
└── highlightProvider（高亮 CRUD + 笔记文档生成）

Service 层
├── TtsService（已有，扩展朗读选中文本）
├── DictService（新建：字典抽象 + 海词实现）
└── SearchService（新建：文档内全文搜索 + 知识库 RAG 搜索）

数据访问由 Provider 层直接调用 DAO/Repository，不单独设 Service 层

数据层（SQLite，直接改表，无迁移）
├── bookmarks 表（新建）
├── highlights 表（新建）
├── documents 表（已有，直接加 source_doc_id 列）
└── settings 表（已有，新增阅读设置键）
```

## 3. 数据模型

### 3.1 bookmarks 表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER PK | 自增主键 |
| doc_id | INTEGER | 关联 documents.id |
| position | INTEGER | 起始字符偏移 |
| end_position | INTEGER | 结束偏移 |
| selected_text | TEXT | 选中文字 |
| label | TEXT | 可选标签 |
| created_at | TEXT | 创建时间 |

### 3.2 highlights 表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER PK | 自增主键 |
| doc_id | INTEGER | 关联 documents.id |
| start_pos | INTEGER | 起始偏移 |
| end_pos | INTEGER | 结束偏移 |
| selected_text | TEXT | 选中文字（用于文本匹配回退定位） |
| style | TEXT | JSON: `{"type":"bg","color":"#FFF59D"}` 或 `{"type":"underline","color":"#FF0000"}` |
| note_text | TEXT | 笔记内容（可为空） |
| note_doc_id | INTEGER | 关联笔记文档 ID（可为空） |
| created_at | TEXT | 创建时间 |
| updated_at | TEXT | 更新时间 |

### 3.3 documents 表扩展

新增 `source_doc_id` INTEGER 列，笔记文档指向原文档 ID。

### 3.4 settings 表新增键

| 键 | 默认值 | 说明 |
|----|--------|------|
| reader_font_size | 16.0 | 阅读字体大小 |
| reader_line_spacing | 1.6 | 行距 |
| reader_dark_mode | false | 深色模式 |
| highlight_presets | JSON 数组 | 预配置的高亮样式列表 |
| default_ai_assistant | "builtin" | 默认 AI 助手（内置/外部） |
| default_dict_source | "haici" | 默认词典源 |

### 3.5 双重定位策略

书签和高亮的跳转定位采用双重策略：
1. **优先**：使用 `position` / `start_pos` 偏移量直接定位
2. **回退**：若文档已编辑导致偏移失效（选中文字不匹配），通过 `selected_text` 文本搜索定位
3. **失效处理**：若文本搜索也找不到，标记该书签/高亮为"失效"，在列表中灰显，用户可手动删除

## 4. Markdown 渲染与高亮

### 4.1 渲染方案

将阅读器从只读 `TextField` 改为 `flutter_markdown` 的 `Markdown` widget，启用 `selectable: true`。

自定义 `MarkdownBuilder` 实现高亮注入：
1. 将 Markdown 源解析为 AST
2. 遍历 AST 时累积全局字符偏移量，记录每个文本叶子节点的 `globalStart` / `globalEnd`
3. 查询 highlights 表，对命中区间注入背景色或下划线样式到 `TextSpan`
4. 输出最终的 `TextSpan` 树给 `SelectableText.rich`

### 4.2 高亮应用算法

```
输入：原始 TextSpan 列表 + highlights 列表
1. 将高亮按 start_pos 排序
2. 遍历 TextSpan 列表
3. 对与高亮区间相交的 Span 切割为三段（前、重叠、后）
4. 对重叠段合并高亮样式：
   - 背景色：background: Paint()..color = hlColor.withOpacity(0.3)
   - 下划线：decoration: TextDecoration.underline
5. 输出应用高亮后的新 TextSpan 列表
```

### 4.3 选择交互

- `selectable: true` 提供原生选择手柄
- 通过 `onSelectionChanged` 回调获取选中范围（baseOffset, extentOffset）
- 弹出 ContextToolbar（Overlay 定位）

## 5. 上下文工具栏

### 5.1 定位与样式

- 使用 `Overlay` + `CompositedTransformTarget/Follower` 定位到选中区域上方/下方
- 选中区域靠近顶部时显示在下方，反之在上方
- 水平滚动按钮栏，毛玻璃背景，圆角卡片
- 点击空白处或选择操作后自动消失

### 5.2 菜单项（9 项）

| 菜单项 | 实现方式 |
|--------|----------|
| **复制** | `Clipboard.setData`，Toast 提示 |
| **书签** | 保存到 bookmarks 表，弹窗输入可选标签 |
| **朗读** | `TtsService.speak(selectedText)`，工具栏临时显示停止按钮 |
| **字典** | 弹出 DictSheet 底部弹窗（Tab 布局） |
| **浏览器搜索** | `url_launcher` 打开系统浏览器搜索关键词 |
| **问问 AI** | 默认用内置 AIProvider，提供"分享到外部"选项 |
| **全文搜索** | 在当前文档纯文本中搜索，高亮匹配项，上下切换 |
| **知识库搜索** | 调用 RAG 服务检索，展示结果列表，点击跳转 |
| **划重点/笔记** | 弹出样式选择器 + 笔记输入框，保存到 highlights 表 |

### 5.3 全文搜索细节

- 选中文字后自动在文档内搜索
- 顶部显示匹配计数（如 3/12）+ 上一个/下一个按钮
- 所有匹配项临时高亮
- 点击空白处清除搜索状态

### 5.4 问问 AI 流程

1. **默认**：用 app 内置 AIProvider.generateAnswer() 直接展示回答
2. **可选**：通过 url_launcher 打开外部 AI 应用（DeepSeek 网页版、ChatGPT 等），同时复制到剪贴板
3. 设置中可配置默认 AI 助手

### 5.5 划重点/笔记流程

1. 点击"划重点/笔记" → 弹出样式选择器，展示用户在设置中预配置的所有高亮样式
2. 选择样式后可选输入笔记内容
3. 保存到 highlights 表
4. 若输入了笔记，同时创建笔记文档（见第 7.3 节）

## 6. 字典服务

### 6.1 抽象接口

```dart
abstract class DictService {
  String get name; // 词典名称（用于 Tab 显示）
  Future<List<DictEntry>> lookup(String word);
}

class DictEntry {
  String word;
  String pronunciation;
  List<String> definitions;
  String source;
}
```

### 6.2 实现

- 内置 `HaiciDictService`，调用海词在线 API
- 可扩展其他服务（柯林斯等），通过注册机制添加

### 6.3 DictSheet UI

```
┌─────────────────────────────┐
│  [海词] [柯林斯] [+]         │  ← Tab 栏（切换词典来源）
├─────────────────────────────┤
│  word  /phonetic/           │
│  1. 释义一                   │
│  2. 释义二                   │
│  ...                        │
└─────────────────────────────┘
```

- Tab 栏动态展示已启用的词典源
- `[+]` 按钮预留未来添加新词典
- 无网络时显示提示

## 7. 书签与笔记管理

### 7.1 书签管理

- 阅读器右上角图标进入书签列表页
- 列表展示：选中文字摘要、位置、日期，左滑删除
- 点击书签 → 打开阅读器并定位到保存位置
- 定位后临时高亮闪烁 2 秒

### 7.2 高亮/笔记管理

- 阅读器内可查看当前文档的所有高亮/笔记列表
- 点击跳转到对应位置
- 长按原文文件 → "查看笔记" → 列出关联笔记文件
- 笔记文档在知识图谱中用不同图标区分

### 7.3 笔记文档生成规则

- **标题**：`原文档标题-笔记`（多个笔记加数字编号）
- **内容格式**：

```markdown
## 选中文字1
用户笔记内容...

## 选中文字2
用户笔记内容...
```

- 存入 documents 表，`source_doc_id` 指向原文
- 与原文同一 `category_id`
- 知识图谱中建立"笔记"关系连线
- 文件列表默认隐藏笔记文档，通过"查看笔记"入口访问

## 8. 设置界面改造

### 8.1 模块化导航结构

设置主页改为模块入口列表，点击进入各模块的专属设置页：

```
设置主页
├── Wiki 设置
│   ├── 阅读设置（字体大小、行距、深色模式）
│   ├── 高亮样式管理（预设样式列表，可新增/编辑/删除）
│   └── 字典设置（词典源启用/禁用、默认词典）
├── AI 设置
│   ├── AI 助手选择（内置/外部应用）
│   ├── 模型配置
│   └── 搜索设置（联网搜索开关）
├── 答题设置
│   ├── 难度偏好
│   └── 考试配置
├── 备份设置
│   └── WebDAV 配置
├── 通用设置
│   ├── 语言
│   ├── 主题
│   └── 日志
└── 关于
```

### 8.2 高亮样式管理

- 预配置多套样式（如黄色背景、红色下划线、绿色背景...）
- 每套样式包含：类型（背景色/下划线）、颜色、透明度
- 可新增/编辑/删除预设
- 设置默认样式
- 存入 settings 表 `highlight_presets` 键（JSON 数组）

## 9. 国际化

所有新增字符串必须国际化：

- 使用 `monolith_localization`（CSV 格式）
- 各模块字符串存放在各自包的 `res/strings.csv` 中
- 新增的 UI 文案包括：
  - 上下文工具栏菜单项名称
  - 书签/高亮列表页标题和提示
  - 字典弹窗标题和 Tab 名称
  - 设置页面的模块名称、分块标题、设置项标签
  - Toast 提示信息
  - 确认对话框文案

## 10. 性能优化

- **缓存**：Markdown AST 解析 + segments 缓存，文档内容不变时不重新计算
- **增量更新**：高亮数据变更时仅在当前文档范围重新生成 TextSpan
- **分段渲染**：长文档考虑 ListView.builder 分段，降级为非跨段选择
- **避免过多 Widget**：所有 TextSegment 合并为单个 TextSpan 树

## 11. 扩展性

- `DictService` 抽象接口，新增词典只需实现接口 + 注册
- 高亮样式支持自定义预设，存入 settings 表
- 问问 AI 支持多助手配置
- Tab 布局的字典 UI 预留多词典源扩展

## 12. 文件变更清单

### 新增文件

| 文件 | 说明 |
|------|------|
| packages/wiki/lib/screens/context_toolbar.dart | 上下文工具栏 |
| packages/wiki/lib/screens/bookmark_list_page.dart | 书签管理页 |
| packages/wiki/lib/screens/highlight_list_page.dart | 高亮/笔记列表页 |
| packages/wiki/lib/screens/dict_sheet.dart | 字典查询底部弹窗 |
| packages/wiki/lib/screens/note_editor_sheet.dart | 笔记输入弹窗 |
| packages/wiki/lib/models/bookmark.dart | 书签数据模型 |
| packages/wiki/lib/models/highlight.dart | 高亮数据模型 |
| packages/wiki/lib/models/highlight_style.dart | 高亮样式模型 |
| packages/wiki/lib/services/dict_service.dart | 字典抽象接口 |
| packages/wiki/lib/services/haici_dict_service.dart | 海词词典实现 |
| packages/wiki/lib/services/search_service.dart | 搜索服务 |
| packages/wiki/lib/providers/reader_provider.dart | 阅读器 Provider |
| packages/wiki/lib/providers/bookmark_provider.dart | 书签 Provider |
| packages/wiki/lib/providers/highlight_provider.dart | 高亮 Provider |

### 修改文件

| 文件 | 说明 |
|------|------|
| packages/wiki/lib/screens/reader_page.dart | 核心改造：TextField → flutter_markdown + 高亮 |
| packages/wiki/lib/screens/settings_page.dart | 设置界面模块化改造 |
| packages/core/lib/database/app_database.dart | 新增 bookmarks、highlights 表 |
| packages/core/lib/database/dao/document_dao.dart | documents 表加 source_doc_id 列 |
| packages/wiki/res/strings.csv | Wiki 模块国际化字符串 |
| packages/core/res/strings.csv | Core 模块国际化字符串 |
| packages/wiki/pubspec.yaml | 添加 flutter_markdown 依赖 |
