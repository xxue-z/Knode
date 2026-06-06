// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monolith_options.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MonolithOptions {

/// monolith.yamlのパス.
/// nullの場合、カレントディレクトリをルートとして `monolith.yaml` を読み込む.
 File? get monolith;/// シェル実行インスタンス.
 ShellRunner? get shellRunner;/// `monolith.yaml` 系ファイルをマージするためのインスタンス.
 MonolithFileMerger? get monolithFileMerger;
/// Create a copy of MonolithOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonolithOptionsCopyWith<MonolithOptions> get copyWith => _$MonolithOptionsCopyWithImpl<MonolithOptions>(this as MonolithOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonolithOptions&&(identical(other.monolith, monolith) || other.monolith == monolith)&&(identical(other.shellRunner, shellRunner) || other.shellRunner == shellRunner)&&(identical(other.monolithFileMerger, monolithFileMerger) || other.monolithFileMerger == monolithFileMerger));
}


@override
int get hashCode => Object.hash(runtimeType,monolith,shellRunner,monolithFileMerger);

@override
String toString() {
  return 'MonolithOptions(monolith: $monolith, shellRunner: $shellRunner, monolithFileMerger: $monolithFileMerger)';
}


}

/// @nodoc
abstract mixin class $MonolithOptionsCopyWith<$Res>  {
  factory $MonolithOptionsCopyWith(MonolithOptions value, $Res Function(MonolithOptions) _then) = _$MonolithOptionsCopyWithImpl;
@useResult
$Res call({
 File? monolith, ShellRunner? shellRunner, MonolithFileMerger? monolithFileMerger
});




}
/// @nodoc
class _$MonolithOptionsCopyWithImpl<$Res>
    implements $MonolithOptionsCopyWith<$Res> {
  _$MonolithOptionsCopyWithImpl(this._self, this._then);

  final MonolithOptions _self;
  final $Res Function(MonolithOptions) _then;

/// Create a copy of MonolithOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? monolith = freezed,Object? shellRunner = freezed,Object? monolithFileMerger = freezed,}) {
  return _then(_self.copyWith(
monolith: freezed == monolith ? _self.monolith : monolith // ignore: cast_nullable_to_non_nullable
as File?,shellRunner: freezed == shellRunner ? _self.shellRunner : shellRunner // ignore: cast_nullable_to_non_nullable
as ShellRunner?,monolithFileMerger: freezed == monolithFileMerger ? _self.monolithFileMerger : monolithFileMerger // ignore: cast_nullable_to_non_nullable
as MonolithFileMerger?,
  ));
}

}


/// Adds pattern-matching-related methods to [MonolithOptions].
extension MonolithOptionsPatterns on MonolithOptions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonolithOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonolithOptions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonolithOptions value)  $default,){
final _that = this;
switch (_that) {
case _MonolithOptions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonolithOptions value)?  $default,){
final _that = this;
switch (_that) {
case _MonolithOptions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( File? monolith,  ShellRunner? shellRunner,  MonolithFileMerger? monolithFileMerger)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonolithOptions() when $default != null:
return $default(_that.monolith,_that.shellRunner,_that.monolithFileMerger);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( File? monolith,  ShellRunner? shellRunner,  MonolithFileMerger? monolithFileMerger)  $default,) {final _that = this;
switch (_that) {
case _MonolithOptions():
return $default(_that.monolith,_that.shellRunner,_that.monolithFileMerger);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( File? monolith,  ShellRunner? shellRunner,  MonolithFileMerger? monolithFileMerger)?  $default,) {final _that = this;
switch (_that) {
case _MonolithOptions() when $default != null:
return $default(_that.monolith,_that.shellRunner,_that.monolithFileMerger);case _:
  return null;

}
}

}

/// @nodoc


class _MonolithOptions implements MonolithOptions {
  const _MonolithOptions({this.monolith, this.shellRunner, this.monolithFileMerger});
  

/// monolith.yamlのパス.
/// nullの場合、カレントディレクトリをルートとして `monolith.yaml` を読み込む.
@override final  File? monolith;
/// シェル実行インスタンス.
@override final  ShellRunner? shellRunner;
/// `monolith.yaml` 系ファイルをマージするためのインスタンス.
@override final  MonolithFileMerger? monolithFileMerger;

/// Create a copy of MonolithOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonolithOptionsCopyWith<_MonolithOptions> get copyWith => __$MonolithOptionsCopyWithImpl<_MonolithOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonolithOptions&&(identical(other.monolith, monolith) || other.monolith == monolith)&&(identical(other.shellRunner, shellRunner) || other.shellRunner == shellRunner)&&(identical(other.monolithFileMerger, monolithFileMerger) || other.monolithFileMerger == monolithFileMerger));
}


@override
int get hashCode => Object.hash(runtimeType,monolith,shellRunner,monolithFileMerger);

@override
String toString() {
  return 'MonolithOptions(monolith: $monolith, shellRunner: $shellRunner, monolithFileMerger: $monolithFileMerger)';
}


}

/// @nodoc
abstract mixin class _$MonolithOptionsCopyWith<$Res> implements $MonolithOptionsCopyWith<$Res> {
  factory _$MonolithOptionsCopyWith(_MonolithOptions value, $Res Function(_MonolithOptions) _then) = __$MonolithOptionsCopyWithImpl;
@override @useResult
$Res call({
 File? monolith, ShellRunner? shellRunner, MonolithFileMerger? monolithFileMerger
});




}
/// @nodoc
class __$MonolithOptionsCopyWithImpl<$Res>
    implements _$MonolithOptionsCopyWith<$Res> {
  __$MonolithOptionsCopyWithImpl(this._self, this._then);

  final _MonolithOptions _self;
  final $Res Function(_MonolithOptions) _then;

/// Create a copy of MonolithOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? monolith = freezed,Object? shellRunner = freezed,Object? monolithFileMerger = freezed,}) {
  return _then(_MonolithOptions(
monolith: freezed == monolith ? _self.monolith : monolith // ignore: cast_nullable_to_non_nullable
as File?,shellRunner: freezed == shellRunner ? _self.shellRunner : shellRunner // ignore: cast_nullable_to_non_nullable
as ShellRunner?,monolithFileMerger: freezed == monolithFileMerger ? _self.monolithFileMerger : monolithFileMerger // ignore: cast_nullable_to_non_nullable
as MonolithFileMerger?,
  ));
}


}

// dart format on
