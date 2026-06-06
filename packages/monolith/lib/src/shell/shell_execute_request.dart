import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'shell_execute_request.freezed.dart';

enum FailMode {
  /// コマンドが0以外を返却した場合にプロセスを終了する.
  exit,

  /// コマンドが0以外を返却した場合に例外を投げる.
  throwException,

  /// コマンドが0以外を返却した場合にreturnする.
  returnFunction,
}

/// Shell実行のリクエスト.
@freezed
abstract class ShellExecuteRequest with _$ShellExecuteRequest {
  const factory ShellExecuteRequest({
    /// 実行するコマンド.
    required String command,

    /// 実行するコマンドの引数.
    required List<String> arguments,

    /// 実行するコマンドの環境変数.
    Map<String, String>? environment,

    /// 実行するコマンドのワーキングディレクトリ.
    Directory? workingDirectory,

    /// コマンドが0以外を返却した場合のハンドラ.
    @Default(FailMode.exit) FailMode failMode,
  }) = _ShellExecuteRequest;
}
