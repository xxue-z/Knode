import 'dart:io';

import 'package:armyknife_logger/armyknife_logger.dart';
import 'package:armyknife_yamlx/armyknife_yamlx.dart';
import 'package:monolith/src/dto/monolith_dto.dart';
import 'package:monolith/src/internal/default_monolith_file_merger.dart';
import 'package:monolith/src/monolith_options.dart';
import 'package:monolith/src/package/dart_package.dart';
import 'package:monolith/src/shell/shell_runner.dart';
import 'package:path/path.dart' as p;

final _log = Logger.of(Monolith);

/// FlutterでのModular Monolith Workspaceの処理をサポートするクラス.
class Monolith {
  /// ワークスペースのRootパッケージ.
  final DartPackage project;

  /// オプション.
  final MonolithOptions options;

  /// `monolith.yaml` 系ファイルから読み込んだ設定値.
  final Map<String, dynamic> configurations;

  factory Monolith(MonolithOptions options) {
    final workspaceDirectory = Directory.current;
    final monolithFile =
        (options.monolith ??
                File(p.join(workspaceDirectory.path, 'monolith.yaml')))
            .absolute;
    final monolithFileMerger =
        options.monolithFileMerger ?? const DefaultMonolithFileMerger();
    _log.i('monolith.yaml: ${monolithFile.path}');

    final monolithYamlFiles = () {
      final rootMonolithDto = MonolithDto.fromJson(
        YamlX.parse(monolithFile),
      );
      final includes = rootMonolithDto.includes ?? <String>[];
      return [
        monolithFile,
        ...includes
            .map((e) => File(p.join(workspaceDirectory.path, e)))
            .where((e) => e.existsSync())
            .map((e) {
              _log.i('include: ${e.path}');
              return e;
            }),
      ];
    }();

    final pubspecYaml = File(p.join(workspaceDirectory.path, 'pubspec.yaml'));
    _log.i('load workspace: ${pubspecYaml.path}');
    return Monolith._(
      project: DartPackage.fromFile(
        pubspecYaml,
        shellRunner:
            options.shellRunner ??
            ShellRunner(
              monolith: monolithFile,
            ),
      ),
      options: options,
      configurations: monolithFileMerger.merge(monolithYamlFiles),
    );
  }

  const Monolith._({
    required this.project,
    required this.options,
    required this.configurations,
  });

  /// ワークスペースすべてのプロジェクトを列挙する.
  /// 最初のプロジェクトは、ワークスペースのルートプロジェクト.
  Iterable<DartPackage> get workspace sync* {
    yield project;
    yield* project.workspaces;
  }

  /// ワークスペースに含まれるpackageを処理する.
  Future each(Future<void> Function(DartPackage pkg) callback) async {
    await callback(project);
    for (final child in project.workspaces) {
      await callback(child);
    }
  }

  /// 指定パスの設定値を取得する.
  /// 存在しない場合はnullを返す.
  T? findConfiguration<T>(List<String> path) {
    return YamlX.find<T>(configurations, path);
  }

  /// 指定ファイルが含まれるpackageを取得する.
  DartPackage? findFromFocusFile(File file) {
    var directory = file.parent;
    while (directory.path.isNotEmpty) {
      final pubspec = File(p.join(directory.path, 'pubspec.yaml'));
      if (pubspec.existsSync()) {
        _log.i('pubspec: ${pubspec.path}');
        return workspace.firstWhere(
          (e) => p.equals(e.pubspecYaml.path, pubspec.path),
        );
      }
      directory = directory.parent.absolute;
    }
    return null;
  }

  /// 設定値を出力する.
  void printConfigurations({
    void Function(String msg)? print,
  }) {
    void printImpl(int indent, Map map) {
      for (final kv in map.entries) {
        if (kv.value is Map) {
          (print ?? _log.i)('${' ' * indent}${kv.key}:');
          printImpl(indent + 2, kv.value as Map);
        } else {
          (print ?? _log.i)('${' ' * indent}${kv.key}: ${kv.value}');
        }
      }
    }

    printImpl(0, configurations);
  }

  /// ルートプロジェクトからのディレクトリ取得
  Directory relativeDirectory(String path) => project.relativeDirectory(path);

  /// ルートプロジェクトからのファイル取得
  File relativeFile(String path) => project.relativeFile(path);

  /// ワークスペースに含まれるpackageを取得する.
  /// 存在しない場合は例外を投げる.
  DartPackage require(String name) {
    return workspace.firstWhere((e) => e.name == name);
  }

  /// 指定パスの設定値を取得する.
  T requireConfiguration<T>(List<String> path) {
    return YamlX.require<T>(configurations, path);
  }

  /// ワークスペースに含まれるpackageを処理する.
  /// 指定したpackage名がnullの場合は、ワークスペースのルートプロジェクトを処理する.
  Future<T> run<T>(
    String name,
    Future<T> Function(DartPackage pkg) callback,
  ) async {
    return callback(require(name));
  }
}
