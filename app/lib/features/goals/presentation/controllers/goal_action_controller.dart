import 'dart:async';

import 'package:app/features/goals/data/goals_repository.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'goal_action_controller.g.dart';

/// Runs one write against one goal and holds its progress.
///
/// A family keyed by [goalId], so a call in flight only locks the tile it
/// was started from rather than every tile in the list. There is no result to
/// carry: the RPCs return the updated row, but the lists re-read it anyway.
///
/// Every action here is a single repository call, so they go straight to
/// `GoalsRepository` rather than through a service.
@riverpod
class GoalActionController extends _$GoalActionController {
  @override
  FutureOr<void> build(String goalId) {}

  /// Sets the owner's own unverified goal to [status].
  Future<void> setStatus(Goal goal, GoalStatus status) {
    return _run(
      () => ref.read(goalsRepositoryProvider).setStatus(goal.id, status),
    );
  }

  /// Marks someone else's complete, unverified goal as verified.
  Future<void> verify(Goal goal) {
    return _run(() => ref.read(goalsRepositoryProvider).verify(goal.id));
  }

  /// Takes back the verification of a goal the admin does not own, leaving
  /// it complete and unlocked.
  Future<void> unverify(Goal goal) {
    return _run(() => ref.read(goalsRepositoryProvider).unverify(goal.id));
  }

  /// Renames a goal. [title] is stored as given; the sheet trims it, and so
  /// does the RPC.
  Future<void> updateTitle(Goal goal, String title) {
    return _run(
      () => ref.read(goalsRepositoryProvider).updateTitle(goal.id, title),
    );
  }

  /// Removes a goal. Its events stay behind; each carries a copy of it.
  Future<void> delete(Goal goal) {
    return _run(() => ref.read(goalsRepositoryProvider).deleteGoal(goal.id));
  }

  Future<void> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(action);

    if (result case AsyncError(:final error, :final stackTrace)) {
      state = AsyncError(error, stackTrace);
      return;
    }

    // Settled before the invalidation, which rebuilds the tile watching this
    // and can take the notifier with it.
    state = const AsyncData(null);

    // The whole family: the goal is in the tab it was tapped from, but the
    // other tabs, the admin tab, and History read lists it is also in, and a
    // stale row somewhere else is not worth naming each key to avoid.
    ref.invalidate(goalsForPeriodProvider);
    ref.invalidate(groupGoalsForPeriodProvider);
    ref.invalidate(historyGoalsProvider);
  }
}
