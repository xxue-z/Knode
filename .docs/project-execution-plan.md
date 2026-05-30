# 知维（Knode）项目执行计划与实施方案

## 一、项目目录结构设计

```
knode/
├── android/                          # Android 平台代码
├── ios/                              # iOS 平台代码
├── lib/
│   ├── main.dart                     # 应用入口
│   ├── app.dart                      # MaterialApp 配置、路由、主题
│   │
│   ├── core/                         # 核心基础层
│   │   ├── constants/
│   │   │   ├── app_constants.dart    # 全局常量（默认端口、路径等）
│   │   │   └── db_constants.dart     # 数据库版本、表名常量
│   │   ├── theme/
│   │   │   ├── app_theme.dart        # Material 3 主题定义
│   │   │   └── text_styles.dart      # 字体/排版样式
│   │   ├── utils/
│   │   │   ├── file_utils.dart       # 文件读写、路径拼接
│   │   │   ├── hash_utils.dart       # 文本哈希去重
│   │   │   ├── json_utils.dart       # JSON 编解码辅助
│   │   │   ├── date_utils.dart       # 日期格式化
│   │   │   └── device_utils.dart     # 设备内存/存储检测
│   │   └── extensions/
│   │       └── string_extensions.dart # String 扩展方法
│   │
│   ├── data/                         # 数据层
│   │   ├── database/
│   │   │   ├── app_database.dart     # SQLite 单例、初始化、迁移
│   │   │   └── tables/              # 各表的建表 SQL 常量
│   │   │       ├── category_table.dart
│   │   │       ├── document_table.dart
│   │   │       ├── conversation_table.dart
│   │   │       ├── message_table.dart
│   │   │       ├── question_table.dart
│   │   │       ├── exam_table.dart
│   │   │       ├── exam_answer_table.dart
│   │   │       ├── wrong_question_log_table.dart
│   │   │       ├── daily_task_config_table.dart
│   │   │       ├── reading_log_table.dart
│   │   │       └── settings_table.dart
│   │   ├── dao/                      # 数据访问对象
│   │   │   ├── category_dao.dart
│   │   │   ├── document_dao.dart
│   │   │   ├── conversation_dao.dart
│   │   │   ├── message_dao.dart
│   │   │   ├── question_dao.dart
│   │   │   ├── exam_dao.dart
│   │   │   ├── exam_answer_dao.dart
│   │   │   ├── wrong_question_dao.dart
│   │   │   ├── daily_task_dao.dart
│   │   │   ├── reading_log_dao.dart
│   │   │   └── settings_dao.dart
│   │   ├── models/                   # 数据模型（与表一一对应）
│   │   │   ├── category.dart
│   │   │   ├── document.dart
│   │   │   ├── conversation.dart
│   │   │   ├── message.dart
│   │   │   ├── question.dart
│   │   │   ├── exam.dart
│   │   │   ├── exam_answer.dart
│   │   │   ├── wrong_question_log.dart
│   │   │   ├── daily_task_config.dart
│   │   │   ├── reading_log.dart
│   │   │   ├── citation.dart         # 引用模型
│   │   │   ├── intent_result.dart    # 意图识别结果
│   │   │   ├── local_model.dart      # 本地模型元数据 + ModelStatus 枚举
│   │   │   └── cloud_vendor.dart     # 云端厂商数据模型
│   │   └── repositories/             # 业务仓库（组合 DAO + 文件操作）
│   │       ├── category_repository.dart
│   │       ├── document_repository.dart
│   │       ├── conversation_repository.dart
│   │       ├── question_repository.dart
│   │       ├── exam_repository.dart
│   │       └── settings_repository.dart
│   │
│   ├── ai/                           # AI 抽象层
│   │   ├── ai_provider.dart          # AIProvider 抽象接口
│   │   ├── cloud_ai_provider.dart    # 云端实现（dio + OpenAI 兼容）
│   │   ├── local_ai_provider.dart    # 本地实现（llama_cpp_dart）
│   │   ├── ai_provider_factory.dart  # Provider 工厂，根据配置创建实例
│   │   ├── prompt_manager.dart       # 提示词模板加载/变量替换
│   │   ├── embedding_service.dart    # 文本向量化服务
│   │   └── agents/                   # Agent 逻辑封装
│   │       ├── qa_agent.dart         # 问答 Agent（RAG）
│   │       ├── quiz_agent.dart       # 出题 Agent
│   │       ├── grader_agent.dart     # 阅卷 Agent
│   │       ├── intent_agent.dart     # 意图识别 Agent
│   │       ├── summarizer_agent.dart # 摘要 Agent
│   │       └── search_agent.dart     # 联网搜索 Agent（仅云端可用）
│   │
│   ├── services/                     # 业务服务
│   │   ├── rag_service.dart          # RAG 流水线（向量化→检索→生成）
│   │   ├── vector_store_service.dart # sqlite-vec 向量存储/检索
│   │   ├── file_service.dart         # Wiki 文件 CRUD（.md 读写）
│   │   ├── import_service.dart       # PDF/DOCX 导入转换
│   │   ├── export_service.dart       # MD 导出 PDF/Word
│   │   ├── tts_service.dart          # TTS 朗读封装
│   │   ├── speech_service.dart       # 语音输入封装
│   │   ├── notification_service.dart # 本地通知
│   │   ├── background_service.dart   # workmanager 后台任务注册
│   │   ├── periodic_exam_service.dart       # 阶段考试预生成（月/季/年考）
│   │   ├── external_app_launcher.dart       # 外部 App 跳转（一键复制讲解）
│   │   ├── backup_service.dart       # WebDAV 备份
│   │   ├── prompt_remote_sync_service.dart  # 远程提示词模板同步
│   │   ├── model_repo_service.dart    # 远程模型仓库拉取/缓存 + 重试
│   │   ├── cloud_vendor_service.dart  # 云端厂商 JSON 拉取/缓存 + 重试
│   │   └── micro_server/             # 内嵌 HTTP 微服务
│   │       ├── server.dart           # shelf HTTP 服务启动/停止
│   │       ├── router.dart           # REST API 路由
│   │       ├── handlers/
│   │       │   ├── file_handler.dart # 文件列表/上传/下载
│   │       │   ├── doc_handler.dart  # 文档阅读 API
│   │       │   ├── quiz_handler.dart # 在线答题 API
│   │       │   └── ai_handler.dart   # AI 问答 API
│   │       └── web_assets/           # Web UI 静态资源（HTML/CSS/JS）
│   │
│   ├── providers/                    # Riverpod Providers
│   │   ├── database_provider.dart    # AppDatabase Provider
│   │   ├── ai_provider.dart          # AIProvider Provider
│   │   ├── category_provider.dart    # 类目状态管理
│   │   ├── document_provider.dart    # 文档状态管理
│   │   ├── graph_provider.dart       # 知识图谱状态
│   │   ├── conversation_provider.dart# 会话状态
│   │   ├── chat_provider.dart        # Chat 消息状态
│   │   ├── quiz_provider.dart        # 测验状态
│   │   ├── exam_provider.dart        # 考试状态
│   │   ├── stats_provider.dart       # 统计数据（个人中心）
│   │   ├── settings_provider.dart    # 设置状态
│   │   └── model_provider.dart       # 本地模型列表状态管理
│   │
│   ├── ui/                           # UI 层
│   │   ├── shell/
│   │   │   ├── app_shell.dart        # 底部导航 + 顶部栏 + Drawer
│   │   │   ├── bottom_nav.dart       # 底部导航（含中间 Chat 浮球）
│   │   │   └── personal_drawer.dart  # 左侧个人中心抽屉
│   │   ├── home/
│   │   │   ├── home_page.dart        # 首页（卡片布局）
│   │   │   ├── daily_card.dart       # 每日一测入口卡片
│   │   │   ├── quick_card.dart       # 随机速记入口卡片
│   │   │   ├── score_card.dart       # 最近成绩卡片
│   │   │   └── wrong_card.dart       # 最近错题卡片
│   │   ├── wiki/
│   │   │   ├── wiki_page.dart        # 知识图谱主页面
│   │   │   ├── graph/
│   │   │   │   ├── graph_canvas.dart # 图谱画布（节点+连线渲染）
│   │   │   │   ├── graph_node.dart   # 单个节点 Widget
│   │   │   │   ├── graph_edge.dart   # 连线 Widget
│   │   │   │   └── graph_controller.dart # 缩放/拖拽/惯性控制
│   │   │   ├── category/
│   │   │   │   ├── category_panel.dart   # 右滑类目面板
│   │   │   │   └── category_tree.dart    # 层级目录树
│   │   │   ├── reader/
│   │   │   │   ├── reader_page.dart      # 沉浸式阅读页
│   │   │   │   ├── reader_toolbar.dart   # 阅读设置栏
│   │   │   │   └── citation_popup.dart   # 引用浮窗
│   │   │   └── editor/
│   │   │       ├── editor_page.dart      # 文档编辑页
│   │   │       └── quill_editor.dart     # flutter_quill 封装
│   │   ├── chat/
│   │   │   ├── chat_page.dart        # Chat 主页面
│   │   │   ├── conversation_list.dart# 会话列表
│   │   │   ├── message_bubble.dart   # 消息气泡
│   │   │   ├── message_input.dart    # 输入框（文字/语音/图片）
│   │   │   ├── citation_widget.dart  # 引用角标+底部引用列表
│   │   │   └── archive_dialog.dart   # 归档为笔记对话框
│   │   ├── quiz/
│   │   │   ├── quiz_page.dart        # 测验主页面
│   │   │   ├── exam/
│   │   │   │   ├── exam_page.dart    # 答题页面（PageView）
│   │   │   │   ├── question_card.dart# 单题展示
│   │   │   │   ├── timer_widget.dart # 倒计时
│   │   │   │   └── result_page.dart  # 成绩单
│   │   │   ├── wrong/
│   │   │   │   ├── wrong_list.dart   # 错题本列表
│   │   │   │   └── wrong_detail.dart # 错题详情
│   │   │   └── config/
│   │   │       └── daily_config_page.dart # 每日一测配置
│   │   └── settings/
│   │       ├── settings_page.dart    # 设置主页面
│   │       ├── ai_settings.dart      # AI 模型配置（本地/云端 Tab）
│   │       ├── model_card_widget.dart # 模型状态联动卡片
│   │       ├── cloud_config_form.dart # 云端配置表单
│   │       ├── model_download_page.dart # 模型下载管理
│   │       ├── server_settings.dart  # 微服务开关/端口
│   │       ├── backup_settings.dart  # WebDAV 配置
│   │       └── storage_settings.dart # 存储路径配置
│   │
│   └── assets/
│       ├── prompts/                  # Agent 提示词模板
│       │   ├── qa_with_rag.txt
│       │   ├── quiz_generator.txt
│       │   ├── grader.txt
│       │   ├── intent_analyzer.txt
│       │   └── summarizer.txt
│       └── web/                      # 微服务 Web UI 静态文件
│           ├── index.html
│           ├── style.css
│           └── app.js
│
├── test/                             # 测试
│   ├── unit/
│   │   ├── dao/
│   │   ├── services/
│   │   └── providers/
│   ├── widget/
│   └── integration/
│
├── pubspec.yaml
└── CLAUDE.md
```

---

## 二、核心模块类图与状态管理

### 2.1 数据模型类图

```
┌─────────────────────────────────────────────────────────────────┐
│                         数据模型层                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐       ┌──────────────┐                        │
│  │  Category    │       │  Document    │                        │
│  ├──────────────┤       ├──────────────┤                        │
│  │ id: int      │◄──┐   │ id: int      │                        │
│  │ name: String │   │   │ title: String│                        │
│  │ parentId: int│───┘   │ fileName:Str │                        │
│  │ sortOrder:int│  1:N  │ filePath: Str│                        │
│  │ createdAt    │       │ categoryId:int│──►Category            │
│  │ updatedAt    │       │ contentText  │                        │
│  └──────────────┘       │ summary      │                        │
│                         │ wordCount    │                        │
│                         │ readingTime  │                        │
│                         │ readCount    │                        │
│                         │ lastReadAt   │                        │
│                         │ isDeleted    │                        │
│                         │ createdAt    │                        │
│                         │ updatedAt    │                        │
│                         └──────┬───────┘                        │
│                                │ 1:N                            │
│                         ┌──────▼───────┐                        │
│                         │ ReadingLog   │                        │
│                         ├──────────────┤                        │
│                         │ id: int      │                        │
│                         │ docId: int   │                        │
│                         │ startTime    │                        │
│                         │ endTime      │                        │
│                         │ durationSec  │                        │
│                         └──────────────┘                        │
│                                                                 │
│  ┌──────────────────┐    ┌──────────────────┐                   │
│  │  Conversation    │    │  Message         │                   │
│  ├──────────────────┤    ├──────────────────┤                   │
│  │ id: int          │◄───│ id: int          │                   │
│  │ title: String    │ 1:N│ conversationId   │                   │
│  │ status: String   │    │ role: String     │                   │
│  │ wikiFileId: int? │    │ content: String  │                   │
│  │ createdAt        │    │ contentType: Str │                   │
│  │ updatedAt        │    │ mediaPath: Str?  │                   │
│  └──────────────────┘    │ citations: JSON? │                   │
│                          │ createdAt        │                   │
│                          └──────────────────┘                   │
│                                                                 │
│  ┌──────────────────┐    ┌──────────────────┐                   │
│  │  Question        │    │  Exam            │                   │
│  ├──────────────────┤    ├──────────────────┤                   │
│  │ id: int          │◄───│ id: int          │                   │
│  │ type: String     │    │ examType: String │                   │
│  │ stem: String     │    │ title: String?   │                   │
│  │ options: JSON?   │    │ questionCount    │                   │
│  │ answer: String   │    │ totalScore       │                   │
│  │ explanation      │    │ obtainedScore    │                   │
│  │ sourceFileIds:JS │    │ timeLimit        │                   │
│  │ difficulty: int  │    │ startedAt        │                   │
│  │ tags: JSON?      │    │ finishedAt       │                   │
│  │ createdAt        │    │ status: String   │                   │
│  └────────┬─────────┘    │ configJson       │                   │
│           │ 1:N          └────────┬─────────┘                   │
│  ┌────────▼─────────┐    ┌────────▼─────────┐                   │
│  │WrongQuestionLog  │    │ ExamAnswer       │                   │
│  ├──────────────────┤    ├──────────────────┤                   │
│  │ id: int          │    │ id: int          │                   │
│  │ questionId: int  │    │ examId: int      │                   │
│  │ wrongCount: int  │    │ questionId: int  │                   │
│  │ lastWrongAt      │    │ userAnswer       │                   │
│  └──────────────────┘    │ isCorrect: int?  │                   │
│                          │ score: double?   │                   │
│                          │ aiFeedback: Str? │                   │
│                          └──────────────────┘                   │
│                                                                 │
│  ┌──────────────────┐    ┌──────────────────┐                   │
│  │DailyTaskConfig   │    │ Settings (KV)    │                   │
│  ├──────────────────┤    ├──────────────────┤                   │
│  │ id: int          │    │ key: String (PK) │                   │
│  │ isEnabled: int   │    │ value: String    │                   │
│  │ scopeType: String│    └──────────────────┘                   │
│  │ scopeValue: JSON │                                           │
│  │ questionCount    │    ┌──────────────────┐                   │
│  │ reminderTime     │    │ IntentResult     │                   │
│  │ reminderMethods  │    ├──────────────────┤                   │
│  │ createdAt        │    │ isQuestion: bool │                   │
│  │ updatedAt        │    │ suggestedPath?   │                   │
│  └──────────────────┘    │ confidence       │                   │
│                          └──────────────────┘                   │
│                                                                 │
│  ┌──────────────────┐                                           │
│  │ Citation         │                                           │
│  ├──────────────────┤                                           │
│  │ docId: int       │                                           │
│  │ title: String    │                                           │
│  │ snippet: String  │                                           │
│  └──────────────────┘                                           │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 AIProvider 类图

```
┌─────────────────────────────────────────────────────────────┐
│                    AI 抽象层                                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────────────────────────────┐               │
│  │  «abstract» AIProvider                   │               │
│  ├──────────────────────────────────────────┤               │
│  │                                          │               │
│  │  + generateAnswer(                       │               │
│  │      query: String,                      │               │
│  │      contextDocs: List<String>,          │               │
│  │      history: List<Map>                  │               │
│  │    ): Future<AIResponse>                 │               │
│  │                                          │               │
│  │  + generateQuiz(                         │               │
│  │      content: String,                    │               │
│  │      minCount: int,                      │               │
│  │      maxCount: int                       │               │
│  │    ): Future<List<Question>>             │               │
│  │                                          │               │
│  │  + analyzeIntent(                        │               │
│  │      text: String,                       │               │
│  │      existingFiles: List<String>         │               │
│  │    ): Future<IntentResult>               │               │
│  │                                          │               │
│  │  + summarize(content: String):           │               │
│  │      Future<String>                      │               │
│  │                                          │               │
│  │  + gradeAnswer(                          │               │
│  │      question: String,                   │               │
│  │      reference: String,                  │               │
│  │      userAnswer: String                  │               │
│  │    ): Future<GradeResult>                │               │
│  │                                          │               │
│  │  + generateEmbedding(                    │               │
│  │      text: String                        │               │
│  │    ): Future<List<double>>               │               │
│  │                                          │               │
│  │  # buildMessages(                        │               │
│  │      systemPrompt: String,               │               │
│  │      userContent: String,                │               │
│  │      history: List<Map>                  │               │
│  │    ): List<Map<String, String>>          │               │
│  │                                          │               │
│  └─────────────────┬────────────────────────┘               │
│                    │ implements                              │
│        ┌───────────┴───────────┐                            │
│        ▼                       ▼                            │
│  ┌──────────────────┐  ┌──────────────────────┐             │
│  │CloudAIProvider   │  │ LocalAIProvider      │             │
│  ├──────────────────┤  ├──────────────────────┤             │
│  │ - _dio: Dio      │  │ - _llama: LlamaCpp   │             │
│  │ - _baseUrl: Str  │  │ - _modelPath: String │             │
│  │ - _apiKey: String│  │ - _isLoaded: bool    │             │
│  │ - _model: String │  ├──────────────────────┤             │
│  ├──────────────────┤  │ + loadModel(): void  │             │
│  │                  │  │ + unloadModel(): void│             │
│  │ 实现所有抽象方法  │  │ 实现所有抽象方法      │             │
│  └──────────────────┘  └──────────────────────┘             │
│                                                             │
│  ┌──────────────────────────────────────────┐               │
│  │  AIProviderFactory                       │               │
│  ├──────────────────────────────────────────┤               │
│  │  + create(type: String, config: Map):    │               │
│  │      AIProvider                          │               │
│  └──────────────────────────────────────────┘               │
│                                                             │
│  ┌──────────────────────────────────────────┐               │
│  │  PromptManager                           │               │
│  ├──────────────────────────────────────────┤               │
│  │  - _templates: Map<String, String>       │               │
│  │  + loadTemplates(): void                 │               │
│  │  + getPrompt(agentName: String,          │               │
│  │      params: Map): String                │               │
│  │  + updateTemplate(name: String,          │               │
│  │      template: String): void             │               │
│  └──────────────────────────────────────────┘               │
└─────────────────────────────────────────────────────────────┘
```

### 2.3 状态管理（Riverpod）

采用 **Riverpod** 作为状态管理方案，核心 Provider 链：

```
┌─────────────────────────────────────────────────────────────────┐
│                     Riverpod Provider 层                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─ 基础设施 ──────────────────────────────────────────────┐    │
│  │                                                         │    │
│  │  databaseProvider ──► AppDatabase 单例                  │    │
│  │  aiProviderProvider ──► 当前 AIProvider 实例            │    │
│  │  promptManagerProvider ──► PromptManager 单例           │    │
│  │  settingsProvider ──► SettingsNotifier                  │    │
│  │                                                         │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ┌─ Wiki 模块 ─────────────────────────────────────────────┐    │
│  │                                                         │    │
│  │  categoryListProvider ──► AsyncValue<List<Category>>    │    │
│  │  selectedCategoryProvider ──► Category?                 │    │
│  │  documentListProvider(categoryId)                       │    │
│  │      ──► AsyncValue<List<Document>>                     │    │
│  │  documentProvider(docId) ──► AsyncValue<Document>       │    │
│  │  graphDataProvider ──► GraphState                       │    │
│  │      (nodes: List<GraphNode>, edges: List<GraphEdge>)   │    │
│  │                                                         │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ┌─ Chat 模块 ─────────────────────────────────────────────┐    │
│  │                                                         │    │
│  │  conversationListProvider                               │    │
│  │      ──► AsyncValue<List<Conversation>>                 │    │
│  │  activeConversationProvider ──► Conversation?           │    │
│  │  messageListProvider(conversationId)                    │    │
│  │      ──► AsyncValue<List<Message>>                      │    │
│  │  chatInputProvider ──► ChatInputState                   │    │
│  │      (text, mediaPath, isRecording)                     │    │
│  │                                                         │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ┌─ 测验模块 ──────────────────────────────────────────────┐    │
│  │                                                         │    │
│  │  examListProvider ──► AsyncValue<List<Exam>>            │    │
│  │  activeExamProvider ──► ExamState                       │    │
│  │      (exam, questions, answers, currentIndex)           │    │
│  │  wrongQuestionProvider                                  │    │
│  │      ──► AsyncValue<List<WrongQuestionLog>>             │    │
│  │  dailyTaskConfigProvider ──► DailyTaskConfig?           │    │
│  │                                                         │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ┌─ 首页统计 ──────────────────────────────────────────────┐    │
│  │                                                         │    │
│  │  homeStatsProvider ──► HomeStatsState                   │    │
│  │      (dailyDone, recentScore, wrongCount,              │    │
│  │       readingTop5, readingBottom5)                      │    │
│  │                                                         │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

**状态更新原则**：
- DAO 层操作数据库 → Repository 组合业务 → Provider 驱动 UI 刷新
- 所有异步操作用 `AsyncNotifier`，UI 通过 `ref.watch` 响应
- AI 调用结果通过 `StateNotifier` 管理加载/成功/错误状态

---

## 三、数据流设计

### 3.0 知识图谱数据构建流程

```
GraphNotifier 构建图谱数据：
    │
    ├─ 1. DocumentDao.getByCategory(categoryId)
    │     └─ 获取当前类目下所有文档元数据
    │
    ├─ 2. 提取关联关系，生成边：
    │     a. 引用关系：解析 MD 内容中的 [链接文本](file_path) 语法，
    │        匹配目标文档 file_path → 生成边(type: reference)
    │     b. 标签相似度：比较 documents.tags（JSON 数组），
    │        Jaccard 相似度 > 0.3 → 生成边(type: tag_similarity)
    │     c. 同类目关系：同一 category_id 下的文档自然聚类
    │
    ├─ 3. 输出 GraphState(nodes: List<GraphNode>, edges: List<GraphEdge>)
    │
    └─ 4. 若节点数 > 50，启用聚类模式：
          按类目聚合为超级节点（显示包含数量），点击展开时再细分
```

> **图谱渲染选型**：采用 CustomPaint 自绘而非 GraphView 库。理由：
> (1) GraphView 的 FruchtermanReingold 力导向算法在节点数 > 200 时性能不足；
> (2) 自绘可精确控制惯性动效、节点放大动画、聚类展开等交互细节；
> (3) 减少第三方依赖。
> GraphView 可作为 P0 原型阶段的快速验证手段。

### 3.1 Wiki 阅读流程

```
用户单击图谱节点
    │
    ▼
GraphController.onNodeTap(nodeId)
    │
    ▼
ref.read(graphDataProvider.notifier).selectNode(nodeId)
    │
    ▼
graphDataProvider 状态更新：选中节点放大居中
    │
    ▼
显示摘要卡片（Document.contentText 前 50 字）
    │
    ▼
用户点击"阅读"按钮
    │
    ▼
Navigator.push → ReaderPage(docId)
    │
    ├─► ref.read(documentProvider(docId))  加载文档内容
    ├─► ref.read(readingLogProvider).startLog(docId)  记录阅读开始
    │
    ▼
ReaderPage 渲染 Markdown（flutter_markdown）
    │
    ├─► 点击屏幕中央 → 弹出 ReaderToolbar（字体/间距/背景）
    ├─► TTS 按钮 → TtsService.speak(content)
    └─► 长按选中文字 → 菜单：AI讲解/生成题目/复制
         │
         ├─ "AI讲解" → Navigator.push ChatPage(preFilledQuery)
         └─ "生成题目" → QuizAgent.generateQuiz(content) → 入库
    │
    ▼
用户返回
    │
    ▼
ref.read(readingLogProvider).endLog(docId, duration)
    │
    ▼
DocumentDao.updateReadingStats(docId, duration)
```

### 3.2 RAG 问答流程

```
用户在 Chat 输入框输入问题
    │
    ▼
ChatInputNotifier.submit(text)
    │
    ├─► MessageDao.insert(conversationId, role:'user', content:text)
    │
    ▼
RagService.answer(query, conversationId)
    │
    ├─ 1. EmbeddingService.embed(query)
    │     └─► AIProvider.generateEmbedding(query) → vector
    │
    ├─ 2. VectorStoreService.search(vector, topK:5)
    │     └─► sqlite-vec 查询 → List<SearchResult>
    │
    ├─ 3. MessageDao.getHistory(conversationId, limit:10)
    │     └─► 最近 10 条消息作为对话历史
    │
    ├─ 4. PromptManager.getPrompt('qa_with_rag', {
    │        'context': searchResults.map((r) => r.snippet).join('\n'),
    │        'history': history,
    │        'query': query
    │     })
    │
    ├─ 5. AIProvider.generateAnswer(query, contextDocs, history)
    │     └─► CloudAIProvider: dio.post → OpenAI API
    │     └─► LocalAIProvider: llama.prompt
    │
    ├─ 6. 解析返回内容中的引用标记 → List<Citation>
    │
    └─ 7. MessageDao.insert(conversationId, role:'assistant',
            content:answer, citations:citations)
    │
    ▼
ChatNotifier 接收结果，UI 刷新
    │
    ├─► MessageBubble 渲染消息（含引用角标 [1][2]）
    └─► CitationWidget 渲染底部引用列表（点击跳转阅读）
```

### 3.3 出题与考试流程

```
场景A：每日一测（后台预生成）
─────────────────────────────────
workmanager 定时触发（每日 reminder_time - 30min）
    │
    ▼
BackgroundService.onDailyQuizTask()
    │
    ├─► DailyTaskDao.getConfig()
    │     └─ 获取 scopeType, scopeValue, questionCount
    │
    ├─► DocumentDao.getDocsByScope(scopeType, scopeValue)
    │     └─ 按配置范围筛选文档列表
    │
    ├─► 对每个文档：QuizAgent.generateQuiz(content, min:2, max:10)
    │     └─► AIProvider.generateQuiz() → JSON 解析 → List<Question>
    │     └─► QuestionDao.upsertWithDedup(questions)  // 哈希去重
    │
    ├─► ExamDao.create(examType:'daily', questionIds:...)
    │
    └─► NotificationService.showDailyQuizReminder()


场景B：随机速记（实时生成）
─────────────────────────────────
用户点击首页"随机速记"卡片
    │
    ▼
Navigator.push → ExamPage(examType:'random')
    │
    ▼
ExamNotifier.startRandomQuiz()
    │
    ├─► DocumentDao.getRecentlyRead(days:7, limit:10)
    │
    ├─► QuizAgent.generateQuiz(contents, min:8, max:12)
    │     └─ 若生成失败 → 降级为 QuestionDao.getRandomFromPool(count:10)
    │
    ├─► ExamDao.create(examType:'random', questionIds:...)
    │
    └─► ExamNotifier 状态更新 → ExamPage 渲染


答题与阅卷
─────────────────────────────────
ExamPage 显示题目（PageView 逐题）
    │
    ├─► 用户作答 → ExamNotifier.submitAnswer(questionId, userAnswer)
    │     └─► ExamAnswerDao.insert(examId, questionId, userAnswer)
    │
    ▼
用户点击"交卷"
    │
    ▼
ExamNotifier.finishExam()
    │
    ├─► 客观题：自动判分（对比 answer 字段）
    │
    ├─► 简答题：GraderAgent.grade(question, reference, userAnswer)
    │     └─► AIProvider.gradeAnswer() → GradeResult(score, feedback)
    │
    ├─► ExamAnswerDao.batchUpdateScores(examId, results)
    ├─► ExamDao.updateScore(examId, totalScore)
    │
    └─► 错题记录：WrongQuestionDao.upsert(wrongQuestionIds)
    │
    ▼
Navigator.push → ResultPage(examId)
    └─► 展示成绩单：总分、各题对错、引用源文件
```

### 3.4 设置与 Provider 切换流程

```
用户在 SettingsPage 修改 AI Provider 类型
    │
    ▼
SettingsNotifier.update('ai_provider_type', 'local')
    │
    ▼
SettingsDao.upsert('ai_provider_type', 'local')
    │
    ▼
ref.read(aiProviderProvider.notifier).switchProvider(type, config)
    │
    ├─► 旧 provider.dispose()（释放资源）
    ├─► AIProviderFactory.create(type, config)
    │     └─► LocalAIProvider(modelPath) → loadModel()
    └─► 新 provider 赋值，所有依赖方自动刷新
```

---

## 四、组件树与服务架构

### 4.1 应用根组件树

```
MaterialApp (app.dart)
    │
    └─► ProviderScope (Riverpod 根)
        │
        └─► AppShell (app_shell.dart)
            │
            ├─► Scaffold
            │   ├─► AppBar (顶部栏)
            │   │   ├─► GestureDetector(avatar) → 打开 Drawer
            │   │   └─► title: 当前页面标题
            │   │
            │   ├─► Drawer (PersonalDrawer)
            │   │   ├─► UserInfoCard (头像/昵称/学习天数)
            │   │   ├─► ReadingStatsCard (Top5/Bottom5)
            │   │   ├─► QuizStatsCard (各类型次数/均分)
            │   │   └─► SettingsButton (底部固定)
            │   │
            │   ├─► Body (IndexedStack 保持页面状态)
            │   │   ├─► HomePage
            │   │   ├─► WikiPage
            │   │   ├─► ChatPage
            │   │   └─► QuizPage
            │   │
            │   └─► BottomNavigationBar (BottomNav)
            │       ├─► NavigationBarItem("知识库")
            │       ├─► FloatingActionButton("Chat") ← 突出圆球
            │       └─► NavigationBarItem("测验")
            │
            └─► Overlay (全局浮层：Toast/Dialog/Loading)
```

### 4.2 Wiki 模块组件树

```
WikiPage
    │
    ├─► Stack (图谱 + 右滑面板)
    │   │
    │   ├─► GraphCanvas (全屏图谱)
    │   │   ├─► InteractiveViewer / GestureDetector
    │   │   │   └─► CustomPaint
    │   │   │       ├─► GraphEdge × N (连线)
    │   │   │       └─► GraphNode × N (节点)
    │   │   │           └─► AnimatedScale / AnimatedContainer
    │   │   │
    │   │   └─► NodeSummaryCard (选中节点的摘要浮窗)
    │   │       ├─► Text(摘要, maxLines:2)
    │   │       └─► TextButton("阅读") → Navigator.push ReaderPage
    │   │
    │   └─► CategoryPanel (从右向左滑出)
    │       ├─► AnimatedSlide / SlideTransition
    │       └─► CategoryTree
    │           └─► CategoryTile × N (递归树形)
    │               ├─► Icon(文件夹)
    │               ├─► Text(类目名)
    │               └─► PopupMenuButton (重命名/删除/移动)
    │
    └─► FloatingActionButton("新建文档")
        └─► EditorPage
```

### 4.3 Chat 模块组件树

```
ChatPage
    │
    ├─► Row (会话列表 + 消息区) [手机端：Navigator 切换]
    │   │
    │   ├─► ConversationList (侧边栏/独立页面)
    │   │   ├─► ListTile("新会话") + IconButton
    │   │   └─► ConversationTile × N
    │   │       ├─► title, subtitle(lastMessage)
    │   │       └─► Dismissible(删除) / LongPressMenu(重命名/归档)
    │   │
    │   └─► MessageArea
    │       ├─► ListView.builder (消息列表)
    │       │   └─► MessageBubble × N
    │       │       ├─► Avatar(role)
    │       │       ├─► MarkdownBody(content)
    │       │       ├─► CitationSuperscript [1][2]...
    │       │       └─► CopyButton / FeedbackButton
    │       │
    │       ├─► CitationWidget (底部引用列表)
    │       │   └─► CitationTile × N → 点击跳转 ReaderPage
    │       │
    │       └─► MessageInput
    │           ├─► TextField
    │           ├─► IconButton(mic) → SpeechService
    │           ├─► IconButton(image) → ImagePicker
    │           └─► IconButton(send) → submit
```

### 4.4 测验模块组件树

```
QuizPage
    │
    ├─► GridView (入口卡片)
    │   ├─► DailyQuizCard (每日一测)
    │   ├─► QuickQuizCard (随机速记)
    │   ├─► ReviewCard (温故知新)
    │   └─► ExamHistoryCard (历史考试)
    │
    └─► ExamPage (答题页，Navigator.push)
        │
        ├─► AppBar
        │   ├─► title: 考试标题
        │   └─► TimerWidget (倒计时)
        │
        ├─► PageView.builder (逐题)
        │   └─► QuestionCard × N
        │       ├─► Text(stem)
        │       ├─► OptionsList (Radio/Checkbox/Input)
        │       │   ├─► RadioListTile (单选)
        │       │   ├─► CheckboxListTile (多选)
        │       │   ├─► SwitchListTile (判断)
        │       │   └─► TextField (填空/简答)
        │       └─► "AI讲解"按钮 (长按/完成后可用)
        │
        └─► ResultPage (成绩)
            ├─► ScoreDisplay (总分/满分)
            ├─► AnswerReview (逐题回顾)
            │   ├─► QuestionCard + 正确答案
            │   ├─► AIFeedback (AI 讲解)
            │   └─► SourceLink → 跳转 ReaderPage
            └─► Button("错题本") / Button("再来一次")
```

### 4.5 微服务部署架构

```
┌───────────────────────────────────────────────────────────────┐
│                    手机端（Flutter App）                        │
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  MicroServer (shelf)                                    │  │
│  │                                                         │  │
│  │  监听: 0.0.0.0:{port} (默认 8080)                       │  │
│  │                                                         │  │
│  │  ┌─ 中间件 ─────────────────────────────────────────┐   │  │
│  │  │  • CORS 中间件                                    │   │  │
│  │  │  • 日志中间件                                     │   │  │
│  │  │  • 认证中间件（可选，局域网场景可关闭）             │   │  │
│  │  └───────────────────────────────────────────────────┘   │  │
│  │                                                         │  │
│  │  ┌─ 路由 ───────────────────────────────────────────┐   │  │
│  │  │  GET  /api/files/list        → 文件列表           │   │  │
│  │  │  GET  /api/files/:id/read    → 读取文档           │   │  │
│  │  │  POST /api/files/upload      → 上传文件（需确认）  │   │  │
│  │  │  GET  /api/files/:id/download→ 下载文件           │   │  │
│  │  │  GET  /api/quiz/daily        → 每日一测题目       │   │  │
│  │  │  POST /api/quiz/submit       → 提交答案           │   │  │
│  │  │  POST /api/chat/ask          → AI 问答            │   │  │
│  │  │  GET  /                       → Web UI 首页        │   │  │
│  │  └───────────────────────────────────────────────────┘   │  │
│  │                                                         │  │
│  │  ┌─ 静态资源 ───────────────────────────────────────┐   │  │
│  │  │  assets/web/index.html                           │   │  │
│  │  │  assets/web/style.css                            │   │  │
│  │  │  assets/web/app.js                               │   │  │
│  │  └───────────────────────────────────────────────────┘   │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  WebDAV Backup Service                                  │  │
│  │  • 定时（workmanager）同步 wiki_root/ 和数据库文件       │  │
│  │  • 配置：webdav_url, webdav_user, webdav_pass           │  │
│  └─────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────┘
        │
        │ 局域网 WiFi
        ▼
┌───────────────────────────────────────────────────────────────┐
│  电脑/平板浏览器                                               │
│  http://{手机IP}:{port}                                       │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  Web UI (SPA)                                           │  │
│  │  • 文档阅读（Markdown 渲染）                             │  │
│  │  • 在线答题                                             │  │
│  │  • 文件上传（触发手机端确认弹窗）                         │  │
│  │  • 文件下载                                             │  │
│  │  • AI 问答                                              │  │
│  └─────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────┘
```

**上传确认流程**：
1. 浏览器 POST `/api/files/upload`
2. 服务端通过 WebSocket 或本地通知向 App 发送确认请求
3. App 弹出 `Dialog`：显示文件名、大小，用户点击"确认"或"拒绝"
4. 确认后服务端接收文件并存入 `wiki_root/`

---

## 五、开发阶段与里程碑

### P0 基础骨架（第 1-2 周）

**目标**：可交互的产品外壳，跑通导航和图谱渲染。

| 序号 | 文件 | 职责 | 依赖 |
|------|------|------|------|
| 1 | `main.dart` | 应用入口，初始化 ProviderScope、数据库 | - |
| 2 | `app.dart` | MaterialApp、主题、路由表（GoRouter） | - |
| 3 | `core/theme/app_theme.dart` | Material 3 主题定义 | - |
| 4 | `core/theme/text_styles.dart` | 字体排版 | - |
| 5 | `data/database/app_database.dart` | SQLite 单例、初始化、建表迁移 | - |
| 6 | `data/database/tables/*_table.dart` | 11 张表的建表 SQL | app_database |
| 7 | `data/models/*.dart` | 所有数据模型（含 fromMap/toMap） | - |
| 8 | `providers/database_provider.dart` | AppDatabase Riverpod Provider | app_database |
| 9 | `ui/shell/app_shell.dart` | 底部导航 + 顶部栏骨架 | - |
| 10 | `ui/shell/bottom_nav.dart` | 三栏底部导航（含 Chat 浮球） | - |
| 11 | `ui/shell/personal_drawer.dart` | 左侧抽屉（占位内容） | - |
| 12 | `ui/home/home_page.dart` | 首页卡片布局（静态占位） | - |
| 13 | `ui/wiki/wiki_page.dart` | 知识图谱页面骨架 | - |
| 14 | `ui/wiki/graph/graph_canvas.dart` | 图谱画布（CustomPaint 渲染节点+连线） | - |
| 15 | `ui/wiki/graph/graph_node.dart` | 节点 Widget | graph_canvas |
| 16 | `ui/wiki/graph/graph_edge.dart` | 连线 Widget | graph_canvas |
| 17 | `ui/wiki/graph/graph_controller.dart` | 缩放/拖拽/惯性控制 | graph_canvas |
| 18 | `ui/chat/chat_page.dart` | Chat 页面骨架 | - |
| 19 | `ui/quiz/quiz_page.dart` | 测验页面骨架 | - |

**里程碑验证**：
- [x] 应用启动，底部三栏导航正常切换
- [x] 知识图谱可渲染示例节点和连线
- [x] 图谱支持缩放、拖拽手势
- [x] 个人中心抽屉可滑出

---

### P1 Wiki 核心（第 3-6 周）

**目标**：类目管理、文档编辑/阅读、图谱交互完整闭环。

| 序号 | 文件 | 职责 | 依赖 |
|------|------|------|------|
| 20 | `data/dao/category_dao.dart` | 类目 CRUD（增删改查+树形查询） | app_database |
| 21 | `data/dao/document_dao.dart` | 文档 CRUD（含阅读统计更新） | app_database |
| 22 | `data/dao/reading_log_dao.dart` | 阅读日志 CRUD | app_database |
| 23 | `data/repositories/category_repository.dart` | 类目业务逻辑 | category_dao |
| 24 | `data/repositories/document_repository.dart` | 文档业务逻辑（含文件系统操作） | document_dao, file_service |
| 25 | `providers/category_provider.dart` | 类目列表状态 | category_repository |
| 26 | `providers/document_provider.dart` | 文档列表/详情状态 | document_repository |
| 27 | `providers/graph_provider.dart` | 图谱数据（节点=文档，连线=引用/标签） | document_provider |
| 28 | `services/file_service.dart` | 文件系统操作（读写 .md、目录管理） | - |
| 29 | `services/import_service.dart` | PDF/DOCX 导入转换 | file_service |
| 30 | `services/export_service.dart` | MD 导出 PDF/Word/Text | - |
| 31 | `services/tts_service.dart` | flutter_tts 封装 | - |
| 32 | `ui/wiki/category/category_panel.dart` | 右滑类目面板 | category_provider |
| 33 | `ui/wiki/category/category_tree.dart` | 层级目录树 | category_panel |
| 34 | `ui/wiki/editor/editor_page.dart` | 文档编辑页 | document_repository |
| 35 | `ui/wiki/editor/quill_editor.dart` | flutter_quill 封装 | editor_page |
| 36 | `ui/wiki/reader/reader_page.dart` | 沉浸式阅读页 | document_provider |
| 37 | `ui/wiki/reader/reader_toolbar.dart` | 阅读设置栏（字体/间距/背景） | reader_page |
| 38 | `ui/wiki/reader/citation_popup.dart` | 引用浮窗 | reader_page |
| 39 | `providers/stats_provider.dart` | 阅读统计（Top5/Bottom5） | reading_log_dao |

**里程碑验证**：
- [x] 类目树可展开/折叠，支持新建/重命名/删除/移动
- [x] 新建文档自动归入当前类目，编辑器所见即所得
- [x] PDF/DOCX 导入后转换为 MD，原文件保留
- [x] 图谱节点单击显示摘要，再次点击进入阅读
- [x] 沉浸式阅读支持 TTS、字体设置
- [x] 个人中心显示阅读统计

---

### P2 AI 与 Chat（第 7-10 周）

**目标**：AIProvider 跑通、RAG 问答可用、对话 UI 完整。

| 序号 | 文件 | 职责 | 依赖 |
|------|------|------|------|
| 40 | `ai/ai_provider.dart` | AIProvider 抽象接口定义 | - |
| 41 | `ai/cloud_ai_provider.dart` | 云端实现（dio + OpenAI 兼容 API） | ai_provider |
| 42 | `ai/ai_provider_factory.dart` | 工厂方法，根据配置创建 Provider | ai_provider, settings |
| 43 | `ai/prompt_manager.dart` | 提示词模板加载/变量替换 | - |
| 44 | `ai/embedding_service.dart` | 文本向量化 | ai_provider |
| 45 | `services/vector_store_service.dart` | sqlite-vec 向量表创建/写入/检索 | embedding_service |
| 46 | `services/rag_service.dart` | RAG 流水线（向量化→检索→组装→生成） | vector_store, ai_provider |
| 47 | `ai/agents/qa_agent.dart` | 问答 Agent 封装（含联网搜索判断：用户勾选"联网"且 Provider 为 Cloud 时，先调用 SearchAgent 再合并 RAG 上下文） | rag_service, prompt_manager, search_agent |
| 48 | `ai/agents/summarizer_agent.dart` | 摘要 Agent | ai_provider, prompt_manager |
| 49 | `data/dao/conversation_dao.dart` | 会话 CRUD | app_database |
| 50 | `data/dao/message_dao.dart` | 消息 CRUD | app_database |
| 51 | `data/repositories/conversation_repository.dart` | 会话业务逻辑 | conversation_dao, message_dao |
| 52 | `providers/conversation_provider.dart` | 会话列表状态 | conversation_repository |
| 53 | `providers/chat_provider.dart` | Chat 消息状态 + AI 调用 | qa_agent, conversation_repository |
| 54 | `ui/chat/conversation_list.dart` | 会话列表 | conversation_provider |
| 55 | `ui/chat/message_bubble.dart` | 消息气泡（含引用角标） | chat_provider |
| 56 | `ui/chat/message_input.dart` | 输入框（文字+语音+图片） | chat_provider, speech_service |
| 57 | `ui/chat/citation_widget.dart` | 引用角标+底部引用列表 | message_bubble |
| 58 | `ui/chat/archive_dialog.dart` | 归档为笔记对话框 | summarizer_agent |
| 59 | `services/speech_service.dart` | speech_to_text 封装 | - |
| 60 | `providers/settings_provider.dart` | 设置状态管理 | settings_dao |
| 61 | `ui/settings/settings_page.dart` | 设置主页面 | settings_provider |
| 62 | `ui/settings/ai_settings.dart` | AI 模型配置页面 | settings_provider |
| 63 | `assets/prompts/qa_with_rag.txt` | 问答 Agent 提示词模板 | - |
| 64 | `assets/prompts/summarizer.txt` | 摘要 Agent 提示词模板 | - |
| 64+ | `ai/agents/search_agent.dart` | 联网搜索 Agent，调用云端 API 的 enable_search 参数（仅 CloudAIProvider 可用） | ai_provider |

**里程碑验证**：
- [x] 配置云端 API Key 后，Chat 可正常对话
- [x] RAG 问答能检索知识库文档并给出引用
- [x] 引用角标可点击，弹出原文浮窗
- [x] 会话支持新建/删除/重命名/归档为笔记
- [x] 语音输入可转文字
- [x] 联网搜索仅云端 Provider 可用，本地模式下该选项隐藏

---

### P3 题库与测验（第 11-15 周）

**目标**：出题、四种测验流程、阅卷、错题本完整。

| 序号 | 文件 | 职责 | 依赖 |
|------|------|------|------|
| 65 | `ai/agents/quiz_agent.dart` | 出题 Agent（JSON 解析+去重） | ai_provider, prompt_manager |
| 66 | `ai/agents/grader_agent.dart` | 阅卷 Agent（简答题评分） | ai_provider, prompt_manager |
| 67 | `ai/agents/intent_agent.dart` | 意图识别 Agent | ai_provider, prompt_manager |
| 68 | `data/dao/question_dao.dart` | 题库 CRUD（含哈希去重） | app_database |
| 69 | `data/dao/exam_dao.dart` | 考试记录 CRUD | app_database |
| 70 | `data/dao/exam_answer_dao.dart` | 答题明细 CRUD | app_database |
| 71 | `data/dao/wrong_question_dao.dart` | 错题日志 CRUD | app_database |
| 72 | `data/dao/daily_task_dao.dart` | 每日一测配置 CRUD | app_database |
| 73 | `data/repositories/question_repository.dart` | 题库业务逻辑 | question_dao |
| 74 | `data/repositories/exam_repository.dart` | 考试业务逻辑（含阅卷编排） | exam_dao, exam_answer_dao, grader_agent |
| 75 | `providers/quiz_provider.dart` | 测验状态（入口/进行中/结果） | exam_repository |
| 76 | `providers/exam_provider.dart` | 考试进行中状态（当前题/答案/计时） | exam_repository |
| 77 | `services/notification_service.dart` | 本地通知封装 | - |
| 78 | `services/background_service.dart` | workmanager 后台任务注册 | quiz_agent, notification_service |
| 79 | `ui/quiz/exam/exam_page.dart` | 答题页面（PageView） | exam_provider |
| 80 | `ui/quiz/exam/question_card.dart` | 单题展示（支持 5 种题型） | exam_page |
| 81 | `ui/quiz/exam/timer_widget.dart` | 倒计时 | exam_page |
| 82 | `ui/quiz/exam/result_page.dart` | 成绩单 | exam_provider |
| 83 | `ui/quiz/wrong/wrong_list.dart` | 错题本列表 | quiz_provider |
| 84 | `ui/quiz/wrong/wrong_detail.dart` | 错题详情+AI讲解 | wrong_list |
| 85 | `ui/quiz/config/daily_config_page.dart` | 每日一测配置 | daily_task_dao |
| 86 | `ui/home/daily_card.dart` | 首页每日一测卡片 | quiz_provider |
| 87 | `ui/home/quick_card.dart` | 首页随机速记卡片 | quiz_provider |
| 88 | `ui/home/score_card.dart` | 首页最近成绩卡片 | exam_repository |
| 89 | `ui/home/wrong_card.dart` | 首页最近错题卡片 | wrong_question_dao |
| 90 | `assets/prompts/quiz_generator.txt` | 出题 Agent 提示词模板 | - |
| 91 | `assets/prompts/grader.txt` | 阅卷 Agent 提示词模板 | - |
| 92 | `assets/prompts/intent_analyzer.txt` | 意图识别 Agent 提示词模板 | - |
| 93 | `services/periodic_exam_service.dart` | 阶段考试预生成（月考/季考/年考前一天晚间 workmanager 触发，50-80 题） | quiz_agent, exam_repository |
| 94 | `services/external_app_launcher.dart` | 复制题干+指令到剪贴板，通过 URL Scheme 跳转 DeepSeek/豆包等 App | - |

**里程碑验证**：
- [x] 每日一测后台预生成，通知提醒后可直接答题
- [x] 随机速记基于最近阅读文件实时出题
- [x] 月考/季考/年考限时答题，AI 阅卷
- [x] 温故知新混合错题和新题
- [x] 客观题自动判分，简答题 AI 评分+解析
- [x] 成绩单可查看每题详情并跳转源文件
- [x] 错题本记录累计错误次数
- [x] 月考/季考/年考在考前一天晚间自动预生成 50-80 题
- [x] 本地模型用户可通过"一键复制并跳转"获取外部 App 讲解

---

### P4 微服务与备份（第 16-18 周）

**目标**：内嵌 HTTP 服务可用、WebDAV 备份跑通。

| 序号 | 文件 | 职责 | 依赖 |
|------|------|------|------|
| 93 | `services/micro_server/server.dart` | shelf HTTP 服务启动/停止 | - |
| 94 | `services/micro_server/router.dart` | REST API 路由注册 | server |
| 95 | `services/micro_server/handlers/file_handler.dart` | 文件列表/上传/下载 API | file_service |
| 96 | `services/micro_server/handlers/doc_handler.dart` | 文档阅读 API | document_repository |
| 97 | `services/micro_server/handlers/quiz_handler.dart` | 在线答题 API | exam_repository |
| 98 | `services/micro_server/handlers/ai_handler.dart` | AI 问答 API | rag_service |
| 99 | `services/backup_service.dart` | WebDAV 备份封装 | - |
| 100 | `ui/settings/server_settings.dart` | 微服务开关/端口配置 | settings_provider |
| 101 | `ui/settings/backup_settings.dart` | WebDAV 配置页面 | settings_provider |
| 102 | `assets/web/index.html` | Web UI 首页 | - |
| 103 | `assets/web/style.css` | Web UI 样式 | - |
| 104 | `assets/web/app.js` | Web UI 交互逻辑 | - |

**里程碑验证**：
- [x] 开启微服务后，电脑浏览器可访问手机 IP:端口
- [x] Web 端可阅读文档、在线答题
- [x] 上传文件需手机端确认
- [x] WebDAV 配置后可定时备份

---

### P5 本地模型与打磨（第 19-22 周）

**目标**：本地模型可用、UI/UX 打磨、测试完善。

| 序号 | 文件 | 职责 | 依赖 |
|------|------|------|------|
| 105 | `ai/local_ai_provider.dart` | 本地实现（llama_cpp_dart） | ai_provider |
| 106 | `services/model_download_service.dart` | 模型下载管理（断点续传+进度）+ 设备内存检测自动过滤推荐模型 | - |
| 107 | `ui/settings/model_download_page.dart` | 模型下载/管理页面 | model_download_service |
| 108 | `ui/settings/storage_settings.dart` | 存储路径配置 | settings_provider |
| 109 | 各 UI 文件 | 动效打磨（节点动画、页面转场、呼吸灯） | - |
| 110 | 各文件 | 异常处理完善（网络错误、AI 超时、文件损坏） | - |
| 111 | `test/unit/**` | DAO/Service/Provider 单元测试 | - |
| 112 | `test/widget/**` | 核心 Widget 测试 | - |
| 113 | `core/utils/device_utils.dart` | 设备内存/存储检测，供模型下载过滤推荐模型使用 | - |
| 114 | `services/prompt_remote_sync_service.dart` | 从云端 JSON 拉取最新提示词模板，覆盖本地默认模板（保留用户自定义） | prompt_manager, settings_dao |

**里程碑验证**：
- [x] 下载 .gguf 模型后可切换为本地推理
- [x] 本地模式下 RAG 问答正常（无联网）
- [x] UI 动效流畅，无明显卡顿
- [x] 单元测试覆盖率 > 70%
- [x] 设备内存不足时自动过滤不兼容的本地模型
- [x] 提示词模板支持云端远程更新（保留用户自定义）

---

### P6 API Key 安全存储（第 23 周）

**目标**：API Key 使用 flutter_secure_storage 加密存储，不再明文存入 SQLite。

| 序号 | 文件 | 职责 | 依赖 |
|------|------|------|------|
| 115 | `ui/settings/cloud_config_form.dart` | 云端配置表单（API Key 加密存储/读取/删除） | flutter_secure_storage, settings_provider |
| 116 | `pubspec.yaml` | 新增 flutter_secure_storage: ^9.0.0 | - |

**里程碑验证**：
- [x] API Key 存储在 Keychain（iOS）/ EncryptedSharedPreferences（Android），非明文
- [x] 切换云端厂商后 API Key 自动清空
- [x] 测试连接按钮可验证 Key 有效性

---

### P7 AI 模型配置（第 24-25 周）

**目标**：本地模型 + 云端模型统一配置界面，远程仓库拉取、多镜像下载、SHA256 校验、状态联动卡片。

| 序号 | 文件 | 职责 | 依赖 |
|------|------|------|------|
| 117 | `data/models/local_model.dart` | LocalModel 数据模型 + ModelStatus 枚举（5 种状态） + fromJson/toJson | - |
| 118 | `data/models/cloud_vendor.dart` | CloudVendor 云端厂商数据模型 + fromJson | - |
| 119 | `services/model_repo_service.dart` | 远程模型仓库 JSON 拉取/本地缓存 + 3 次重试指数退避 | dio |
| 120 | `services/cloud_vendor_service.dart` | 云端厂商 JSON 拉取/本地缓存 + 3 次重试指数退避 | dio |
| 121 | `services/model_download_service.dart` (增强) | 新增 downloadWithMirror（多镜像+SHA256 校验+.download 临时文件）、verifySha256、importLocalModel、modelsDir getter | crypto, dio |
| 122 | `providers/model_provider.dart` | ModelListNotifier（下载/加载/删除/导入）、modelListProvider、modelRepoServiceProvider、modelDownloadServiceProvider、localAiProviderRef | riverpod, model_repo_service, model_download_service |
| 123 | `ui/settings/model_card_widget.dart` | 状态联动卡片（5 种背景色 + 下载进度动画 + 动态操作按钮） | local_model |
| 124 | `ui/settings/cloud_config_form.dart` (增强) | 厂商下拉自动填充、API Key 安全存储、测试连接、Key URL 跳转 | cloud_vendor, cloud_vendor_service, flutter_secure_storage |
| 125 | `ui/settings/ai_settings.dart` (重构) | SegmentedButton 切换本地/云端 Tab，整合模型卡片列表和云端配置表单 | model_provider, cloud_config_form, model_card_widget |
| 126 | `ui/settings/model_download_page.dart` (增强) | ModelCardWidget 替换旧 _ModelTile、仓库地址输入、导入按钮 | model_provider, model_card_widget |
| 127 | `ui/settings/settings_page.dart` (微调) | 入口文案更新为"本地模型管理、云端 API 配置" | - |
| 128 | `pubspec.yaml` (扩展) | 新增 llama_cpp_dart, flutter_secure_storage, crypto, path_provider | - |

**里程碑验证**：
- [x] 本地 Tab：输入仓库地址 → 获取模型列表 → 选择镜像下载 → SHA256 校验通过 → 加载到内存
- [x] 云端 Tab：选择厂商自动填充配置 → 输入 API Key（加密存储）→ 测试连接成功
- [x] SegmentedButton 切换后 ai_type 持久化到 settings 表
- [x] 模型卡片 5 种状态联动（未下载/下载中/已下载/已加载/加载失败）
- [x] 网络请求失败时自动重试 3 次（指数退避 2/4/8 秒）
- [x] 导入本地 .gguf 文件可正常加载
- [x] 同一时间仅一个模型处于 loaded 状态

---

## 六、关键接口定义

### 6.1 AIProvider 接口

```dart
abstract class AIProvider {
  /// 生成对话回答（支持 RAG 上下文和历史消息）
  Future<AIResponse> generateAnswer({
    required String query,
    required List<String> contextDocs,
    List<ChatMessage> history = const [],
  });

  /// 生成题目（返回 JSON 解析后的 Question 列表）
  Future<QuizGenerationResult> generateQuiz({
    required String content,
    required int minCount,
    required int maxCount,
  });

  /// 意图识别（判断用户输入是提问还是知识点）
  Future<IntentResult> analyzeIntent({
    required String text,
    List<String> existingFiles = const [],
  });

  /// 文档/会话摘要
  Future<String> summarize({
    required String content,
    int maxLength = 200,
  });

  /// 简答题评分
  Future<GradeResult> gradeAnswer({
    required String question,
    required String referenceAnswer,
    required String userAnswer,
  });

  /// 生成文本向量（用于 RAG）
  Future<List<double>> generateEmbedding({
    required String text,
  });

  /// 释放资源
  void dispose();
}

// === 返回类型定义 ===

class AIResponse {
  final String content;
  final List<Citation> citations;
  final int tokenUsage;
  const AIResponse({required this.content, this.citations = const [], this.tokenUsage = 0});
}

class QuizGenerationResult {
  final String assessment;  // high / medium / low（内容信息密度）
  final List<Question> questions;
  const QuizGenerationResult({required this.assessment, required this.questions});
}

class GradeResult {
  final double score;
  final String feedback;
  final bool isCorrect;
  const GradeResult({required this.score, required this.feedback, required this.isCorrect});
}
```

### 6.2 DAO 抽象接口

```dart
// === CategoryDao ===
abstract class CategoryDao {
  Future<List<Category>> getAll();
  Future<List<Category>> getChildren(int parentId);
  Future<Category?> getById(int id);
  Future<int> insert(Category category);
  Future<void> update(Category category);
  Future<void> delete(int id);
  Future<void> move(int id, int newParentId);
}

// === DocumentDao ===
abstract class DocumentDao {
  Future<List<Document>> getByCategory(int categoryId, {bool includeDeleted = false});
  Future<Document?> getById(int id);
  Future<List<Document>> search(String query);
  Future<List<Document>> getRecentlyRead({int days = 7, int limit = 20});
  Future<List<Document>> getTopRead({int limit = 5, bool ascending = false});
  Future<int> insert(Document document);
  Future<void> update(Document document);
  Future<void> softDelete(int id);
  Future<void> restore(int id);
  Future<void> updateReadingStats(int docId, int durationSeconds);
}

// === ConversationDao ===
abstract class ConversationDao {
  Future<List<Conversation>> getAll({String status = 'active'});
  Future<Conversation?> getById(int id);
  Future<int> insert(Conversation conversation);
  Future<void> update(Conversation conversation);
  Future<void> delete(int id);
  Future<void> archive(int id, int wikiFileId);
}

// === MessageDao ===
abstract class MessageDao {
  Future<List<Message>> getByConversation(int conversationId, {int? limit, int offset = 0});
  Future<int> insert(Message message);
  Future<void> delete(int id);
  Future<void> deleteByConversation(int conversationId);
}

// === QuestionDao ===
abstract class QuestionDao {
  Future<List<Question>> getByIds(List<int> ids);
  Future<List<Question>> getBySourceFile(int docId);
  Future<List<Question>> getRandom({int limit = 10});
  Future<List<Question>> getWrongQuestions({int limit = 20});
  Future<int> insert(Question question);
  Future<int> upsertWithDedup(Question question);  // 哈希去重插入
  Future<void> batchInsert(List<Question> questions);
}

// === ExamDao ===
abstract class ExamDao {
  Future<List<Exam>> getAll({String? examType, int limit = 50});
  Future<Exam?> getById(int id);
  Future<int> insert(Exam exam);
  Future<void> update(Exam exam);
  Future<void> updateScore(int examId, double obtainedScore, String status);
}

// === ExamAnswerDao ===
abstract class ExamAnswerDao {
  Future<List<ExamAnswer>> getByExam(int examId);
  Future<int> insert(ExamAnswer answer);
  Future<void> update(ExamAnswer answer);
  Future<void> batchUpdateScores(int examId, List<ExamAnswer> answers);
}

// === WrongQuestionDao ===
abstract class WrongQuestionDao {
  Future<List<WrongQuestionLog>> getAll({int limit = 100});
  Future<WrongQuestionLog?> getByQuestion(int questionId);
  Future<void> upsert(int questionId);  // 存在则 wrongCount+1，否则新建
  Future<void> clear(int questionId);
}

// === DailyTaskDao ===
abstract class DailyTaskDao {
  Future<DailyTaskConfig?> getConfig();
  Future<void> saveConfig(DailyTaskConfig config);
}

// === ReadingLogDao ===
abstract class ReadingLogDao {
  Future<List<ReadingLog>> getByDoc(int docId);
  Future<List<ReadingLog>> getByDateRange(DateTime start, DateTime end);
  Future<int> insert(ReadingLog log);
  Future<Map<int, int>> getDocDurationSum({int days = 30});  // docId → totalSeconds
}

// === SettingsDao ===
abstract class SettingsDao {
  Future<String?> get(String key);
  Future<void> set(String key, String value);
  Future<void> delete(String key);
  Future<Map<String, String>> getAll();
}
```

### 6.3 Repository 接口

```dart
// === DocumentRepository ===
class DocumentRepository {
  final DocumentDao _docDao;
  final FileService _fileService;
  final VectorStoreService? _vectorStore;  // 可选

  Future<Document> createDocument({
    required int categoryId,
    required String title,
    String? initialContent,
  });

  Future<Document> importFile({
    required int categoryId,
    required String filePath,  // PDF/DOCX 路径
  });

  Future<String> readContent(int docId);

  Future<void> saveContent(int docId, String content);

  Future<void> deleteDocument(int docId);

  Future<void> startReadingLog(int docId);

  Future<void> endReadingLog(int docId, int durationSeconds);
}

// === ExamRepository ===
class ExamRepository {
  final ExamDao _examDao;
  final ExamAnswerDao _answerDao;
  final QuestionDao _questionDao;
  final WrongQuestionDao _wrongDao;
  final QuizAgent _quizAgent;
  final GraderAgent _graderAgent;

  /// 创建每日一测
  Future<Exam> createDailyQuiz(DailyTaskConfig config);

  /// 创建随机速记
  Future<Exam> createRandomQuiz(List<Document> recentDocs);

  /// 创建温故知新
  Future<Exam> createReviewQuiz({double wrongRatio = 0.5});

  /// 创建月度考试（考前一天晚间预生成 50-80 题）
  Future<Exam> createMonthlyExam();

  /// 创建季度考试
  Future<Exam> createQuarterlyExam();

  /// 创建年度考试
  Future<Exam> createYearlyExam();

  /// 提交单题答案
  Future<void> submitAnswer(int examId, int questionId, String userAnswer);

  /// 交卷（含自动判分+AI阅卷简答题）
  Future<ExamResult> finishExam(int examId);
}
```

### 6.4 核心 Service 接口

```dart
// === RagService ===
class RagService {
  final EmbeddingService _embedding;
  final VectorStoreService _vectorStore;
  final AIProvider _aiProvider;
  final PromptManager _promptManager;

  /// RAG 问答主流程
  Future<AIResponse> answer({
    required String query,
    required int conversationId,
    int topK = 5,
  });
}

// === MicroServer ===
class MicroServer {
  HttpServer? _server;
  final int port;

  Future<void> start();
  Future<void> stop();
  bool get isRunning;

  // 上传确认回调
  Stream<UploadRequest> get uploadRequests;
  void confirmUpload(String requestId);
  void rejectUpload(String requestId);
}
```

---

## 七、关键依赖清单（pubspec.yaml）

```yaml
dependencies:
  flutter:
    sdk: flutter

  # 状态管理
  flutter_riverpod: ^2.x
  riverpod_annotation: ^2.x

  # 数据库
  sqflite: ^2.x
  path_provider: ^2.x
  sqlite_vec: ^0.1.x              # 可选，本地向量检索

  # 网络
  dio: ^5.x

  # 本地模型
  llama_cpp_dart: ^0.1.x          # llama.cpp 绑定

  # 富文本/Markdown
  flutter_quill: ^9.x
  flutter_markdown: ^0.6.x

  # 文件处理
  file_picker: ^6.x
  path: ^1.x

  # 语音
  flutter_tts: ^3.x
  speech_to_text: ^6.x

  # 后台与通知
  workmanager: ^0.5.x
  flutter_local_notifications: ^17.x

  # HTTP 服务
  shelf: ^1.x
  shelf_static: ^1.x

  # WebDAV
  webdav_client: ^2.x

  # 安全存储
  flutter_secure_storage: ^9.x     # API Key 加密存储

  # 工具
  uuid: ^4.x
  crypto: ^3.x                    # 哈希去重、SHA256 校验
  intl: ^0.19.x                   # 日期格式化

dev_dependencies:
  flutter_test:
    sdk: flutter
  riverpod_generator: ^2.x
  build_runner: ^2.x
  mocktail: ^1.x
  integration_test:
    sdk: flutter
```

---

## 八、验证方案

### 阶段验收标准

每个阶段完成后执行以下验证：

1. **编译检查**：`flutter analyze` 无错误
2. **单元测试**：`flutter test` 全部通过
3. **运行验证**：`flutter run` 在模拟器/真机上可正常操作
4. **集成测试**：核心流程（P1 文档CRUD、P2 Chat问答、P3 答题交卷）端到端跑通

### 关键集成测试用例

| 测试 | 覆盖阶段 | 验证内容 |
|------|----------|----------|
| `test_wiki_crud` | P1 | 新建类目→新建文档→编辑→保存→阅读→删除 |
| `test_rag_chat` | P2 | 配置API→新建文档→Chat提问→验证引用 |
| `test_daily_quiz` | P3 | 配置每日一测→手动触发→答题→交卷→查看成绩 |
| `test_exam_grading` | P3 | 客观题自动判分+简答题AI评分 |
| `test_micro_server` | P4 | 启动服务→浏览器访问→阅读文档→上传确认 |
