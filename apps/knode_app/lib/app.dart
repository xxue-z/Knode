import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';

import 'package:core/theme/app_theme.dart';
import 'package:knode_app/l10n/l10n_helper.dart';
import 'package:knode_app/screens/app_shell.dart';
import 'package:knode_app/providers/locale_provider.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [GoRoute(path: '/', builder: (context, state) => const AppShell())],
);

class KnodeApp extends ConsumerWidget {
  const KnodeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: '知维',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
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
