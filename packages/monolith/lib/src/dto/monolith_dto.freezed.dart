// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monolith_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MonolithDto {

/// インクルードするmonolith.yamlのパス.
///
/// パスは相対パスで指定する.
/// デフォルトでは、`monolith.yaml` が存在するディレクトリを起点として、
/// そのディレクトリ配下の `monolith.yaml` をインクルードする.
/// ファイルが存在しない場合はそのファイルを無視する.
@JsonKey(name: 'includes') List<String>? get includes;
/// Create a copy of MonolithDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonolithDtoCopyWith<MonolithDto> get copyWith => _$MonolithDtoCopyWithImpl<MonolithDto>(this as MonolithDto, _$identity);

  /// Serializes this MonolithDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonolithDto&&const DeepCollectionEquality().equals(other.includes, includes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(includes));

@override
String toString() {
  return 'MonolithDto(includes: $includes)';
}


}

/// @nodoc
abstract mixin class $MonolithDtoCopyWith<$Res>  {
  factory $MonolithDtoCopyWith(MonolithDto value, $Res Function(MonolithDto) _then) = _$MonolithDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'includes') List<String>? includes
});




}
/// @nodoc
class _$MonolithDtoCopyWithImpl<$Res>
    implements $MonolithDtoCopyWith<$Res> {
  _$MonolithDtoCopyWithImpl(this._self, this._then);

  final MonolithDto _self;
  final $Res Function(MonolithDto) _then;

/// Create a copy of MonolithDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? includes = freezed,}) {
  return _then(_self.copyWith(
includes: freezed == includes ? _self.includes : includes // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [MonolithDto].
extension MonolithDtoPatterns on MonolithDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonolithDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonolithDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonolithDto value)  $default,){
final _that = this;
switch (_that) {
case _MonolithDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonolithDto value)?  $default,){
final _that = this;
switch (_that) {
case _MonolithDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'includes')  List<String>? includes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonolithDto() when $default != null:
return $default(_that.includes);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'includes')  List<String>? includes)  $default,) {final _that = this;
switch (_that) {
case _MonolithDto():
return $default(_that.includes);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'includes')  List<String>? includes)?  $default,) {final _that = this;
switch (_that) {
case _MonolithDto() when $default != null:
return $default(_that.includes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MonolithDto implements MonolithDto {
  const _MonolithDto({@JsonKey(name: 'includes') final  List<String>? includes}): _includes = includes;
  factory _MonolithDto.fromJson(Map<String, dynamic> json) => _$MonolithDtoFromJson(json);

/// インクルードするmonolith.yamlのパス.
///
/// パスは相対パスで指定する.
/// デフォルトでは、`monolith.yaml` が存在するディレクトリを起点として、
/// そのディレクトリ配下の `monolith.yaml` をインクルードする.
/// ファイルが存在しない場合はそのファイルを無視する.
 final  List<String>? _includes;
/// インクルードするmonolith.yamlのパス.
///
/// パスは相対パスで指定する.
/// デフォルトでは、`monolith.yaml` が存在するディレクトリを起点として、
/// そのディレクトリ配下の `monolith.yaml` をインクルードする.
/// ファイルが存在しない場合はそのファイルを無視する.
@override@JsonKey(name: 'includes') List<String>? get includes {
  final value = _includes;
  if (value == null) return null;
  if (_includes is EqualUnmodifiableListView) return _includes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of MonolithDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonolithDtoCopyWith<_MonolithDto> get copyWith => __$MonolithDtoCopyWithImpl<_MonolithDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MonolithDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonolithDto&&const DeepCollectionEquality().equals(other._includes, _includes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_includes));

@override
String toString() {
  return 'MonolithDto(includes: $includes)';
}


}

/// @nodoc
abstract mixin class _$MonolithDtoCopyWith<$Res> implements $MonolithDtoCopyWith<$Res> {
  factory _$MonolithDtoCopyWith(_MonolithDto value, $Res Function(_MonolithDto) _then) = __$MonolithDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'includes') List<String>? includes
});




}
/// @nodoc
class __$MonolithDtoCopyWithImpl<$Res>
    implements _$MonolithDtoCopyWith<$Res> {
  __$MonolithDtoCopyWithImpl(this._self, this._then);

  final _MonolithDto _self;
  final $Res Function(_MonolithDto) _then;

/// Create a copy of MonolithDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? includes = freezed,}) {
  return _then(_MonolithDto(
includes: freezed == includes ? _self._includes : includes // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
