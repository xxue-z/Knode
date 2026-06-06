// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monolith_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MonolithDto _$MonolithDtoFromJson(Map<String, dynamic> json) => _MonolithDto(
  includes: (json['includes'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$MonolithDtoToJson(_MonolithDto instance) =>
    <String, dynamic>{'includes': instance.includes};
