// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shell_execute_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ShellExecuteRequest {

/// 実行するコマンド.
 String get command;/// 実行するコマンドの引数.
 List<String> get arguments;/// 実行するコマンドの環境変数.
 Map<String, String>? get environment;/// 実行するコマンドのワーキングディレクトリ.
 Directory? get workingDirectory;/// コマンドが0以外を返却した場合のハンドラ.
 FailMode get failMode;
/// Create a copy of ShellExecuteRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShellExecuteRequestCopyWith<ShellExecuteRequest> get copyWith => _$ShellExecuteRequestCopyWithImpl<ShellExecuteRequest>(this as ShellExecuteRequest, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShellExecuteRequest&&(identical(other.command, command) || other.command == command)&&const DeepCollectionEquality().equals(other.arguments, arguments)&&const DeepCollectionEquality().equals(other.environment, environment)&&(identical(other.workingDirectory, workingDirectory) || other.workingDirectory == workingDirectory)&&(identical(other.failMode, failMode) || other.failMode == failMode));
}


@override
int get hashCode => Object.hash(runtimeType,command,const DeepCollectionEquality().hash(arguments),const DeepCollectionEquality().hash(environment),workingDirectory,failMode);

@override
String toString() {
  return 'ShellExecuteRequest(command: $command, arguments: $arguments, environment: $environment, workingDirectory: $workingDirectory, failMode: $failMode)';
}


}

/// @nodoc
abstract mixin class $ShellExecuteRequestCopyWith<$Res>  {
  factory $ShellExecuteRequestCopyWith(ShellExecuteRequest value, $Res Function(ShellExecuteRequest) _then) = _$ShellExecuteRequestCopyWithImpl;
@useResult
$Res call({
 String command, List<String> arguments, Map<String, String>? environment, Directory? workingDirectory, FailMode failMode
});




}
/// @nodoc
class _$ShellExecuteRequestCopyWithImpl<$Res>
    implements $ShellExecuteRequestCopyWith<$Res> {
  _$ShellExecuteRequestCopyWithImpl(this._self, this._then);

  final ShellExecuteRequest _self;
  final $Res Function(ShellExecuteRequest) _then;

/// Create a copy of ShellExecuteRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? command = null,Object? arguments = null,Object? environment = freezed,Object? workingDirectory = freezed,Object? failMode = null,}) {
  return _then(_self.copyWith(
command: null == command ? _self.command : command // ignore: cast_nullable_to_non_nullable
as String,arguments: null == arguments ? _self.arguments : arguments // ignore: cast_nullable_to_non_nullable
as List<String>,environment: freezed == environment ? _self.environment : environment // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,workingDirectory: freezed == workingDirectory ? _self.workingDirectory : workingDirectory // ignore: cast_nullable_to_non_nullable
as Directory?,failMode: null == failMode ? _self.failMode : failMode // ignore: cast_nullable_to_non_nullable
as FailMode,
  ));
}

}


/// Adds pattern-matching-related methods to [ShellExecuteRequest].
extension ShellExecuteRequestPatterns on ShellExecuteRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShellExecuteRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShellExecuteRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShellExecuteRequest value)  $default,){
final _that = this;
switch (_that) {
case _ShellExecuteRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShellExecuteRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ShellExecuteRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String command,  List<String> arguments,  Map<String, String>? environment,  Directory? workingDirectory,  FailMode failMode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShellExecuteRequest() when $default != null:
return $default(_that.command,_that.arguments,_that.environment,_that.workingDirectory,_that.failMode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String command,  List<String> arguments,  Map<String, String>? environment,  Directory? workingDirectory,  FailMode failMode)  $default,) {final _that = this;
switch (_that) {
case _ShellExecuteRequest():
return $default(_that.command,_that.arguments,_that.environment,_that.workingDirectory,_that.failMode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String command,  List<String> arguments,  Map<String, String>? environment,  Directory? workingDirectory,  FailMode failMode)?  $default,) {final _that = this;
switch (_that) {
case _ShellExecuteRequest() when $default != null:
return $default(_that.command,_that.arguments,_that.environment,_that.workingDirectory,_that.failMode);case _:
  return null;

}
}

}

/// @nodoc


class _ShellExecuteRequest implements ShellExecuteRequest {
  const _ShellExecuteRequest({required this.command, required final  List<String> arguments, final  Map<String, String>? environment, this.workingDirectory, this.failMode = FailMode.exit}): _arguments = arguments,_environment = environment;
  

/// 実行するコマンド.
@override final  String command;
/// 実行するコマンドの引数.
 final  List<String> _arguments;
/// 実行するコマンドの引数.
@override List<String> get arguments {
  if (_arguments is EqualUnmodifiableListView) return _arguments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_arguments);
}

/// 実行するコマンドの環境変数.
 final  Map<String, String>? _environment;
/// 実行するコマンドの環境変数.
@override Map<String, String>? get environment {
  final value = _environment;
  if (value == null) return null;
  if (_environment is EqualUnmodifiableMapView) return _environment;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// 実行するコマンドのワーキングディレクトリ.
@override final  Directory? workingDirectory;
/// コマンドが0以外を返却した場合のハンドラ.
@override@JsonKey() final  FailMode failMode;

/// Create a copy of ShellExecuteRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShellExecuteRequestCopyWith<_ShellExecuteRequest> get copyWith => __$ShellExecuteRequestCopyWithImpl<_ShellExecuteRequest>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShellExecuteRequest&&(identical(other.command, command) || other.command == command)&&const DeepCollectionEquality().equals(other._arguments, _arguments)&&const DeepCollectionEquality().equals(other._environment, _environment)&&(identical(other.workingDirectory, workingDirectory) || other.workingDirectory == workingDirectory)&&(identical(other.failMode, failMode) || other.failMode == failMode));
}


@override
int get hashCode => Object.hash(runtimeType,command,const DeepCollectionEquality().hash(_arguments),const DeepCollectionEquality().hash(_environment),workingDirectory,failMode);

@override
String toString() {
  return 'ShellExecuteRequest(command: $command, arguments: $arguments, environment: $environment, workingDirectory: $workingDirectory, failMode: $failMode)';
}


}

/// @nodoc
abstract mixin class _$ShellExecuteRequestCopyWith<$Res> implements $ShellExecuteRequestCopyWith<$Res> {
  factory _$ShellExecuteRequestCopyWith(_ShellExecuteRequest value, $Res Function(_ShellExecuteRequest) _then) = __$ShellExecuteRequestCopyWithImpl;
@override @useResult
$Res call({
 String command, List<String> arguments, Map<String, String>? environment, Directory? workingDirectory, FailMode failMode
});




}
/// @nodoc
class __$ShellExecuteRequestCopyWithImpl<$Res>
    implements _$ShellExecuteRequestCopyWith<$Res> {
  __$ShellExecuteRequestCopyWithImpl(this._self, this._then);

  final _ShellExecuteRequest _self;
  final $Res Function(_ShellExecuteRequest) _then;

/// Create a copy of ShellExecuteRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? command = null,Object? arguments = null,Object? environment = freezed,Object? workingDirectory = freezed,Object? failMode = null,}) {
  return _then(_ShellExecuteRequest(
command: null == command ? _self.command : command // ignore: cast_nullable_to_non_nullable
as String,arguments: null == arguments ? _self._arguments : arguments // ignore: cast_nullable_to_non_nullable
as List<String>,environment: freezed == environment ? _self._environment : environment // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,workingDirectory: freezed == workingDirectory ? _self.workingDirectory : workingDirectory // ignore: cast_nullable_to_non_nullable
as Directory?,failMode: null == failMode ? _self.failMode : failMode // ignore: cast_nullable_to_non_nullable
as FailMode,
  ));
}


}

// dart format on
