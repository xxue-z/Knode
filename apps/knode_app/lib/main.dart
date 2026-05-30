import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'package:core/database/app_database.dart';

/// Application entry point.
///
/// Performs the following initialization sequence:
/// 1. Ensures Flutter bindings are ready.
/// 2. Initializes the [AppDatabase] singleton (creates/migrates SQLite).
/// 3. Launches the widget tree wrapped in Riverpod's [ProviderScope].
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await AppDatabase.instance.init();
  } catch (e, st) {
    debugPrint('Failed to initialize database: $e\n$st');
    // Database failure is fatal for the app; rethrow to surface the error
    // in the zone handler rather than silently continuing.
    rethrow;
  }

  runApp(
    const ProviderScope(
      child: KnodeApp(),
    ),
  );
}
