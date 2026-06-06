// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'monolith_dto.freezed.dart';
part 'monolith_dto.g.dart';

@freezed
abstract class MonolithDto with _$MonolithDto {
  const factory MonolithDto({
    /// インクルードするmonolith.yamlのパス.
    ///
    /// パスは相対パスで指定する.
    /// デフォルトでは、`monolith.yaml` が存在するディレクトリを起点として、
    /// そのディレクトリ配下の `monolith.yaml` をインクルードする.
    /// ファイルが存在しない場合はそのファイルを無視する.
    @JsonKey(name: 'includes') List<String>? includes,
  }) = _MonolithDto;

  factory MonolithDto.fromJson(Map<String, dynamic> json) =>
      _$MonolithDtoFromJson(json);
}
