import 'dart:io';

import 'package:armyknife_logger/armyknife_logger.dart';
import 'package:armyknife_yamlx/armyknife_yamlx.dart';
import 'package:meta/meta.dart';
import 'package:monolith/src/package/dto/pubspec_yaml_dto.dart';
import 'package:monolith/src/shell/shell_execute_request.dart';
import 'package:monolith/src/shell/shell_runner.dart';
import 'package:path/path.dart' as p;

/// Dartの1packageを示すオブジェクト.
class DartPackage {
  late final Logger _log;

  final File pubspecYaml;

  final PubspecYamlDto _pubspecYamlDto;

  /// pubspec.yamlの生データ
  // ignore: unused_field
  final Map<String, dynamic> _pubspecYaml;

  /// シェル実行インスタンス.
  final ShellRunner _shellRunner;

  @internal
  factory DartPackage.fromFile(
    File pubspecYaml, {
    required ShellRunner shellRunner,
  }) {
    final yamlMap = YamlX.parse(pubspecYaml);
    final dto = PubspecYamlDto.fromJson(yamlMap);
    return DartPackage._(
      pubspecYaml: pubspecYaml.absolute,
      pubspecYamlDto: dto,
      yamlMap: yamlMap,
      shellRunner: shellRunner,
    );
  }

  DartPackage._({
    required this.pubspecYaml,
    required PubspecYamlDto pubspecYamlDto,
    required Map<String, dynamic> yamlMap,
    required ShellRunner shellRunner,
  }) : _pubspecYamlDto = pubspecYamlDto,
       _pubspecYaml = yamlMap,
       _log = Logger.tag(pubspecYamlDto.name!),
       _shellRunner = shellRunner;

  /// ディレクトリ
  Directory get directory => pubspecYaml.parent;

  /// テストファイルが存在するかどうか.
  bool get hasTests {
    final testDirectory = Directory(p.join(directory.path, 'test'));
    if (!testDirectory.existsSync()) {
      return false;
    }

    final testFiles = testDirectory.listSync(recursive: true);
    for (final file in testFiles) {
      if (file.path.endsWith('_test.dart')) {
        return true;
      }
    }
    return false;
  }

  /// Flutterプロジェクトであればtrue.
  bool get isFlutter => containsDependencies('flutter');

  /// package名
  String get name => _pubspecYamlDto.name!;

  /// packageのバージョン.
  String get version => _pubspecYamlDto.version!;

  /// ワークスペースに含まれるpackageリスト.
  Iterable<DartPackage> get workspaces sync* {
    final workspace = _pubspecYamlDto.workspace ?? const [];
    for (final pub in workspace) {
      final child = p.join(pubspecYaml.parent.path, pub, 'pubspec.yaml');
      yield DartPackage.fromFile(
        File(child),
        shellRunner: _shellRunner,
      );
    }
  }

  /// `dependencies` に依存が含まれているかどうか.
  bool containsDependencies(String pubName) {
    return _pubspecYamlDto.dependencies?.containsKey(pubName) ?? false;
  }

  /// `dev_dependencies` に依存が含まれているかどうか.
  bool containsDevDependencies(String pubName) {
    return _pubspecYamlDto.devDependencies?.containsKey(pubName) ?? false;
  }

  /// 指定したコマンドを実行する.
  Future<String> shell(
    String executable, {
    String? relativeWorkingDirectory,
    required List<String> arguments,
    Map<String, String>? environment,
  }) async {
    final workingDirectory = p.join(
      directory.path,
      relativeWorkingDirectory ?? '',
    );

    _log.i('exec: $executable $arguments');

    final result = await _shellRunner.execute(
      ShellExecuteRequest(
        command: executable,
        arguments: arguments,
        workingDirectory: Directory(workingDirectory),
        environment: environment,
      ),
    );
    return result.stdout;
  }

  /// package配下のディレクトリを取得する.
  Directory relativeDirectory(String path) =>
      Directory(p.normalize(p.join(directory.path, path)));

  /// package配下のファイルを取得する.
  File relativeFile(String path) =>
      File(p.normalize(p.join(directory.path, path)));
}
