import 'dart:io';

import 'package:monolith/src/shell/decorator/default_shell_runner.dart';
import 'package:monolith/src/shell/decorator/fvm_shell_decorator.dart';
import 'package:monolith/src/shell/shell_execute_request.dart';
import 'package:monolith/src/shell/shell_execute_result.dart';
import 'package:path/path.dart' as p;

/// シェル実行インターフェース.
abstract class ShellRunner {
  factory ShellRunner({
    required File monolith,
  }) {
    final rootDirectory = monolith.parent;
    final dotFvm = Directory(p.join(rootDirectory.path, '.fvm'));
    return FvmShellDecorator(
      const DefaultShellRunner(),
      dotFvm: dotFvm,
    );
  }

  /// シェルを実行する.
  Future<ShellExecuteResult> execute(ShellExecuteRequest request);
}
