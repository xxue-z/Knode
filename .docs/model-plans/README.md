# 知维（Knode）优化实施计划总览

> 基于《阶段7点优化方案》，对 G1~G7 逐项制定详细实施计划。
> **所有计划需审核通过后方可修改代码。**

## 计划文件清单

| 编号 | 功能 | 文件 | 预估工作量 | 状态 |
|------|------|------|-----------|------|
| G1 | 知识图谱连线 + 标签体系 | [G1-knowledge-graph-tags.md](G1-knowledge-graph-tags.md) | 3 天 | ✅ 已完成 |
| G2 | 月度/季度/年度考试预生成 | [G2-periodic-exam.md](G2-periodic-exam.md) | 2 天 | ✅ 已完成 |
| G3 | 联网搜索 Agent | [G3-web-search.md](G3-web-search.md) | 1.5 天 | ✅ 已完成 |
| G4 | 提示词模板管理 | [G4-prompt-management.md](G4-prompt-management.md) | 1.5 天 | ✅ 已完成 |
| G5 | 设备内存检测与模型推荐 | [G5-device-memory.md](G5-device-memory.md) | 1 天 | 待执行 |
| G6 | WebDAV 备份优化 | [G6-backup-optimization.md](G6-backup-optimization.md) | 1.5 天 | 待执行 |
| G7 | 日志系统 | [G7-logging-system.md](G7-logging-system.md) | 1.5 天 | 待执行 |
| G8 | 硬编码中文修复 | [G8-i18n-hardcoded-fix.md](G8-i18n-hardcoded-fix.md) | 2 天 | 待执行 |

### G9 阅读器增强功能（分 6 个子计划）

| 编号 | 功能 | 文件 | 预估工作量 | 状态 |
|------|------|------|-----------|------|
| G9-1 | 数据层（表、模型、DAO） | [G9-1-data-layer.md](G9-1-data-layer.md) | 1.5 天 | 待执行 |
| G9-2 | Markdown 渲染与高亮系统 | [G9-2-markdown-rendering.md](G9-2-markdown-rendering.md) | 2 天 | 待执行 |
| G9-3 | 上下文工具栏（9 项菜单） | [G9-3-context-toolbar.md](G9-3-context-toolbar.md) | 2 天 | 待执行 |
| G9-4 | 侧滑面板与标题导航 | [G9-4-swipe-panels-heading-nav.md](G9-4-swipe-panels-heading-nav.md) | 1.5 天 | 待执行 |
| G9-5 | 字典服务 | [G9-5-dictionary-service.md](G9-5-dictionary-service.md) | 1 天 | 待执行 |
| G9-6 | 设置界面模块化 | [G9-6-settings-restructure.md](G9-6-settings-restructure.md) | 1.5 天 | 待执行 |

**G9 总计**：约 9.5 人天

**总计**：约 23.5 人天

## 修复计划

| 编号 | 关联 | 文件 | 说明 |
|------|------|------|------|
| G2-fix | G2 | [G2-fix-plan.md](G2-fix-plan.md) | G2 审核发现的 9 个问题修复（已修复） |
| G3-fix | G3 | [G3-fix-plan.md](G3-fix-plan.md) | G3 审核发现的 15 个问题修复（已修复） |
| G4-fix | G4 | — | G4 审核发现的 12 个问题修复（已修复，见提交 c292b06） |

## 推荐实施顺序

```
Phase 1（基础设施）
  └── G7 日志系统 ──────────────────────────→ 其他模块开发时可使用日志

Phase 2（核心能力，可并行）
  ├── G1 知识图谱+标签 ─────────────────────→ 基础导航能力
  ├── G5 内存检测 ──────────────────────────→ 稳定性保障
  └── G6 备份优化 ──────────────────────────→ 数据安全

Phase 3（功能增强，可并行）
  ├── G2 阶段考试 ──────────────────────────→ 学习闭环
  ├── G3 联网搜索 ──────────────────────────→ 用户体验
  └── G4 提示词管理 ────────────────────────→ 高级配置

Phase 4（阅读器增强，按序执行）
  ├── G9-1 数据层 ─────────────────────────→ 表结构 + 模型 + DAO
  ├── G9-2 Markdown 渲染 + 高亮 ──────────→ 核心渲染改造
  ├── G9-3 上下文工具栏 ──────────────────→ 9 项菜单
  ├── G9-4 侧滑面板 + 标题导航 ──────────→ 手势导航
  ├── G9-5 字典服务 ──────────────────────→ 在线词典查询
  └── G9-6 设置模块化 ────────────────────→ 设置界面重构
```

## 各计划现状分析摘要

| 编号 | 已有 | 缺失 | 类型 |
|------|------|------|------|
| G1 | 图谱 UI 层完整；graph_provider 内联 Jaccard | 无 tags/links_to 字段；无 TagGeneratorAgent；无 graph_service | 设计空白 |
| G2 | PeriodicExamService + ExamRepository 已有；workmanager 已集成 | callbackDispatcher 是 stub；QuizAgent 未接入；无专属 UI | 执行遗漏 |
| G3 | SearchAgent 已实现（支持 DeepSeek/OpenAI） | ~~无 enable_web_search 字段；无搜索开关 UI；无第三方搜索回退~~ | ✅ 已完成 |
| G4 | PromptManager 支持用户覆盖；saveCustomTemplate 可持久化 | ~~无管理 UI；settings 无入口；无导入导出~~ | ✅ 已完成 |
| G5 | getAvailableMemory() 存在；isModelSupported() 存在但是死代码 | 无 getTotalMemoryInGB()；无下载过滤；无内存警告 | 执行遗漏 |
| G6 | BackupService 有基础 backup/restore | 无 zip 压缩；逐文件上传；无备份列表 | 代码缺陷 |
| G7 | 无 | 无 AppLogger；main.dart 无全局异常捕获；无日志查看 | 执行遗漏 |
| G9 | reader_page.dart 有基础文本选择（3 项菜单）；TTS 已集成 | 无 Markdown 渲染；无书签/高亮/笔记；无字典；无标题导航；设置不持久化 | 功能增强 |

## 跨模块依赖

- **G7 → 其他所有模块**：日志系统是基础设施，其他模块开发时需要日志支持
- **G1 数据库迁移**：独立于其他模块的数据库变更 ✅
- **G2 数据库迁移**：独立于 G1 的数据库变更 ✅
- **G3 数据库迁移**：独立于 G1/G2 的数据库变更 ✅（已完成，conversation_table 新增 enable_web_search 列）
- **G9 内部依赖**：G9-1 → G9-2 → G9-3 → G9-4，G9-5 可与 G9-3 并行，G9-6 可独立执行
- **G9 跨模块依赖**：G9-1 依赖 G7（日志），G9-6 需迁移现有设置页面内容

G5-G8 无数据库迁移需求。G9-1 需数据库迁移（新增 bookmarks/highlights 表 + documents 加列）。

## 审核清单

审核每个计划时请检查：

- [ ] 现状分析是否准确（对照实际代码）
- [ ] 文件清单是否完整（无遗漏）
- [ ] 实施步骤是否可执行（有具体代码示例）
- [ ] 依赖关系是否正确
- [ ] 验收标准是否可测试
- [ ] 风险是否充分识别
- [ ] **是否包含「代码验证」章节（必须执行 `dart analyze` + `flutter test` + `dart run monolith_runner:localization` + 硬编码扫描）**

## ⚠️ 代码验证要求（所有计划必须遵守）

> **每个实施步骤完成后、提交代码前，必须通过验证命令。未通过验证的代码禁止提交。**

所有 G3-G8 实施计划（含修复计划）均包含「代码验证」章节，定义了：

1. **验证命令**：`dart analyze`、`flutter test`、`dart run monolith_runner:localization`、硬编码中文扫描
2. **验证标准**：0 error、0 warning（新增代码）、0 测试失败、0 硬编码中文
3. **验证时机**：每个步骤完成后立即验证，不能等到最后

这是强制性验收环节，不可跳过。
