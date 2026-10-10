// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_action_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Runs one write against one goal and holds its progress.
///
/// A family keyed by [goalId], so a call in flight only locks the tile it
/// was started from rather than every tile in the list. There is no result to
/// carry: the RPCs return the updated row, but the lists re-read it anyway.
///
/// Every action here is a single repository call, so they go straight to
/// `GoalsRepository` rather than through a service.

@ProviderFor(GoalActionController)
final goalActionControllerProvider = GoalActionControllerFamily._();

/// Runs one write against one goal and holds its progress.
///
/// A family keyed by [goalId], so a call in flight only locks the tile it
/// was started from rather than every tile in the list. There is no result to
/// carry: the RPCs return the updated row, but the lists re-read it anyway.
///
/// Every action here is a single repository call, so they go straight to
/// `GoalsRepository` rather than through a service.
final class GoalActionControllerProvider
    extends $AsyncNotifierProvider<GoalActionController, void> {
  /// Runs one write against one goal and holds its progress.
  ///
  /// A family keyed by [goalId], so a call in flight only locks the tile it
  /// was started from rather than every tile in the list. There is no result to
  /// carry: the RPCs return the updated row, but the lists re-read it anyway.
  ///
  /// Every action here is a single repository call, so they go straight to
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
    r'21e7ab2a6a89988586c755f3c4c00dc0dadf27f8';

/// Runs one write against one goal and holds its progress.
///
/// A family keyed by [goalId], so a call in flight only locks the tile it
/// was started from rather than every tile in the list. There is no result to
/// carry: the RPCs return the updated row, but the lists re-read it anyway.
///
/// Every action here is a single repository call, so they go straight to
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

  /// Runs one write against one goal and holds its progress.
  ///
  /// A family keyed by [goalId], so a call in flight only locks the tile it
  /// was started from rather than every tile in the list. There is no result to
  /// carry: the RPCs return the updated row, but the lists re-read it anyway.
  ///
  /// Every action here is a single repository call, so they go straight to
  /// `GoalsRepository` rather than through a service.

  GoalActionControllerProvider call(String goalId) =>
      GoalActionControllerProvider._(argument: goalId, from: this);

  @override
  String toString() => r'goalActionControllerProvider';
}

/// Runs one write against one goal and holds its progress.
///
/// A family keyed by [goalId], so a call in flight only locks the tile it
/// was started from rather than every tile in the list. There is no result to
/// carry: the RPCs return the updated row, but the lists re-read it anyway.
///
/// Every action here is a single repository call, so they go straight to
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
