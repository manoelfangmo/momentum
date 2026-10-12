// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goals_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(goalsRepository)
final goalsRepositoryProvider = GoalsRepositoryProvider._();

final class GoalsRepositoryProvider
    extends
        $FunctionalProvider<GoalsRepository, GoalsRepository, GoalsRepository>
    with $Provider<GoalsRepository> {
  GoalsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalsRepositoryHash();

  @$internal
  @override
  $ProviderElement<GoalsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoalsRepository create(Ref ref) {
    return goalsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoalsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoalsRepository>(value),
    );
  }
}

String _$goalsRepositoryHash() => r'f5be8a20877caf4f37ef8c2d8765ecfa05b8757f';

/// One member's goals for one period.
///
/// A family keyed by both arguments: [Period] has `==`/`hashCode`, so two
/// widgets asking for the same member and period share a cache.

@ProviderFor(goalsForPeriod)
final goalsForPeriodProvider = GoalsForPeriodFamily._();

/// One member's goals for one period.
///
/// A family keyed by both arguments: [Period] has `==`/`hashCode`, so two
/// widgets asking for the same member and period share a cache.

final class GoalsForPeriodProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Goal>>,
          List<Goal>,
          FutureOr<List<Goal>>
        >
    with $FutureModifier<List<Goal>>, $FutureProvider<List<Goal>> {
  /// One member's goals for one period.
  ///
  /// A family keyed by both arguments: [Period] has `==`/`hashCode`, so two
  /// widgets asking for the same member and period share a cache.
  GoalsForPeriodProvider._({
    required GoalsForPeriodFamily super.from,
    required (String, Period) super.argument,
  }) : super(
         retry: null,
         name: r'goalsForPeriodProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$goalsForPeriodHash();

  @override
  String toString() {
    return r'goalsForPeriodProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Goal>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Goal>> create(Ref ref) {
    final argument = this.argument as (String, Period);
    return goalsForPeriod(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is GoalsForPeriodProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$goalsForPeriodHash() => r'378db3c0122c8dda7e7b0cf0a907d5573fa28f4a';

/// One member's goals for one period.
///
/// A family keyed by both arguments: [Period] has `==`/`hashCode`, so two
/// widgets asking for the same member and period share a cache.

final class GoalsForPeriodFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Goal>>, (String, Period)> {
  GoalsForPeriodFamily._()
    : super(
        retry: null,
        name: r'goalsForPeriodProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One member's goals for one period.
  ///
  /// A family keyed by both arguments: [Period] has `==`/`hashCode`, so two
  /// widgets asking for the same member and period share a cache.

  GoalsForPeriodProvider call(String memberId, Period period) =>
      GoalsForPeriodProvider._(argument: (memberId, period), from: this);

  @override
  String toString() => r'goalsForPeriodProvider';
}

/// Every member's goals in [groupId] for one period.
///
/// What the admin tab watches: one cache for the whole group rather than one
/// per member, because it shows all of them together.

@ProviderFor(groupGoalsForPeriod)
final groupGoalsForPeriodProvider = GroupGoalsForPeriodFamily._();

/// Every member's goals in [groupId] for one period.
///
/// What the admin tab watches: one cache for the whole group rather than one
/// per member, because it shows all of them together.

final class GroupGoalsForPeriodProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Goal>>,
          List<Goal>,
          FutureOr<List<Goal>>
        >
    with $FutureModifier<List<Goal>>, $FutureProvider<List<Goal>> {
  /// Every member's goals in [groupId] for one period.
  ///
  /// What the admin tab watches: one cache for the whole group rather than one
  /// per member, because it shows all of them together.
  GroupGoalsForPeriodProvider._({
    required GroupGoalsForPeriodFamily super.from,
    required (String, Period) super.argument,
  }) : super(
         retry: null,
         name: r'groupGoalsForPeriodProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupGoalsForPeriodHash();

  @override
  String toString() {
    return r'groupGoalsForPeriodProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Goal>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Goal>> create(Ref ref) {
    final argument = this.argument as (String, Period);
    return groupGoalsForPeriod(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupGoalsForPeriodProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupGoalsForPeriodHash() =>
    r'1d77c7e9566105a877346034c3aba80af0e21bd4';

/// Every member's goals in [groupId] for one period.
///
/// What the admin tab watches: one cache for the whole group rather than one
/// per member, because it shows all of them together.

final class GroupGoalsForPeriodFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Goal>>, (String, Period)> {
  GroupGoalsForPeriodFamily._()
    : super(
        retry: null,
        name: r'groupGoalsForPeriodProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Every member's goals in [groupId] for one period.
  ///
  /// What the admin tab watches: one cache for the whole group rather than one
  /// per member, because it shows all of them together.

  GroupGoalsForPeriodProvider call(String groupId, Period period) =>
      GroupGoalsForPeriodProvider._(argument: (groupId, period), from: this);

  @override
  String toString() => r'groupGoalsForPeriodProvider';
}

/// One member's goals of [type] whose deadline is before [before].
///
/// History uses this for every period that has already ended: [before] is the
/// start of the current period, so the current one stays on Goals. Load all
/// for MVP.
///
/// TODO: paginate past periods instead of loading all of them.

@ProviderFor(historyGoals)
final historyGoalsProvider = HistoryGoalsFamily._();

/// One member's goals of [type] whose deadline is before [before].
///
/// History uses this for every period that has already ended: [before] is the
/// start of the current period, so the current one stays on Goals. Load all
/// for MVP.
///
/// TODO: paginate past periods instead of loading all of them.

final class HistoryGoalsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Goal>>,
          List<Goal>,
          FutureOr<List<Goal>>
        >
    with $FutureModifier<List<Goal>>, $FutureProvider<List<Goal>> {
  /// One member's goals of [type] whose deadline is before [before].
  ///
  /// History uses this for every period that has already ended: [before] is the
  /// start of the current period, so the current one stays on Goals. Load all
  /// for MVP.
  ///
  /// TODO: paginate past periods instead of loading all of them.
  HistoryGoalsProvider._({
    required HistoryGoalsFamily super.from,
    required (String, GoalType, DateTime) super.argument,
  }) : super(
         retry: null,
         name: r'historyGoalsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$historyGoalsHash();

  @override
  String toString() {
    return r'historyGoalsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Goal>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Goal>> create(Ref ref) {
    final argument = this.argument as (String, GoalType, DateTime);
    return historyGoals(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is HistoryGoalsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$historyGoalsHash() => r'6b2ed94020804bbfc5c5d6293c8c84e5c6977553';

/// One member's goals of [type] whose deadline is before [before].
///
/// History uses this for every period that has already ended: [before] is the
/// start of the current period, so the current one stays on Goals. Load all
/// for MVP.
///
/// TODO: paginate past periods instead of loading all of them.

final class HistoryGoalsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Goal>>,
          (String, GoalType, DateTime)
        > {
  HistoryGoalsFamily._()
    : super(
        retry: null,
        name: r'historyGoalsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One member's goals of [type] whose deadline is before [before].
  ///
  /// History uses this for every period that has already ended: [before] is the
  /// start of the current period, so the current one stays on Goals. Load all
  /// for MVP.
  ///
  /// TODO: paginate past periods instead of loading all of them.

  HistoryGoalsProvider call(String ownerId, GoalType type, DateTime before) =>
      HistoryGoalsProvider._(argument: (ownerId, type, before), from: this);

  @override
  String toString() => r'historyGoalsProvider';
}
