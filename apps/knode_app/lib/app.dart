import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';

import 'package:core/theme/app_theme.dart';
import 'package:core/providers/theme_provider.dart';
import 'package:knode_app/l10n/l10n_helper.dart';
import 'package:knode_app/screens/app_shell.dart';
import 'package:knode_app/providers/locale_provider.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [GoRoute(path: '/', builder: (context, state) => const AppShell())],
);

class KnodeApp extends ConsumerStatefulWidget {
  const KnodeApp({super.key});

  @override
  ConsumerState<KnodeApp> createState() => _KnodeAppState();
}

class _KnodeAppState extends ConsumerState<KnodeApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(themeNotifierProvider.notifier).restoreThemeMode());
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp.router(
      title: '知维',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: _router,
      locale: locale,
      localizationsDelegates: [
        ...L10nHelper.localizationsDelegates,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: L10nHelper.supportedLocales,
    );
  }
}