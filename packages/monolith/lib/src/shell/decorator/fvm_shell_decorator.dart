import 'dart:io';

import 'package:armyknife_logger/armyknife_logger.dart';
import 'package:meta/meta.dart';
import 'package:monolith/src/shell/shell_execute_request.dart';
import 'package:monolith/src/shell/shell_execute_result.dart';
import 'package:monolith/src/shell/shell_runner.dart';

// ignore: unused_element
final _log = Logger.of(FvmShellDecorator);

/// fvmコマンドを利用できる場合、fvmを使用してwrapを行う
@internal
class FvmShellDecorator implements ShellRunner {
  final ShellRunner _shellRunner;

  /// .fvmディレクトリ.
  final Directory dotFvm;

  FvmShellDecorator(
    this._shellRunner, {
    required this.dotFvm,
  });

  @override
  Future<ShellExecuteResult> execute(ShellExecuteRequest request) async {
    if (request.command == 'dart' || request.command == 'flutter') {
      // _log.i('fvmrc: ${fvmrc.path}');
      if (dotFvm.existsSync()) {
        // fvmrcが存在する場合、fvmを使用してコマンドを実行する.
        return _shellRunner.execute(
          request.copyWith(
            command: 'fvm',
            arguments: [
              request.command,
              ...request.arguments,
            ],
          ),
        );
      }
    }
    return _shellRunner.execute(request);
  }
}
