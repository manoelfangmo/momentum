import 'dart:async';

import 'package:app/features/goals/data/goals_repository.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'goal_action_controller.g.dart';

/// Runs the two status changes on one goal and holds their progress.
///
/// A family keyed by [goalId], so a verify in flight only locks the tile it
/// was started from rather than every tile in the list. There is no result to
/// carry: the RPC returns the updated row, but the lists re-read it anyway.
///
/// Both actions are a single repository call, so they go straight to
/// `GoalsRepository` rather than through a service.
@riverpod
class GoalActionController extends _$GoalActionController {
  @override
  FutureOr<void> build(String goalId) {}

  /// Marks someone else's pending goal complete.
  Future<void> verify(Goal goal) {
    return _run(
      () => ref.read(goalsRepositoryProvider).verifyComplete(goal.id),
    );
  }

  /// Marks the viewer's own pending goal missed.
  Future<void> markMissed(Goal goal) {
    return _run(() => ref.read(goalsRepositoryProvider).markMissed(goal.id));
  }

  Future<void> _run(Future<Goal> Function() action) async {
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
    // other tabs and History read the same member's lists, and a stale row
    // somewhere else is not worth naming each key to avoid.
    ref.invalidate(goalsForPeriodProvider);
    ref.invalidate(historyGoalsProvider);
  }
}
