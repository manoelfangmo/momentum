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
/// A family keyed by both arguments: [Period] has `==`/`hashCode`, so a tab
/// and the history page asking for the same member and period share a cache.

@ProviderFor(goalsForPeriod)
final goalsForPeriodProvider = GoalsForPeriodFamily._();

/// One member's goals for one period.
///
/// A family keyed by both arguments: [Period] has `==`/`hashCode`, so a tab
/// and the history page asking for the same member and period share a cache.

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
  /// A family keyed by both arguments: [Period] has `==`/`hashCode`, so a tab
  /// and the history page asking for the same member and period share a cache.
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
/// A family keyed by both arguments: [Period] has `==`/`hashCode`, so a tab
/// and the history page asking for the same member and period share a cache.

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
  /// A family keyed by both arguments: [Period] has `==`/`hashCode`, so a tab
  /// and the history page asking for the same member and period share a cache.

  GoalsForPeriodProvider call(String memberId, Period period) =>
      GoalsForPeriodProvider._(argument: (memberId, period), from: this);

  @override
  String toString() => r'goalsForPeriodProvider';
}
