// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(goalService)
final goalServiceProvider = GoalServiceProvider._();

final class GoalServiceProvider
    extends $FunctionalProvider<GoalService, GoalService, GoalService>
    with $Provider<GoalService> {
  GoalServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalServiceHash();

  @$internal
  @override
  $ProviderElement<GoalService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoalService create(Ref ref) {
    return goalService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoalService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoalService>(value),
    );
  }
}

String _$goalServiceHash() => r'6b4f5b8360aedbbb575a394715ce87a8650339d0';

/// What the signed-in member may do to [goal].
///
/// Here rather than in the widget so no tile compares member ids. The member
/// is already loaded by the time a goal is on screen — the router keeps a
/// member without a group off the goals pages — so an unresolved member is
/// treated as nothing to offer.

@ProviderFor(goalActionAvailability)
final goalActionAvailabilityProvider = GoalActionAvailabilityFamily._();

/// What the signed-in member may do to [goal].
///
/// Here rather than in the widget so no tile compares member ids. The member
/// is already loaded by the time a goal is on screen — the router keeps a
/// member without a group off the goals pages — so an unresolved member is
/// treated as nothing to offer.

final class GoalActionAvailabilityProvider
    extends
        $FunctionalProvider<
          GoalActionAvailability,
          GoalActionAvailability,
          GoalActionAvailability
        >
    with $Provider<GoalActionAvailability> {
  /// What the signed-in member may do to [goal].
  ///
  /// Here rather than in the widget so no tile compares member ids. The member
  /// is already loaded by the time a goal is on screen — the router keeps a
  /// member without a group off the goals pages — so an unresolved member is
  /// treated as nothing to offer.
  GoalActionAvailabilityProvider._({
    required GoalActionAvailabilityFamily super.from,
    required Goal super.argument,
  }) : super(
         retry: null,
         name: r'goalActionAvailabilityProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$goalActionAvailabilityHash();

  @override
  String toString() {
    return r'goalActionAvailabilityProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<GoalActionAvailability> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GoalActionAvailability create(Ref ref) {
    final argument = this.argument as Goal;
    return goalActionAvailability(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoalActionAvailability value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoalActionAvailability>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GoalActionAvailabilityProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$goalActionAvailabilityHash() =>
    r'141f60a346fcdedb9cadf7d29a09d2feb0009dd1';

/// What the signed-in member may do to [goal].
///
/// Here rather than in the widget so no tile compares member ids. The member
/// is already loaded by the time a goal is on screen — the router keeps a
/// member without a group off the goals pages — so an unresolved member is
/// treated as nothing to offer.

final class GoalActionAvailabilityFamily extends $Family
    with $FunctionalFamilyOverride<GoalActionAvailability, Goal> {
  GoalActionAvailabilityFamily._()
    : super(
        retry: null,
        name: r'goalActionAvailabilityProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What the signed-in member may do to [goal].
  ///
  /// Here rather than in the widget so no tile compares member ids. The member
  /// is already loaded by the time a goal is on screen — the router keeps a
  /// member without a group off the goals pages — so an unresolved member is
  /// treated as nothing to offer.

  GoalActionAvailabilityProvider call(Goal goal) =>
      GoalActionAvailabilityProvider._(argument: goal, from: this);

  @override
  String toString() => r'goalActionAvailabilityProvider';
}
