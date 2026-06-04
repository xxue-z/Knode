import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'app.dart';
import 'dart:ui';

import 'package:core/core.dart';
import 'package:chat/providers/conversation_provider.dart';
import 'package:core/services/app_logger.dart';
import 'package:wiki/wiki.dart';
import 'package:quiz/quiz.dart';
import 'providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLogger.instance.init(minLevel: AppLogLevel.debug);

  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.instance.e(
      'Flutter 框架错误',
      tag: 'FlutterError',
      error: details.exception,
      stackTrace: details.stack,
    );
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    AppLogger.instance.f(
      '未捕获的异步异常',
      tag: 'PlatformDispatcher',
      error: error,
      stackTrace: stack,
    );
    return true;
  };

  try {
    await AppDatabase.instance.init();
  } catch (e, st) {
    FlutterError.reportError(FlutterErrorDetails(exception: e, stack: st));
  }
  await loadSavedLocale();

  // 获取应用文档目录用于文件服务
  final appDir = await getApplicationDocumentsDirectory();
  final knowledgeRoot = '${appDir.path}/knowledge';
  final modelsDir = '${appDir.path}/models';

  runApp(
    ProviderScope(
      overrides: [
        // ── Core Providers ──
        settingsDaoProvider.overrideWith((ref) => SettingsDao()),
        aiProviderRef.overrideWith((ref) => LocalAIProvider()),
        modelDownloadServiceProvider.overrideWith(
          (ref) => ModelDownloadService(modelsDir),
        ),

        // ── Wiki Providers ──
        documentRepositoryProvider.overrideWith(
          (ref) => DocumentRepository(
            documentDao: DocumentDao(),
            readingLogDao: ReadingLogDao(),
            fileService: FileService(knowledgeRoot),
            settingsDao: SettingsDao(),
          ),
        ),
        categoryRepositoryProvider.overrideWith(
          (ref) => CategoryRepository(
            categoryDao: CategoryDao(),
            documentDao: DocumentDao(),
          ),
        ),

        // ── Quiz Providers ──
        questionRepositoryProvider.overrideWith(
          (ref) => QuestionRepository(
            questionDao: QuestionDao(),
            wrongDao: WrongQuestionDao(),
          ),
        ),
        examRepositoryProvider.overrideWith(
          (ref) => ExamRepository(
            examDao: ExamDao(),
            answerDao: ExamAnswerDao(),
            questionDao: QuestionDao(),
            wrongDao: WrongQuestionDao(),
            readingLogDao: ReadingLogDao(),
            documentDao: DocumentDao(),
          ),
        ),
        dailyTaskDaoProvider.overrideWith((ref) => DailyTaskDao()),

        // ── Chat Providers ──
        conversationRepositoryProvider.overrideWith(
          (ref) => ConversationRepository(
            convDao: ConversationDao(),
            msgDao: MessageDao(),
          ),
        ),
      ],
      child: const KnodeApp(),
    ),
  );
}
