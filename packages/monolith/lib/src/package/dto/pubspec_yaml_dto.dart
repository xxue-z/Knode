// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'pubspec_yaml_dto.freezed.dart';
part 'pubspec_yaml_dto.g.dart';

@internal
@freezed
abstract class PubspecYamlDto with _$PubspecYamlDto {
  const factory PubspecYamlDto({
    /// パッケージ名.
    @JsonKey(name: 'name') required String? name,

    /// パッケージのバージョン.
    @JsonKey(name: 'version') required String? version,

    /// パッケージの説明.
    @JsonKey(name: 'description') required String? description,

    /// パッケージのリポジトリ.
    @JsonKey(name: 'repository') required String? repository,

    /// パッケージのホームページ.
    @JsonKey(name: 'homepage') required String? homepage,

    /// パッケージの依存関係.
    @JsonKey(name: 'dependencies') required Map<String, dynamic>? dependencies,

    /// パッケージの開発依存関係.
    @JsonKey(name: 'dev_dependencies')
    required Map<String, dynamic>? devDependencies,

    /// パッケージに含まれるworkspaceリスト
    @JsonKey(name: 'workspace') required List<String>? workspace,
  }) = _PubspecYamlDto;

  factory PubspecYamlDto.fromJson(Map<String, dynamic> json) =>
      _$PubspecYamlDtoFromJson(json);
}
