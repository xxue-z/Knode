import 'dart:convert';
import 'dart:io';

import 'package:armyknife_logger/armyknife_logger.dart';
import 'package:meta/meta.dart';
import 'package:monolith/src/shell/shell_execute_request.dart';
import 'package:monolith/src/shell/shell_execute_result.dart';
import 'package:monolith/src/shell/shell_runner.dart';

final _log = Logger.file();

/// デフォルトのシェル実行インスタンス.
@internal
class DefaultShellRunner implements ShellRunner {
  const DefaultShellRunner();

  @override
  Future<ShellExecuteResult> execute(ShellExecuteRequest request) async {
    final log = Logger.tag(request.command);
    log.i(' ');

    try {
      final process = await Process.start(
        request.command,
        request.arguments,
        environment: request.environment,
        workingDirectory: request.workingDirectory?.absolute.path,
        runInShell: true,
      );

      final stdoutBuffer = StringBuffer();
      final stderrBuffer = StringBuffer();

      final stdoutSubscription = process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            log.i(line);
            stdoutBuffer.writeln(line);
          });

      final stderrSubscription = process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            log.w(line);
            stderrBuffer.writeln(line);
          });

      final exitCode = await process.exitCode;

      await stdoutSubscription.cancel();
      await stderrSubscription.cancel();

      if (exitCode != 0) {
        switch (request.failMode) {
          case FailMode.exit:
            _log.e('Shell command execution completed. Exit code: ');
            exit(exitCode);
          case FailMode.throwException:
            throw Exception(
              'Shell command execution completed. Exit code: ',
            );
          case FailMode.returnFunction:
            break;
        }
      }

      return ShellExecuteResult(
        request: request,
        stdout: stdoutBuffer.toString(),
        stderr: stderrBuffer.toString(),
        exitCode: exitCode,
      );
    } on Exception catch (e, stackTrace) {
      log.e(
        'An error occurred while executing the shell command',
        e,
        stackTrace,
      );
      exit(127);
    }
  }
}
