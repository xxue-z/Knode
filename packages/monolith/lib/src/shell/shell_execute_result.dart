import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:monolith/src/shell/shell_execute_request.dart';

part 'shell_execute_result.freezed.dart';

/// Shell実行の結果.
@freezed
abstract class ShellExecuteResult with _$ShellExecuteResult {
  const factory ShellExecuteResult({
    /// 実行したコマンドのリクエスト.
    required ShellExecuteRequest request,

    /// 標準出力.
    required String stdout,

    /// 標準エラー.
    required String stderr,

    /// 終了コード.
    required int exitCode,
  }) = _ShellExecuteResult;
}
