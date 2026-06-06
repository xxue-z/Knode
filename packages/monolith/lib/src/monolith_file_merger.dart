import 'dart:io';

/// `monolith.yaml` 系ファイルをマージするためのインターフェース.
abstract interface class MonolithFileMerger {
  /// ファイルをマージして、結果を返す.
  Map<String, dynamic> merge(List<File> files);
}
