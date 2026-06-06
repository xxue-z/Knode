// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shell_execute_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ShellExecuteResult {

/// 実行したコマンドのリクエスト.
 ShellExecuteRequest get request;/// 標準出力.
 String get stdout;/// 標準エラー.
 String get stderr;/// 終了コード.
 int get exitCode;
/// Create a copy of ShellExecuteResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShellExecuteResultCopyWith<ShellExecuteResult> get copyWith => _$ShellExecuteResultCopyWithImpl<ShellExecuteResult>(this as ShellExecuteResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShellExecuteResult&&(identical(other.request, request) || other.request == request)&&(identical(other.stdout, stdout) || other.stdout == stdout)&&(identical(other.stderr, stderr) || other.stderr == stderr)&&(identical(other.exitCode, exitCode) || other.exitCode == exitCode));
}


@override
int get hashCode => Object.hash(runtimeType,request,stdout,stderr,exitCode);

@override
String toString() {
  return 'ShellExecuteResult(request: $request, stdout: $stdout, stderr: $stderr, exitCode: $exitCode)';
}


}

/// @nodoc
abstract mixin class $ShellExecuteResultCopyWith<$Res>  {
  factory $ShellExecuteResultCopyWith(ShellExecuteResult value, $Res Function(ShellExecuteResult) _then) = _$ShellExecuteResultCopyWithImpl;
@useResult
$Res call({
 ShellExecuteRequest request, String stdout, String stderr, int exitCode
});


$ShellExecuteRequestCopyWith<$Res> get request;

}
/// @nodoc
class _$ShellExecuteResultCopyWithImpl<$Res>
    implements $ShellExecuteResultCopyWith<$Res> {
  _$ShellExecuteResultCopyWithImpl(this._self, this._then);

  final ShellExecuteResult _self;
  final $Res Function(ShellExecuteResult) _then;

/// Create a copy of ShellExecuteResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? request = null,Object? stdout = null,Object? stderr = null,Object? exitCode = null,}) {
  return _then(_self.copyWith(
request: null == request ? _self.request : request // ignore: cast_nullable_to_non_nullable
as ShellExecuteRequest,stdout: null == stdout ? _self.stdout : stdout // ignore: cast_nullable_to_non_nullable
as String,stderr: null == stderr ? _self.stderr : stderr // ignore: cast_nullable_to_non_nullable
as String,exitCode: null == exitCode ? _self.exitCode : exitCode // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of ShellExecuteResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShellExecuteRequestCopyWith<$Res> get request {
  
  return $ShellExecuteRequestCopyWith<$Res>(_self.request, (value) {
    return _then(_self.copyWith(request: value));
  });
}
}


/// Adds pattern-matching-related methods to [ShellExecuteResult].
extension ShellExecuteResultPatterns on ShellExecuteResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShellExecuteResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShellExecuteResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShellExecuteResult value)  $default,){
final _that = this;
switch (_that) {
case _ShellExecuteResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShellExecuteResult value)?  $default,){
final _that = this;
switch (_that) {
case _ShellExecuteResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ShellExecuteRequest request,  String stdout,  String stderr,  int exitCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShellExecuteResult() when $default != null:
return $default(_that.request,_that.stdout,_that.stderr,_that.exitCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ShellExecuteRequest request,  String stdout,  String stderr,  int exitCode)  $default,) {final _that = this;
switch (_that) {
case _ShellExecuteResult():
return $default(_that.request,_that.stdout,_that.stderr,_that.exitCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ShellExecuteRequest request,  String stdout,  String stderr,  int exitCode)?  $default,) {final _that = this;
switch (_that) {
case _ShellExecuteResult() when $default != null:
return $default(_that.request,_that.stdout,_that.stderr,_that.exitCode);case _:
  return null;

}
}

}

/// @nodoc


class _ShellExecuteResult implements ShellExecuteResult {
  const _ShellExecuteResult({required this.request, required this.stdout, required this.stderr, required this.exitCode});
  

/// 実行したコマンドのリクエスト.
@override final  ShellExecuteRequest request;
/// 標準出力.
@override final  String stdout;
/// 標準エラー.
@override final  String stderr;
/// 終了コード.
@override final  int exitCode;

/// Create a copy of ShellExecuteResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShellExecuteResultCopyWith<_ShellExecuteResult> get copyWith => __$ShellExecuteResultCopyWithImpl<_ShellExecuteResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShellExecuteResult&&(identical(other.request, request) || other.request == request)&&(identical(other.stdout, stdout) || other.stdout == stdout)&&(identical(other.stderr, stderr) || other.stderr == stderr)&&(identical(other.exitCode, exitCode) || other.exitCode == exitCode));
}


@override
int get hashCode => Object.hash(runtimeType,request,stdout,stderr,exitCode);

@override
String toString() {
  return 'ShellExecuteResult(request: $request, stdout: $stdout, stderr: $stderr, exitCode: $exitCode)';
}


}

/// @nodoc
abstract mixin class _$ShellExecuteResultCopyWith<$Res> implements $ShellExecuteResultCopyWith<$Res> {
  factory _$ShellExecuteResultCopyWith(_ShellExecuteResult value, $Res Function(_ShellExecuteResult) _then) = __$ShellExecuteResultCopyWithImpl;
@override @useResult
$Res call({
 ShellExecuteRequest request, String stdout, String stderr, int exitCode
});


@override $ShellExecuteRequestCopyWith<$Res> get request;

}
/// @nodoc
class __$ShellExecuteResultCopyWithImpl<$Res>
    implements _$ShellExecuteResultCopyWith<$Res> {
  __$ShellExecuteResultCopyWithImpl(this._self, this._then);

  final _ShellExecuteResult _self;
  final $Res Function(_ShellExecuteResult) _then;

/// Create a copy of ShellExecuteResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? request = null,Object? stdout = null,Object? stderr = null,Object? exitCode = null,}) {
  return _then(_ShellExecuteResult(
request: null == request ? _self.request : request // ignore: cast_nullable_to_non_nullable
as ShellExecuteRequest,stdout: null == stdout ? _self.stdout : stdout // ignore: cast_nullable_to_non_nullable
as String,stderr: null == stderr ? _self.stderr : stderr // ignore: cast_nullable_to_non_nullable
as String,exitCode: null == exitCode ? _self.exitCode : exitCode // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of ShellExecuteResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShellExecuteRequestCopyWith<$Res> get request {
  
  return $ShellExecuteRequestCopyWith<$Res>(_self.request, (value) {
    return _then(_self.copyWith(request: value));
  });
}
}

// dart format on
