// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'completion_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CompletionStats {

 int get complete; int get total;
/// Create a copy of CompletionStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompletionStatsCopyWith<CompletionStats> get copyWith => _$CompletionStatsCopyWithImpl<CompletionStats>(this as CompletionStats, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CompletionStats;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompletionStats&&(identical(other.complete, _this.complete) || other.complete == _this.complete)&&(identical(other.total, _this.total) || other.total == _this.total));
}


@override
int get hashCode {
  final _this = this as CompletionStats;
  return Object.hash(runtimeType,_this.complete,_this.total);
}

@override
String toString() {
  final _this = this as CompletionStats;
  return 'CompletionStats(complete: ${_this.complete}, total: ${_this.total})';
}


}

/// @nodoc
abstract mixin class $CompletionStatsCopyWith<$Res>  {
  factory $CompletionStatsCopyWith(CompletionStats value, $Res Function(CompletionStats) _then) = _$CompletionStatsCopyWithImpl;
@useResult
$Res call({
 int complete, int total
});




}
/// @nodoc
class _$CompletionStatsCopyWithImpl<$Res>
    implements $CompletionStatsCopyWith<$Res> {
  _$CompletionStatsCopyWithImpl(this._self, this._then);

  final CompletionStats _self;
  final $Res Function(CompletionStats) _then;

/// Create a copy of CompletionStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? complete = null,Object? total = null,}) {
  return _then(CompletionStats(
complete: null == complete ? _self.complete : complete // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CompletionStats].
extension CompletionStatsPatterns on CompletionStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompletionStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompletionStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompletionStats value)  $default,){
final _that = this;
switch (_that) {
case _CompletionStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompletionStats value)?  $default,){
final _that = this;
switch (_that) {
case _CompletionStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int complete,  int total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompletionStats() when $default != null:
return $default(_that.complete,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int complete,  int total)  $default,) {final _that = this;
switch (_that) {
case _CompletionStats():
return $default(_that.complete,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int complete,  int total)?  $default,) {final _that = this;
switch (_that) {
case _CompletionStats() when $default != null:
return $default(_that.complete,_that.total);case _:
  return null;

}
}

}

/// @nodoc


class _CompletionStats extends CompletionStats {
  const _CompletionStats({required this.complete, required this.total}): super._();
  

@override final  int complete;
@override final  int total;

/// Create a copy of CompletionStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompletionStatsCopyWith<_CompletionStats> get copyWith => __$CompletionStatsCopyWithImpl<_CompletionStats>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompletionStats&&(identical(other.complete, complete) || other.complete == complete)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode {
    return Object.hash(runtimeType,complete,total);
}

@override
String toString() {
    return 'CompletionStats(complete: $complete, total: $total)';
}


}

/// @nodoc
abstract mixin class _$CompletionStatsCopyWith<$Res> implements $CompletionStatsCopyWith<$Res> {
  factory _$CompletionStatsCopyWith(_CompletionStats value, $Res Function(_CompletionStats) _then) = __$CompletionStatsCopyWithImpl;
@override @useResult
$Res call({
 int complete, int total
});




}
/// @nodoc
class __$CompletionStatsCopyWithImpl<$Res>
    implements _$CompletionStatsCopyWith<$Res> {
  __$CompletionStatsCopyWithImpl(this._self, this._then);

  final _CompletionStats _self;
  final $Res Function(_CompletionStats) _then;

/// Create a copy of CompletionStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? complete = null,Object? total = null,}) {
  return _then(_CompletionStats(
complete: null == complete ? _self.complete : complete // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
