import 'goal.dart';
import 'goal_status.dart';

/// The one action a viewer may take on a goal, if any.
///
/// Cases are const singletons, so two of the same case are equal.
sealed class GoalActionAvailability {
  const GoalActionAvailability();
}

/// Someone other than the owner, looking at a pending goal.
final class CanVerify extends GoalActionAvailability {
  const CanVerify();
}

/// The owner, looking at their own pending goal.
final class CanMarkMissed extends GoalActionAvailability {
  const CanMarkMissed();
}

/// Nothing to do: the goal is already complete or missed.
final class NoAction extends GoalActionAvailability {
  const NoAction();
}

/// What [viewerId] may do to [goal].
///
/// Anyone except the owner verifies; only the owner marks missed. The RPCs
/// check the same two rules, so this decides what to show, not what is
/// allowed.
GoalActionAvailability availabilityFor(Goal goal, String viewerId) {
  if (goal.status != GoalStatus.pending) return const NoAction();
  return goal.ownerId == viewerId ? const CanMarkMissed() : const CanVerify();
}
