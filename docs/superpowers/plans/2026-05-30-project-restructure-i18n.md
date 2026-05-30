# 项目结构重组 + 国际化实施计划

> **For agentic workers:** 按模块顺序执行，每阶段完成后运行 `flutter analyze` 确认无错误。

**Goal:** 将 Flutter 单体项目拆分为 Dart Workspaces + Melos monorepo，同步接入 monolith_localization 国际化。

**Architecture:** 6 个 package（core、wiki、chat、quiz、micro_server）+ 1 个 app shell（knode_app）。core 被所有模块依赖，模块间不允许跨依赖。每个模块自带 CSV 翻译文件。

**Tech Stack:** Flutter 3.x、Dart Workspaces、Melos、monolith_localization（CSV）、Riverpod 2.x

**Spec:** `.docs/specs/2026-05-30-project-restructure-i18n-design.md`

**Branch:** `feature/monorepo-restructure`

---

## 迁移原则

1. **git mv 移动文件**，保留 Git 历史
2. **移动后修改** import 路径、常量引用，不新建重复文件
3. 每个模块完成后运行 `flutter analyze`，确认 0 error
4. Import 路径统一使用 `package:模块名/` 前缀
5. barrel export 文件（`模块名.dart`）导出模块公开 API

---

## Import 路径转换规则

移动文件后，import 路径按以下规则替换：

| 场景 | 原 import | 新 import |
|------|-----------|-----------|
| core 内部引用 | `import 'package:knode/core/...'` | `import 'package:core/...'` |
| core 数据层 | `import 'package:knode/data/...'` | `import 'package:core/database/...'` 或 `import 'package:core/models/...'` |
| core AI 层 | `import 'package:knode/ai/...'` | `import 'package:core/ai/...'` |
| wiki 模块 | `import 'package:knode/ui/wiki/...'` | `import 'package:wiki/screens/...'` |
| chat 模块 | `import 'package:knode/ui/chat/...'` | `import 'package:chat/screens/...'` |
| quiz 模块 | `import 'package:knode/ui/quiz/...'` | `import 'package:quiz/screens/...'` |
| micro_server | `import 'package:knode/services/micro_server/...'` | `import 'package:micro_server/...'` |
| App shell | `import 'package:knode/ui/home/...'` | `import 'package:knode_app/screens/...'` |

---

## 执行进度总览

| Phase | 模块 | 状态 | Commit | 文件数 |
|-------|------|------|--------|--------|
| 0 | 基础设施 | ✅ 完成 | workspace root + melos.yaml + 6 package 骨架 | 9 |
| 1 | core | ✅ 完成 | 数据层/AI层/工具/服务/Provider/提示词 全部迁入 | ~80 |
| 2 | micro_server | ✅ 完成 | 微服务文件 + web 前端资源迁出 | 6 |
| 3 | quiz | ✅ 完成 | UI/Provider/服务/Agent 全部迁入 | 13 |
| 4 | wiki | ❌ 待执行 | — | — |
| 5 | chat | ❌ 待执行 | — | — |
| 6 | App shell | ❌ 待执行 | — | — |
| 7 | 清理 | ❌ 待执行 | — | — |

---

## ✅ Phase 0: Monorepo 基础设施 — 已完成

### Task 0.1: 创建 Dart Workspace 配置 ✅

- [x] 创建根 `pubspec.yaml`，声明 workspace 成员
- [x] 创建 `melos.yaml`，配置 scripts（analyze、test、format、fix、get）
- [x] 创建 `analysis_options.yaml` 为全局 lint 规则
- [x] 创建 `apps/` 和 `packages/` 目录结构
- [x] 验证：`dart pub get` 在根目录成功运行

---

## ✅ Phase 1: Core 模块 — 已完成

> 最大最核心的模块，被所有其他模块依赖。包含数据库、AI 抽象层、工具类、基础服务。

### Task 1.1: 创建 core 包结构 ✅
### Task 1.2: 迁移核心工具层 ✅
- `lib/core/constants/`、`extensions/`、`utils/`、`tokenizer/`、`theme/` → `packages/core/lib/`
- 13 个文件，9 个文件更新 import

### Task 1.3: 迁移数据层 ✅
- `lib/data/database/`、`models/`、`dao/`、`repositories/` → `packages/core/lib/`
- 41 个文件，42 个文件更新 import
- 已知问题：3 个 repository 有反向依赖（引用 `lib/services/`、`lib/ai/`），需后续重构

### Task 1.4: 迁移 AI 抽象层 ✅
- `lib/ai/` 下 6 个核心文件 → `packages/core/lib/ai/`
- 11 个文件更新 import
- `lib/ai/agents/` 保留，后续分到各模块

### Task 1.5: 迁移基础服务 ✅
- 18 个服务文件 → `packages/core/lib/services/`
- 9 个文件更新 import

### Task 1.6: 迁移全局 Provider ✅
- 5 个全局 Provider → `packages/core/lib/providers/`
- 9 个文件更新 import

### Task 1.7: 迁移系统提示词 ✅
- 6 个 `.txt` 提示词 → `packages/core/assets/prompts/`
- PromptManager asset 路径无需修改（相对路径一致）

### Task 1.8-1.10: core i18n + barrel export + 验证 ✅
- `core_en.csv` 62 条
- barrel export 完整导出所有子模块
- `dart analyze` 0 error

---

## ✅ Phase 2: Micro Server 模块 — 已完成

### Task 2.1-2.5: 拆分 micro_server ✅
- 6 个源文件迁移（server、router、4 个 handler）
- Web 前端资源迁到 `apps/knode_app/assets/web/`
- `micro_server_en.csv` 30 条
- `dart analyze` 0 error
- 已知变更：`MicroServer` 构造函数 API 从 `pipeline: Pipeline Function(Pipeline)` 改为 `handler: Handler`

---

## ✅ Phase 3: Quiz 模块 — 已完成

### Task 3.1-3.5: 拆分 quiz ✅
- 13 个文件迁移（8 UI + 2 Provider + 1 服务 + 2 Agent）
- UI 子目录已扁平化（config/exam/wrong → screens/）
- `quiz_en.csv` 80+ 条
- 架构变更：`result_page.dart` 改用回调 `onSourceDocumentTap(int docId)` 替代直接导入 ReaderPage
- 已知 5 个预存 bug（非迁移导致）：
  1. `ExamRepository.createExam` 未定义（2 处）
  2. `wrong_detail.dart` `asMap()` 类型错误
  3. `wrong_detail.dart` 参数类型不匹配

---

## ❌ Phase 4: Wiki 模块 — 待执行

> 最复杂的模块，含知识图谱、Markdown 编辑器、RAG、TTS。

### Task 4.1: 创建 wiki 包结构

- [ ] 更新 `packages/wiki/pubspec.yaml`，添加依赖（core、flutter_quill、flutter_riverpod、path 等）
- [ ] 创建 `packages/wiki/lib/wiki.dart` barrel export
- [ ] 创建子目录：`agents/`、`services/`、`providers/`、`screens/`、`widgets/`、`l10n/`

### Task 4.2: 迁移 Wiki UI（12 个文件）

**git mv 操作：**

| 原路径 | 目标路径 |
|--------|----------|
| `lib/ui/wiki/wiki_page.dart` | `packages/wiki/lib/screens/wiki_page.dart` |
| `lib/ui/wiki/editor/editor_page.dart` | `packages/wiki/lib/screens/editor_page.dart` |
| `lib/ui/wiki/editor/quill_editor.dart` | `packages/wiki/lib/screens/quill_editor.dart` |
| `lib/ui/wiki/reader/reader_page.dart` | `packages/wiki/lib/screens/reader_page.dart` |
| `lib/ui/wiki/reader/reader_toolbar.dart` | `packages/wiki/lib/screens/reader_toolbar.dart` |
| `lib/ui/wiki/reader/citation_popup.dart` | `packages/wiki/lib/screens/citation_popup.dart` |
| `lib/ui/wiki/category/category_tree.dart` | `packages/wiki/lib/screens/category_tree.dart` |
| `lib/ui/wiki/category/category_panel.dart` | `packages/wiki/lib/screens/category_panel.dart` |
| `lib/ui/wiki/graph/graph_canvas.dart` | `packages/wiki/lib/widgets/graph_canvas.dart` |
| `lib/ui/wiki/graph/graph_controller.dart` | `packages/wiki/lib/widgets/graph_controller.dart` |
| `lib/ui/wiki/graph/graph_edge.dart` | `packages/wiki/lib/widgets/graph_edge.dart` |
| `lib/ui/wiki/graph/graph_node.dart` | `packages/wiki/lib/widgets/graph_node.dart` |

- 扁平化子目录：editor/reader/category → screens/，graph → widgets/
- 更新所有 import 路径

### Task 4.3: 迁移 Wiki Provider（3 个文件）

**git mv 操作：**

| 原路径 | 目标路径 |
|--------|----------|
| `lib/providers/category_provider.dart` | `packages/wiki/lib/providers/category_provider.dart` |
| `lib/providers/document_provider.dart` | `packages/wiki/lib/providers/document_provider.dart` |
| `lib/providers/graph_provider.dart` | `packages/wiki/lib/providers/graph_provider.dart` |

### Task 4.4: 迁移 Wiki 服务与 Agent（3 个文件）

**git mv 操作：**

| 原路径 | 目标路径 |
|--------|----------|
| `lib/services/import_service.dart` | `packages/wiki/lib/services/import_service.dart` |
| `lib/services/export_service.dart` | `packages/wiki/lib/services/export_service.dart` |
| `lib/ai/agents/summarizer_agent.dart` | `packages/wiki/lib/agents/summarizer_agent.dart` |

### Task 4.5: 创建 wiki i18n & 验证

- [ ] 创建 `packages/wiki/lib/l10n/wiki_en.csv`（预期 80+ 条）
- [ ] 更新 barrel export
- [ ] `dart analyze packages/wiki/` 通过
- [ ] Commit: `feat: 拆分 wiki 模块到 packages/wiki`

---

## ❌ Phase 5: Chat 模块 — 待执行

### Task 5.1: 创建 chat 包结构

- [ ] 更新 `packages/chat/pubspec.yaml`，添加依赖（core、flutter_riverpod、path 等）
- [ ] 创建 `packages/chat/lib/chat.dart` barrel export
- [ ] 创建子目录：`agents/`、`providers/`、`screens/`、`widgets/`、`l10n/`

### Task 5.2: 迁移 Chat UI（6 个文件）

**git mv 操作：**

| 原路径 | 目标路径 |
|--------|----------|
| `lib/ui/chat/chat_page.dart` | `packages/chat/lib/screens/chat_page.dart` |
| `lib/ui/chat/message_input.dart` | `packages/chat/lib/screens/message_input.dart` |
| `lib/ui/chat/message_bubble.dart` | `packages/chat/lib/screens/message_bubble.dart` |
| `lib/ui/chat/citation_widget.dart` | `packages/chat/lib/screens/citation_widget.dart` |
| `lib/ui/chat/conversation_list.dart` | `packages/chat/lib/screens/conversation_list.dart` |
| `lib/ui/chat/archive_dialog.dart` | `packages/chat/lib/screens/archive_dialog.dart` |

### Task 5.3: 迁移 Chat Provider（2 个文件）

**git mv 操作：**

| 原路径 | 目标路径 |
|--------|----------|
| `lib/providers/chat_provider.dart` | `packages/chat/lib/providers/chat_provider.dart` |
| `lib/providers/conversation_provider.dart` | `packages/chat/lib/providers/conversation_provider.dart` |

### Task 5.4: 迁移 Chat Agent（3 个文件）

**git mv 操作：**

| 原路径 | 目标路径 |
|--------|----------|
| `lib/ai/agents/qa_agent.dart` | `packages/chat/lib/agents/qa_agent.dart` |
| `lib/ai/agents/intent_agent.dart` | `packages/chat/lib/agents/intent_agent.dart` |
| `lib/ai/agents/search_agent.dart` | `packages/chat/lib/agents/search_agent.dart` |

### Task 5.5: 创建 chat i18n & 验证

- [ ] 创建 `packages/chat/lib/l10n/chat_en.csv`（预期 60+ 条）
- [ ] 更新 barrel export
- [ ] `dart analyze packages/chat/` 通过
- [ ] Commit: `feat: 拆分 chat 模块到 packages/chat`

---

## ❌ Phase 6: App Shell 组装 — 待执行

> 最后阶段，将所有模块通过 App shell 连接起来。

### Task 6.1: 创建 knode_app 包结构

- [ ] 更新 `apps/knode_app/pubspec.yaml`，添加对所有 5 个模块的 path 依赖
- [ ] 确保 `apps/knode_app/lib/main.dart` 和 `app.dart` 存在
- [ ] 创建子目录：`router/`、`providers/`、`screens/`、`l10n/`

### Task 6.2: 迁移 Shell 与 Home（8 个文件）

**git mv 操作：**

| 原路径 | 目标路径 |
|--------|----------|
| `lib/ui/shell/app_shell.dart` | `apps/knode_app/lib/screens/app_shell.dart` |
| `lib/ui/shell/bottom_nav.dart` | `apps/knode_app/lib/screens/bottom_nav.dart` |
| `lib/ui/shell/personal_drawer.dart` | `apps/knode_app/lib/screens/personal_drawer.dart` |
| `lib/ui/home/home_page.dart` | `apps/knode_app/lib/screens/home_page.dart` |
| `lib/ui/home/daily_card.dart` | `apps/knode_app/lib/screens/daily_card.dart` |
| `lib/ui/home/quick_card.dart` | `apps/knode_app/lib/screens/quick_card.dart` |
| `lib/ui/home/score_card.dart` | `apps/knode_app/lib/screens/score_card.dart` |
| `lib/ui/home/wrong_card.dart` | `apps/knode_app/lib/screens/wrong_card.dart` |

### Task 6.3: 迁移 Settings（8 个文件）

**git mv 操作：**

| 原路径 | 目标路径 |
|--------|----------|
| `lib/ui/settings/settings_page.dart` | `apps/knode_app/lib/screens/settings_page.dart` |
| `lib/ui/settings/ai_settings.dart` | `apps/knode_app/lib/screens/ai_settings.dart` |
| `lib/ui/settings/backup_settings.dart` | `apps/knode_app/lib/screens/backup_settings.dart` |
| `lib/ui/settings/cloud_config_form.dart` | `apps/knode_app/lib/screens/cloud_config_form.dart` |
| `lib/ui/settings/model_card_widget.dart` | `apps/knode_app/lib/screens/model_card_widget.dart` |
| `lib/ui/settings/model_download_page.dart` | `apps/knode_app/lib/screens/model_download_page.dart` |
| `lib/ui/settings/server_settings.dart` | `apps/knode_app/lib/screens/server_settings.dart` |
| `lib/ui/settings/storage_settings.dart` | `apps/knode_app/lib/screens/storage_settings.dart` |

### Task 6.4: 迁移全局 Provider

- [ ] `git mv lib/providers/theme_provider.dart` → `apps/knode_app/lib/providers/`
- [ ] 新建 `apps/knode_app/lib/providers/locale_provider.dart`（读写 settings 表 language 配置）

### Task 6.5: 迁移资源文件

- [ ] `git mv lib/assets/web/` → `apps/knode_app/assets/web/`（如未在 Task 2.3 完成）
- [ ] `git mv` 字体文件到 `apps/knode_app/assets/fonts/`（如有）

### Task 6.6: 更新路由配置

- [ ] 更新 `app_router.dart`，所有 import 指向新 package 路径
- [ ] 配置 monolith_localization 初始化

### Task 6.7: 创建 app i18n & 验证

- [ ] 创建 `apps/knode_app/lib/l10n/app_en.csv`
- [ ] `flutter analyze` 在根目录通过
- [ ] `flutter build apk --release` 成功
- [ ] Commit: `feat: 完成 App shell 组装，项目重组完成`

---

## ❌ Phase 7: 清理与收尾 — 待执行

### Task 7.1: 清理旧目录

- [ ] 确认 `lib/` 目录下所有文件已迁移（应为空）
- [ ] 删除空的 `lib/` 目录
- [ ] 更新 `.gitignore`（如有需要）
- [ ] Commit: `chore: 清理旧 lib/ 目录`

### Task 7.2: 更新文档

- [ ] 更新 `CLAUDE.md` 中的目录结构说明
- [ ] 更新常用命令（`melos analyze`、`melos test` 等）
- [ ] Commit: `docs: 更新项目文档，反映 monorepo 结构`

---

## 验收检查清单

- [ ] `lib/` 目录为空或已删除
- [ ] `flutter analyze` 全量通过
- [ ] `flutter build apk --release` 成功
- [ ] 每个 package 的 `pubspec.yaml` 正确声明依赖和 assets
- [ ] 所有 barrel export 文件正确导出公开 API
- [ ] CSV 翻译文件已创建
- [ ] App 可正常启动
