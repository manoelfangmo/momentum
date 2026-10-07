// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'history_section.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HistorySection {

 Period get period; List<Goal> get goals;
/// Create a copy of HistorySection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HistorySectionCopyWith<HistorySection> get copyWith => _$HistorySectionCopyWithImpl<HistorySection>(this as HistorySection, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HistorySection;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HistorySection&&(identical(other.period, _this.period) || other.period == _this.period)&&const DeepCollectionEquality().equals(other.goals, _this.goals));
}


@override
int get hashCode {
  final _this = this as HistorySection;
  return Object.hash(runtimeType,_this.period,const DeepCollectionEquality().hash(_this.goals));
}

@override
String toString() {
  final _this = this as HistorySection;
  return 'HistorySection(period: ${_this.period}, goals: ${_this.goals})';
}


}

/// @nodoc
abstract mixin class $HistorySectionCopyWith<$Res>  {
  factory $HistorySectionCopyWith(HistorySection value, $Res Function(HistorySection) _then) = _$HistorySectionCopyWithImpl;
@useResult
$Res call({
 Period period, List<Goal> goals
});




}
/// @nodoc
class _$HistorySectionCopyWithImpl<$Res>
    implements $HistorySectionCopyWith<$Res> {
  _$HistorySectionCopyWithImpl(this._self, this._then);

  final HistorySection _self;
  final $Res Function(HistorySection) _then;

/// Create a copy of HistorySection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? period = null,Object? goals = null,}) {
  return _then(HistorySection(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as Period,goals: null == goals ? _self.goals : goals // ignore: cast_nullable_to_non_nullable
as List<Goal>,
  ));
}

}


/// Adds pattern-matching-related methods to [HistorySection].
extension HistorySectionPatterns on HistorySection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HistorySection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HistorySection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HistorySection value)  $default,){
final _that = this;
switch (_that) {
case _HistorySection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HistorySection value)?  $default,){
final _that = this;
switch (_that) {
case _HistorySection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Period period,  List<Goal> goals)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HistorySection() when $default != null:
return $default(_that.period,_that.goals);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Period period,  List<Goal> goals)  $default,) {final _that = this;
switch (_that) {
case _HistorySection():
return $default(_that.period,_that.goals);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Period period,  List<Goal> goals)?  $default,) {final _that = this;
switch (_that) {
case _HistorySection() when $default != null:
return $default(_that.period,_that.goals);case _:
  return null;

}
}

}

/// @nodoc


class _HistorySection implements HistorySection {
  const _HistorySection({required this.period, required  List<Goal> goals}): _goals = goals;
  

@override final  Period period;
 final  List<Goal> _goals;
@override List<Goal> get goals {
  if (_goals is EqualUnmodifiableListView) return _goals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_goals);
}


/// Create a copy of HistorySection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HistorySectionCopyWith<_HistorySection> get copyWith => __$HistorySectionCopyWithImpl<_HistorySection>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HistorySection&&(identical(other.period, period) || other.period == period)&&const DeepCollectionEquality().equals(other.goals, _goals));
}


@override
int get hashCode {
    return Object.hash(runtimeType,period,const DeepCollectionEquality().hash(_goals));
}

@override
String toString() {
    return 'HistorySection(period: $period, goals: $goals)';
}


}

/// @nodoc
abstract mixin class _$HistorySectionCopyWith<$Res> implements $HistorySectionCopyWith<$Res> {
  factory _$HistorySectionCopyWith(_HistorySection value, $Res Function(_HistorySection) _then) = __$HistorySectionCopyWithImpl;
@override @useResult
$Res call({
 Period period, List<Goal> goals
});




}
/// @nodoc
class __$HistorySectionCopyWithImpl<$Res>
    implements _$HistorySectionCopyWith<$Res> {
  __$HistorySectionCopyWithImpl(this._self, this._then);

  final _HistorySection _self;
  final $Res Function(_HistorySection) _then;

/// Create a copy of HistorySection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? period = null,Object? goals = null,}) {
  return _then(_HistorySection(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as Period,goals: null == goals ? _self._goals : goals // ignore: cast_nullable_to_non_nullable
as List<Goal>,
  ));
}


}

// dart format on
