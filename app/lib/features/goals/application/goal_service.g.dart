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
/// Here rather than in the widget so no tile compares member ids or works
/// out who the admin is. Both answers come from other features — the member
/// from auth, the admin flag from groups — which is what keeps the rule out
/// of `domain` on its own and in a provider.
///
/// The member is already loaded by the time a goal is on screen: the router
/// keeps a member without a group off the goals pages. An unresolved member
/// is offered nothing, and an admin flag still loading counts as not the
/// admin, so the first frame never shows a control the viewer cannot use.

@ProviderFor(goalPermissions)
final goalPermissionsProvider = GoalPermissionsFamily._();

/// What the signed-in member may do to [goal].
///
/// Here rather than in the widget so no tile compares member ids or works
/// out who the admin is. Both answers come from other features — the member
/// from auth, the admin flag from groups — which is what keeps the rule out
/// of `domain` on its own and in a provider.
///
/// The member is already loaded by the time a goal is on screen: the router
/// keeps a member without a group off the goals pages. An unresolved member
/// is offered nothing, and an admin flag still loading counts as not the
/// admin, so the first frame never shows a control the viewer cannot use.

final class GoalPermissionsProvider
    extends
        $FunctionalProvider<GoalPermissions, GoalPermissions, GoalPermissions>
    with $Provider<GoalPermissions> {
  /// What the signed-in member may do to [goal].
  ///
  /// Here rather than in the widget so no tile compares member ids or works
  /// out who the admin is. Both answers come from other features — the member
  /// from auth, the admin flag from groups — which is what keeps the rule out
  /// of `domain` on its own and in a provider.
  ///
  /// The member is already loaded by the time a goal is on screen: the router
  /// keeps a member without a group off the goals pages. An unresolved member
  /// is offered nothing, and an admin flag still loading counts as not the
  /// admin, so the first frame never shows a control the viewer cannot use.
  GoalPermissionsProvider._({
    required GoalPermissionsFamily super.from,
    required Goal super.argument,
  }) : super(
         retry: null,
         name: r'goalPermissionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$goalPermissionsHash();

  @override
  String toString() {
    return r'goalPermissionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<GoalPermissions> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoalPermissions create(Ref ref) {
    final argument = this.argument as Goal;
    return goalPermissions(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoalPermissions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoalPermissions>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GoalPermissionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$goalPermissionsHash() => r'3ec08d0c2f4c84070b5542fdcf8ae04887a29b5c';

/// What the signed-in member may do to [goal].
///
/// Here rather than in the widget so no tile compares member ids or works
/// out who the admin is. Both answers come from other features — the member
/// from auth, the admin flag from groups — which is what keeps the rule out
/// of `domain` on its own and in a provider.
///
/// The member is already loaded by the time a goal is on screen: the router
/// keeps a member without a group off the goals pages. An unresolved member
/// is offered nothing, and an admin flag still loading counts as not the
/// admin, so the first frame never shows a control the viewer cannot use.

final class GoalPermissionsFamily extends $Family
    with $FunctionalFamilyOverride<GoalPermissions, Goal> {
  GoalPermissionsFamily._()
    : super(
        retry: null,
        name: r'goalPermissionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What the signed-in member may do to [goal].
  ///
  /// Here rather than in the widget so no tile compares member ids or works
  /// out who the admin is. Both answers come from other features — the member
  /// from auth, the admin flag from groups — which is what keeps the rule out
  /// of `domain` on its own and in a provider.
  ///
  /// The member is already loaded by the time a goal is on screen: the router
  /// keeps a member without a group off the goals pages. An unresolved member
  /// is offered nothing, and an admin flag still loading counts as not the
  /// admin, so the first frame never shows a control the viewer cannot use.

  GoalPermissionsProvider call(Goal goal) =>
      GoalPermissionsProvider._(argument: goal, from: this);

  @override
  String toString() => r'goalPermissionsProvider';
}
