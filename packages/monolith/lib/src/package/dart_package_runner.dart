import 'dart:io';

import 'package:armyknife_logger/armyknife_logger.dart';
import 'package:monolith/src/package/dart_package.dart';

final _log = Logger.file();

/// DartPackageに対するタスクを実行する拡張メソッド.
extension DartPackageTaskRunnerExtensions on DartPackage {
  /// バージョン名をビルド番号に簡易変換する.
  /// 1.2.3+4 -> [001][002][003][004] -> 1002003004
  int get buildNumber {
    const multiply = 1000;
    // 1.2.3+4 -> 1002003004
    final major = int.parse(version.split('.')[0]);
    final minor = int.parse(version.split('.')[1]);
    final patch = int.parse(version.split('.')[2].split('+')[0]);
    final build = int.parse(version.split('+')[1]);
    return (major * multiply * multiply * multiply) +
        (minor * multiply * multiply) +
        (patch * multiply) +
        build;
  }

  /// dart analyzeを実行する.
  Future analyze() async {
    return shell('dart', arguments: ['analyze']);
  }

  Future pubGet() async {
    if (isFlutter) {
      return shell('flutter', arguments: ['pub', 'get']);
    } else {
      return shell('dart', arguments: ['pub', 'get']);
    }
  }

  /// flutter cleanを実行する.
  Future clean() async {
    if (isFlutter) {
      return shell('flutter', arguments: ['clean']);
    }
  }

  /// dart formatを実行する.
  Future format() async {
    for (final dir in ['lib/', 'test/']) {
      final target = relativeDirectory(dir);
      if (target.existsSync()) {
        await shell(
          'dart',
          arguments: ['format', dir],
        );
      }
    }
  }

  /// コードフォーマッタを実行し、未設定のファイルがあればエラーを出力する.
  Future validateFormat() async {
    _log.i('dart format $name');
    for (final dir in ['lib/', 'test/']) {
      final target = relativeDirectory(dir);
      if (target.existsSync()) {
        await shell(
          'dart',
          arguments: [
            'format',
            dir,
            '--set-exit-if-changed',
          ],
        );
      }
    }
  }

  /// build_runnerを実行する
  Future runBuildRunner() async {
    if (!containsDevDependencies('build_runner')) {
      _log.i('skip build_runner');
      return;
    }

    _log.i('dart build_runner $name');

    await shell(
      'dart',
      arguments: [
        'run',
        'build_runner',
        'build',
        '--delete-conflicting-outputs',
      ],
      relativeWorkingDirectory: directory.path,
    );

    final libDirectory = relativeDirectory('lib');
    if (libDirectory.existsSync()) {
      libDirectory
          .listSync(recursive: true)
          .where((entity) => entity.path.endsWith('.freezed.dart'))
          .whereType<File>()
          .forEach((file) {
            // freezed出力時、Unionで異なる型・同一プロパティ名があると
            // "InvalidType" という型名が生成されるため、dynamicに変換する
            final content = file.readAsStringSync().replaceAll(
              'InvalidType',
              'dynamic',
            );
            file.writeAsStringSync(content);
          });
    }
    await format();
  }

  /// dart testを実行する.
  Future<String> test() async {
    if (hasTests) {
      if (isFlutter) {
        return shell('flutter', arguments: ['test']);
      } else {
        return shell('dart', arguments: ['test']);
      }
    } else {
      return '';
    }
  }
}
