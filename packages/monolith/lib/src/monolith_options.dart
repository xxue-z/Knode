import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:monolith/src/monolith_file_merger.dart';
import 'package:monolith/src/shell/shell_runner.dart';

part 'monolith_options.freezed.dart';

@freezed
abstract class MonolithOptions with _$MonolithOptions {
  const factory MonolithOptions({
    /// monolith.yamlのパス.
    /// nullの場合、カレントディレクトリをルートとして `monolith.yaml` を読み込む.
    File? monolith,

    /// シェル実行インスタンス.
    ShellRunner? shellRunner,

    /// `monolith.yaml` 系ファイルをマージするためのインスタンス.
    MonolithFileMerger? monolithFileMerger,
  }) = _MonolithOptions;
}
