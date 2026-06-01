import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'package:core/database/app_database.dart';
import 'package:core/services/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppLogger.instance.init(minLevel: AppLogLevel.debug);
  AppLogger.instance.i('应用启动', tag: 'Main');

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
    AppLogger.instance.i('数据库初始化成功', tag: 'Main');
  } catch (e, st) {
    AppLogger.instance.f(
      '数据库初始化失败',
      tag: 'Main',
      error: e,
      stackTrace: st,
    );
    rethrow;
  }

  runZonedGuarded(() {
    runApp(
      const ProviderScope(
        child: KnodeApp(),
      ),
    );
  }, (Object error, StackTrace stack) {
    AppLogger.instance.f(
      'Zone 未捕获异常',
      tag: 'RunZone',
      error: error,
      stackTrace: stack,
    );
  });
}
