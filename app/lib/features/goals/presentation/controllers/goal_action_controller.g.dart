// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_action_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Runs the two status changes on one goal and holds their progress.
///
/// A family keyed by [goalId], so a verify in flight only locks the tile it
/// was started from rather than every tile in the list. There is no result to
/// carry: the RPC returns the updated row, but the lists re-read it anyway.
///
/// Both actions are a single repository call, so they go straight to
/// `GoalsRepository` rather than through a service.

@ProviderFor(GoalActionController)
final goalActionControllerProvider = GoalActionControllerFamily._();

/// Runs the two status changes on one goal and holds their progress.
///
/// A family keyed by [goalId], so a verify in flight only locks the tile it
/// was started from rather than every tile in the list. There is no result to
/// carry: the RPC returns the updated row, but the lists re-read it anyway.
///
/// Both actions are a single repository call, so they go straight to
/// `GoalsRepository` rather than through a service.
final class GoalActionControllerProvider
    extends $AsyncNotifierProvider<GoalActionController, void> {
  /// Runs the two status changes on one goal and holds their progress.
  ///
  /// A family keyed by [goalId], so a verify in flight only locks the tile it
  /// was started from rather than every tile in the list. There is no result to
  /// carry: the RPC returns the updated row, but the lists re-read it anyway.
  ///
  /// Both actions are a single repository call, so they go straight to
  /// `GoalsRepository` rather than through a service.
  GoalActionControllerProvider._({
    required GoalActionControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'goalActionControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$goalActionControllerHash();

  @override
  String toString() {
    return r'goalActionControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  GoalActionController create() => GoalActionController();

  @override
  bool operator ==(Object other) {
    return other is GoalActionControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$goalActionControllerHash() =>
    r'377e9fd8a6ad5fcdf2a953c07ac82b0a4561e37e';

/// Runs the two status changes on one goal and holds their progress.
///
/// A family keyed by [goalId], so a verify in flight only locks the tile it
/// was started from rather than every tile in the list. There is no result to
/// carry: the RPC returns the updated row, but the lists re-read it anyway.
///
/// Both actions are a single repository call, so they go straight to
/// `GoalsRepository` rather than through a service.

final class GoalActionControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          GoalActionController,
          AsyncValue<void>,
          void,
          FutureOr<void>,
          String
        > {
  GoalActionControllerFamily._()
    : super(
        retry: null,
        name: r'goalActionControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Runs the two status changes on one goal and holds their progress.
  ///
  /// A family keyed by [goalId], so a verify in flight only locks the tile it
  /// was started from rather than every tile in the list. There is no result to
  /// carry: the RPC returns the updated row, but the lists re-read it anyway.
  ///
  /// Both actions are a single repository call, so they go straight to
  /// `GoalsRepository` rather than through a service.

  GoalActionControllerProvider call(String goalId) =>
      GoalActionControllerProvider._(argument: goalId, from: this);

  @override
  String toString() => r'goalActionControllerProvider';
}

/// Runs the two status changes on one goal and holds their progress.
///
/// A family keyed by [goalId], so a verify in flight only locks the tile it
/// was started from rather than every tile in the list. There is no result to
/// carry: the RPC returns the updated row, but the lists re-read it anyway.
///
/// Both actions are a single repository call, so they go straight to
/// `GoalsRepository` rather than through a service.

abstract class _$GoalActionController extends $AsyncNotifier<void> {
  late final _$args = ref.$arg as String;
  String get goalId => _$args;

  FutureOr<void> build(String goalId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
