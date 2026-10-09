import 'goal.dart';
import 'goal_status.dart';

/// The one action a viewer may take on a goal, if any.
///
/// Cases are const singletons, so two of the same case are equal.
sealed class GoalActionAvailability {
  const GoalActionAvailability();
}

/// The owner, looking at their own unverified goal.
final class CanChangeStatus extends GoalActionAvailability {
  const CanChangeStatus();
}

/// Someone other than the owner, looking at an unverified complete goal.
final class CanVerify extends GoalActionAvailability {
  const CanVerify();
}

/// Nothing to do: the goal is verified, or the viewer cannot act on it.
final class NoAction extends GoalActionAvailability {
  const NoAction();
}

/// What [viewerId] may do to [goal].
///
/// The owner can change status while the goal is unverified. Anyone else can
/// verify only a complete, unverified goal. Verified is final. The RPCs check
/// the same rules, so this decides what to show, not what is allowed.
GoalActionAvailability availabilityFor(Goal goal, String viewerId) {
  if (goal.verified) return const NoAction();
  if (goal.ownerId == viewerId) return const CanChangeStatus();
  if (goal.status == GoalStatus.complete) return const CanVerify();
  return const NoAction();
}

/// Whether [viewerId] may rename [goal] or delete it.
///
/// Renaming and deleting are the owner's alone, and verifying locks them the
/// same way it locks status. Separate from [availabilityFor] because these
/// are not one of the mutually exclusive actions on a tile: an owner looking
/// at an unverified goal can both change its status and rename it.
bool canManage(Goal goal, String viewerId) =>
    goal.ownerId == viewerId && !goal.verified;
