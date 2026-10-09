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

/// Whether the signed-in member may rename or delete [goal].
///
/// Alongside [goalActionAvailability] and for the same reason: the member
/// comes from auth, so no widget compares ids to decide whether to draw the
/// menu. An unresolved member is offered nothing.

@ProviderFor(canManageGoal)
final canManageGoalProvider = CanManageGoalFamily._();

/// Whether the signed-in member may rename or delete [goal].
///
/// Alongside [goalActionAvailability] and for the same reason: the member
/// comes from auth, so no widget compares ids to decide whether to draw the
/// menu. An unresolved member is offered nothing.

final class CanManageGoalProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the signed-in member may rename or delete [goal].
  ///
  /// Alongside [goalActionAvailability] and for the same reason: the member
  /// comes from auth, so no widget compares ids to decide whether to draw the
  /// menu. An unresolved member is offered nothing.
  CanManageGoalProvider._({
    required CanManageGoalFamily super.from,
    required Goal super.argument,
  }) : super(
         retry: null,
         name: r'canManageGoalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$canManageGoalHash();

  @override
  String toString() {
    return r'canManageGoalProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as Goal;
    return canManageGoal(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CanManageGoalProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$canManageGoalHash() => r'8d05d4cf36f0f694a2ccb71d50825ea9bd9031ec';

/// Whether the signed-in member may rename or delete [goal].
///
/// Alongside [goalActionAvailability] and for the same reason: the member
/// comes from auth, so no widget compares ids to decide whether to draw the
/// menu. An unresolved member is offered nothing.

final class CanManageGoalFamily extends $Family
    with $FunctionalFamilyOverride<bool, Goal> {
  CanManageGoalFamily._()
    : super(
        retry: null,
        name: r'canManageGoalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the signed-in member may rename or delete [goal].
  ///
  /// Alongside [goalActionAvailability] and for the same reason: the member
  /// comes from auth, so no widget compares ids to decide whether to draw the
  /// menu. An unresolved member is offered nothing.

  CanManageGoalProvider call(Goal goal) =>
      CanManageGoalProvider._(argument: goal, from: this);

  @override
  String toString() => r'canManageGoalProvider';
}
