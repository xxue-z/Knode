import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:core/database/app_database.dart';

/// Riverpod provider that exposes the [AppDatabase] singleton.
///
/// The database is initialized once during app startup (see `main.dart`).
/// This provider simply returns the already-initialized instance so that
/// DAOs and repositories can access it via `ref.watch(databaseProvider)`.
///
/// **Important**: Do NOT call `AppDatabase.instance.init()` here.
/// Initialization is handled in `main.dart` before the app starts.
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase.instance;

  ref.onDispose(() async {
    await database.close();
  });

  return database;
});
