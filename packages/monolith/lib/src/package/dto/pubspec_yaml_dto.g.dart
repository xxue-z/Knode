// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pubspec_yaml_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PubspecYamlDto _$PubspecYamlDtoFromJson(Map<String, dynamic> json) =>
    _PubspecYamlDto(
      name: json['name'] as String?,
      version: json['version'] as String?,
      description: json['description'] as String?,
      repository: json['repository'] as String?,
      homepage: json['homepage'] as String?,
      dependencies: json['dependencies'] as Map<String, dynamic>?,
      devDependencies: json['dev_dependencies'] as Map<String, dynamic>?,
      workspace: (json['workspace'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$PubspecYamlDtoToJson(_PubspecYamlDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'version': instance.version,
      'description': instance.description,
      'repository': instance.repository,
      'homepage': instance.homepage,
      'dependencies': instance.dependencies,
      'dev_dependencies': instance.devDependencies,
      'workspace': instance.workspace,
    };
