# 知维（Knode）项目执行计划与实施方案

> **最后更新**: 2026-05-30
> **当前架构**: Dart Workspaces + Melos Monorepo
> **国际化**: monolith_localization（CSV, zh/en）

## 一、项目目录结构

```
Knode/
├── apps/
│   └── knode_app/                # App Shell（路由、导航、设置、首页）
│       ├── lib/
│       │   ├── main.dart         # 应用入口
│       │   ├── app.dart          # MaterialApp 配置、主题、路由
│       │   ├── screens/          # Shell、Home、Settings 页面（15 个）
│       │   ├── providers/        # locale_provider
│       │   ├── gen/strings.dart  # monolith 生成的 L10nStringsMixin
│       │   └── l10n/             # L10n 类 + L10nHelper + ARB 文件
│       ├── res/strings.csv       # App 级翻译（46 条）
│       ├── assets/web/           # 微服务 Web 前端
│       └── pubspec.yaml
│
├── packages/
│   ├── core/                     # 核心包：数据库、AI 抽象层、工具类、服务
│   │   ├── lib/
│   │   │   ├── core.dart         # barrel export
│   │   │   ├── ai/               # AIProvider 接口 + Cloud/Local 实现
│   │   │   ├── database/         # SQLite：DAO、Repository、Table
│   │   │   ├── models/           # 数据模型（15 个）
│   │   │   ├── providers/        # 全局 Provider（database, settings, model, stats）
│   │   │   ├── services/         # 基础服务（18 个）
│   │   │   ├── tokenizer/        # N-gram 分词 + 停用词
│   │   │   ├── theme/            # Material 3 主题
│   │   │   ├── utils/            # 工具类（file, hash, json, date, device）
│   │   │   ├── extensions/       # String 扩展
│   │   │   ├── constants/        # 全局常量
│   │   │   └── gen/strings.dart  # L10nStringsMixin（61 条翻译）
│   │   ├── assets/prompts/       # AI Agent 系统提示词（6 个 .txt）
│   │   └── res/strings.csv
│   │
│   ├── wiki/                     # Wiki 模块：文档管理、知识图谱、RAG
│   │   ├── lib/
│   │   │   ├── wiki.dart         # barrel export
│   │   │   ├── screens/          # Wiki UI（8 个）
│   │   │   ├── widgets/          # 图谱组件（4 个）
│   │   │   ├── providers/        # category, document, graph
│   │   │   ├── services/         # import, export
│   │   │   ├── agents/           # summarizer_agent
│   │   │   └── gen/strings.dart  # L10nStringsMixin（53 条翻译）
│   │   └── res/strings.csv
│   │
│   ├── chat/                     # Chat 模块：AI 对话、意图识别、搜索
│   │   ├── lib/
│   │   │   ├── chat.dart         # barrel export
│   │   │   ├── screens/          # Chat UI（6 个）
│   │   │   ├── providers/        # chat, conversation
│   │   │   ├── agents/           # qa, intent, search
│   │   │   └── gen/strings.dart  # L10nStringsMixin（31 条翻译）
│   │   └── res/strings.csv
│   │
│   ├── quiz/                     # Quiz 模块：出题、考试、阅卷
│   │   ├── lib/
│   │   │   ├── quiz.dart         # barrel export
│   │   │   ├── screens/          # Quiz UI（8 个）
│   │   │   ├── providers/        # exam, quiz
│   │   │   ├── agents/           # grader, quiz
│   │   │   ├── services/         # periodic_exam_service
│   │   │   └── gen/strings.dart  # L10nStringsMixin（86 条翻译）
│   │   └── res/strings.csv
│   │
│   └── micro_server/             # 微服务模块：HTTP 服务器、路由、处理器
│       ├── lib/
│       │   ├── micro_server.dart # barrel export
│       │   ├── services/         # server, router
│       │   ├── handlers/         # file, doc, quiz, ai
│       │   └── gen/strings.dart  # L10nStringsMixin（30 条翻译）
│       └── res/strings.csv
│
├── monolith.yaml                 # monolith_localization 配置
├── melos.yaml                    # Melos monorepo 配置
├── pubspec.yaml                  # Dart Workspace 根配置
└── analysis_options.yaml         # 全局 lint 规则
```

---

## 二、模块依赖关系

```
┌─────────────────────────────────────────────────────────┐
│                    apps/knode_app                        │
│          （路由、导航、设置、首页、l10n 初始化）           │
└────┬────────┬────────┬────────┬────────┬────────────────┘
     │        │        │        │        │
     ▼        ▼        ▼        ▼        ▼
┌────────┐┌───────┐┌───────┐┌───────┐┌─────────────┐
│  core  ││ wiki  ││ chat  ││ quiz  ││micro_server │
└────────┘└───┬───┘└───┬───┘└───┬───┘└──────┬──────┘
              │        │        │           │
              └────────┴────────┴───────────┘
                       │
                       ▼
                   ┌───────┐
                   │ core  │  ← 所有模块依赖 core
                   └───────┘
```

**依赖规则**：
- `core` 被所有模块依赖，不依赖任何其他模块
- `wiki`、`chat`、`quiz`、`micro_server` 只依赖 `core`，彼此不依赖
- 跨模块通信通过**回调模式**（如 `onSourceDocumentTap(int docId)`）

---

## 三、核心模块类图

### 3.1 数据模型（packages/core/lib/models/）

```
┌─────────────────────────────────────────────────────────────┐
│                         数据模型层                            │
├─────────────────────────────────────────────────────────────┤
│  Category ◄──1:N── Document                                 │
│  Document ──1:N── ReadingLog                                │
│  Conversation ──1:N── Message                               │
│  Question ──1:N── WrongQuestionLog                          │
│  Exam ──1:N── ExamAnswer                                    │
│  DailyTaskConfig (每日一测配置)                               │
│  Settings (KV 键值对)                                        │
│  Citation, IntentResult, LocalModel, CloudVendor            │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 AIProvider 接口（packages/core/lib/ai/）

```
AIProvider (abstract)
├── CloudAIProvider   — Dio + OpenAI/Anthropic API
├── LocalAIProvider   — llama_cpp_dart
└── AIProviderFactory — 根据配置创建实例

PromptManager — 提示词模板加载/变量替换
EmbeddingService — 文本向量化
```

### 3.3 Riverpod Provider 层

```
基础设施:  databaseProvider, settingsProvider, modelProvider, aiProviderProvider
Wiki 模块: categoryProvider, documentProvider, graphProvider
Chat 模块: chatProvider, conversationProvider
Quiz 模块: quizProvider, examProvider
统计:      statsProvider (readingTop5, quizStats)
```

---

## 四、国际化架构

### 4.1 技术方案

- **方案**: monolith_localization（mixin-based 类型安全访问）
- **CSV 格式**: `id,en,zh`，每包独立 `res/strings.csv`
- **代码生成**: `dart run monolith_runner:localization`
- **运行时**: `L10nHelper` 桥接 Flutter L10n 与 `LocalizeStringDelegate`

### 4.2 翻译条目统计

| 包 | 条目数 | 示例 ID |
|----|--------|---------|
| core | 61 | `core_save`, `core_error`, `core_daily_quiz` |
| wiki | 53 | `wiki_wiki`, `wiki_editor`, `wiki_knowledge_graph` |
| chat | 31 | `chat_send`, `chat_input_message`, `chat_archive` |
| quiz | 86 | `quiz_daily_quiz`, `quiz_exam_result`, `quiz_wrong_questions` |
| micro_server | 30 | `micro_server_server_started_on_port` |
| knode_app | 46 | `knode_app_home`, `knode_app_settings`, `knode_app_backup_settings` |
| **合计** | **307** | |

### 4.3 使用方式

```dart
import 'package:chat/gen/strings.dart';
final _strings = const L10nStringsMixin();

// 类型安全访问
Text(_strings.chat_send)  // → "发送" / "Send"
```

### 4.4 不翻译的内容

- AI 系统提示词（指导 AI 模型的中文 prompt）
- 中文停用词（tokenizer 语言数据）
- 开发者错误信息（`'请在 main.dart 中覆盖...'`）

---

## 五、组件树

### 5.1 应用根组件树（apps/knode_app）

```
MaterialApp (app.dart)
├── L10nHelper.localizationsDelegates  ← monolith 桥接
├── ProviderScope (Riverpod)
└── AppShell (app_shell.dart)
    ├── AppBar + Drawer (PersonalDrawer)
    ├── IndexedStack
    │   ├── HomePage (daily_card, quick_card, score_card, wrong_card)
    │   ├── WikiPage → GraphCanvas + CategoryPanel
    │   ├── ChatPage → ConversationList + MessageBubble + MessageInput
    │   └── QuizPage → ExamPage / WrongList / DailyConfigPage
    └── BottomNavigationBar
```

### 5.2 Wiki 模块组件树（packages/wiki）

```
WikiPage
├── Stack
│   ├── GraphCanvas (CustomPaint)
│   │   ├── GraphNode × N
│   │   └── GraphEdge × N
│   └── CategoryPanel → CategoryTree
├── EditorPage → QuillEditor (flutter_quill 11.x)
└── ReaderPage → ReaderToolbar + CitationPopup
```

### 5.3 Chat 模块组件树（packages/chat）

```
ChatPage
├── ConversationList (侧边栏)
├── MessageArea
│   ├── MessageBubble × N (MarkdownBody + CitationSuperscript)
│   ├── CitationWidget (底部引用列表)
│   └── MessageInput (文字/语音/图片)
└── ArchiveDialog (归档为笔记)
```

### 5.4 Quiz 模块组件树（packages/quiz）

```
QuizPage
├── GridView (入口卡片: daily/quick/review/exam)
├── ExamPage → PageView → QuestionCard × N
├── ResultPage (成绩单)
├── WrongList → WrongDetail
└── DailyConfigPage (每日一测配置)
```

---

## 六、数据流设计

### 6.1 RAG 问答流程

```
用户输入 → ChatProvider → QaAgent → RagService
  ├─ EmbeddingService.embed(query) → vector
  ├─ VectorStoreService.search(vector, topK:5)
  ├─ PromptManager.getPrompt('qa_with_rag', context, history)
  ├─ AIProvider.generateAnswer(query, contextDocs, history)
  └─ 解析引用标记 → MessageDao.insert(answer + citations)
```

### 6.2 出题与考试流程

```
每日一测: BackgroundService → QuizAgent → QuestionDao → ExamDao → NotificationService
随机速记: QuizPage → ExamProvider → DocumentDao.getRecentlyRead → QuizAgent
答题交卷: ExamPage → submitAnswer → finishExam → GraderAgent → ResultPage
错题重练: WrongList → WrongDetail → markAsMastered
```

---

## 七、技术栈

| 类别 | 技术 |
|------|------|
| 框架 | Flutter 3.x (Dart 3.8+) |
| Monorepo | Dart Workspaces + Melos |
| 状态管理 | Riverpod 2.x |
| 数据库 | SQLite (sqflite) |
| 富文本 | flutter_quill 11.x |
| 国际化 | monolith_localization (CSV) |
| 路由 | go_router |
| AI | 可插拔 AIProvider（Cloud + Local） |
| HTTP 服务 | shelf |
| 安全存储 | flutter_secure_storage |

---

## 八、开发阶段与完成状态

### ✅ P0 基础骨架 — 已完成

- [x] Dart Workspace + Melos 配置
- [x] 6 个 package 骨架搭建
- [x] 全局 lint 规则

### ✅ P1 Core 模块 — 已完成

- [x] 数据库（AppDatabase + 11 张表 + 11 个 DAO + 6 个 Repository）
- [x] AI 抽象层（AIProvider + Cloud/Local 实现）
- [x] 18 个基础服务
- [x] 5 个全局 Provider
- [x] 6 个系统提示词模板
- [x] barrel export (core.dart)

### ✅ P2 Wiki 模块 — 已完成

- [x] 8 个 UI 页面（wiki_page, editor, reader, category_tree 等）
- [x] 4 个图谱组件（graph_canvas, controller, node, edge）
- [x] 3 个 Provider（category, document, graph）
- [x] 2 个服务（import, export）
- [x] 1 个 Agent（summarizer）
- [x] flutter_quill 11.x 适配
- [x] barrel export (wiki.dart)

### ✅ P3 Chat 模块 — 已完成

- [x] 6 个 UI 页面（chat_page, conversation_list, archive_dialog 等）
- [x] 2 个 Provider（chat, conversation）
- [x] 3 个 Agent（qa, intent, search）
- [x] 跨模块回调（archive_dialog 接受 categories 参数）
- [x] barrel export (chat.dart)

### ✅ P4 Quiz 模块 — 已完成

- [x] 8 个 UI 页面（quiz_page, exam_page, wrong_list 等）
- [x] 2 个 Provider（exam, quiz）
- [x] 2 个 Agent（grader, quiz）
- [x] 1 个服务（periodic_exam_service）
- [x] 跨模块回调（result_page 接受 onSourceDocumentTap）
- [x] barrel export (quiz.dart)

### ✅ P5 Micro Server 模块 — 已完成

- [x] HTTP 服务（server, router）
- [x] 4 个 Handler（file, doc, quiz, ai）
- [x] Web 前端资源迁移到 apps/knode_app/assets/web/
- [x] barrel export (micro_server.dart)

### ✅ P6 App Shell 组装 — 已完成

- [x] 15 个 Screen 页面
- [x] GoRouter 路由配置
- [x] locale_provider（SettingsDao 直接读写）
- [x] 依赖所有 5 个模块

### ✅ P7 国际化 — 已完成

- [x] monolith_localization 基础设施配置
- [x] 6 个 CSV 文件（307 条翻译）
- [x] 代码生成（6 个 L10nStringsMixin + L10n + L10nHelper）
- [x] ~146 个硬编码字符串替换为类型安全访问
- [x] MaterialApp 集成 L10nHelper

### ⬜ P8 后续优化 — 待执行

- [ ] flutter build apk --release 验证
- [ ] App 启动与模块功能测试
- [ ] 补充剩余 ~140 个未匹配 ID 的 UI 字符串
- [ ] 日期格式化 locale-aware 方案
- [ ] 单元测试补充
- [ ] CLAUDE.md 更新为最新 monorepo 结构

---

## 九、验证方案

### 阶段验收标准

1. **编译检查**：`dart analyze` 各包 0 error
2. **构建验证**：`flutter build apk --release` 成功
3. **运行验证**：App 启动正常，各模块页面可访问
4. **国际化验证**：切换语言（zh/en）后 UI 文本正确切换

### 关键集成测试用例

| 测试 | 验证内容 |
|------|----------|
| wiki_crud | 新建类目→新建文档→编辑→保存→阅读→删除 |
| rag_chat | 配置API→新建文档→Chat提问→验证引用 |
| daily_quiz | 配置每日一测→手动触发→答题→交卷→查看成绩 |
| i18n_switch | 切换语言→验证各页面文本正确切换 |
| micro_server | 启动服务→浏览器访问→阅读文档→上传确认 |
