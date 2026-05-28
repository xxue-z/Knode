# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

**知维（Knode）** 是一款以手机为核心的个人知识管理 Flutter 应用，融合 Wiki 文档管理、AI 智能问答（RAG）、智能题库与测验、手机端微服务四大能力。

## 技术栈

- **框架**: Flutter 3.x（跨平台）
- **本地数据库**: SQLite（sqflite）
- **向量数据库**: sqlite-vec，用于本地 RAG 语义检索（可选）
- **AI 抽象层**: 可插拔 AIProvider 接口
  - 云端：兼容 OpenAI 格式的 API（DeepSeek 等），通过 dio 调用
  - 本地：llama.cpp（llama_cpp_dart），加载 .gguf 量化模型离线推理
- **富文本编辑器**: flutter_quill（所见即所得 Markdown）
- **语音**: flutter_tts（朗读）、speech_to_text（语音输入）
- **后台任务**: workmanager
- **本地通知**: flutter_local_notifications
- **内嵌 HTTP 服务**: shelf（Dart）
- **WebDAV 备份**: webdav_client
- **状态管理**: Provider / Riverpod

## 架构设计

```
UI 层（知识图谱、Chat、测验、成绩单）
    ↓
业务逻辑层（Provider/Riverpod）
    ↓
AI 抽象层（AIProvider 接口）
    ├── CloudAIProvider（HTTP，兼容 OpenAI）
    └── LocalAIProvider（llama.cpp，.gguf 模型）
    ↓
数据与存储层（SQLite + 文件系统 + 可选 sqlite-vec）
```

核心设计决策：
- **AIProvider 接口**是核心抽象，所有 AI 调用通过它进行，切换 Provider 对业务层透明。
- **RAG 流水线**：用户提问 → 向量化 → sqlite-vec 检索 Top K 文档片段 → 组装 Prompt → AIProvider.generateAnswer → 解析引用。
- **知识图谱**替代传统文件树，作为主要导航范式。
- **Agent** 均为提示词驱动：问答、出题、阅卷、意图识别、摘要，各有专用系统提示词模板（`assets/prompts/`）。

## 数据库

SQLite 共 11 张核心表：`categories`、`documents`、`conversations`、`messages`、`questions`、`exams`、`exam_answers`、`wrong_question_log`、`daily_task_config`、`reading_logs`、`settings`。完整表结构见 `docs/立项文档 v1.3.md`。

## 开发阶段

| 阶段 | 范围 | 预估周期 |
|------|------|----------|
| P0 | 基础骨架：路由、导航、知识图谱渲染 | 2 周 |
| P1 | Wiki 核心：类目、文档编辑/阅读、TTS | 4 周 |
| P2 | AI 与 Chat：AIProvider、RAG、对话 UI | 4 周 |
| P3 | 题库与测验：出题、考试、阅卷、错题本 | 5 周 |
| P4 | 微服务与 WebDAV 备份 | 3 周 |
| P5 | 本地模型管理、UI/UX 打磨 | 4 周 |

## 常用命令

```bash
# 初始化 Flutter 项目（尚未初始化时）
flutter create --org com.knode knode

# 运行应用
flutter run

# 指定设备运行
flutter run -d <device_id>

# 运行测试
flutter test

# 运行单个测试文件
flutter test test/path/to/test.dart

# 代码分析
flutter analyze

# 构建 Release APK
flutter build apk --release

# 构建 Release iOS
flutter build ios --release
```

## 约定

- 文档统一存储为 `.md` 文件，位于 `wiki_root/` 下；原始附件（PDF/DOCX）保留并关联。
- AI 提示词模板存放在 `assets/prompts/`（如 `quiz_generator.txt`、`qa_with_rag.txt`）。
- 配置项以键值对形式存储在 `settings` 表中。
- 题目类型：`single_choice`、`multi_choice`、`true_false`、`fill_blank`、`short_answer`。
- 考试类型：`daily`、`random`、`monthly`、`quarterly`、`yearly`、`review`。
