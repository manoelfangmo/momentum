import 'package:freezed_annotation/freezed_annotation.dart';

import 'goal.dart';
import 'goal_status.dart';

part 'goal_permissions.freezed.dart';

/// Everything one viewer may do to one goal.
///
/// Five independent answers rather than one choice: an owner can change the
/// status of their goal and rename it, and the admin can do both on a goal
/// they could also delete. The RPCs check the same rules, so this decides
/// what to show, not what is allowed.
@freezed
abstract class GoalPermissions with _$GoalPermissions {
  const factory GoalPermissions({
    required bool canChangeStatus,
    required bool canVerify,
    required bool canUnverify,
    required bool canEdit,
    required bool canDelete,
  }) = _GoalPermissions;

  /// Nothing at all. What to show before there is a viewer to compare against.
  static const none = GoalPermissions(
    canChangeStatus: false,
    canVerify: false,
    canUnverify: false,
    canEdit: false,
    canDelete: false,
  );
}

/// What [viewerId] may do to [goal], given whether they are the group admin.
///
/// Verifying is what locks a goal, and only the admin can unlock it:
///
/// - change status: the owner while unverified, the admin on any unverified
///   goal.
/// - verify: anyone but the owner, on a complete unverified goal. The admin
///   is a member like the rest here, even if they set the status themselves.
/// - un-verify: the admin alone, on a verified goal they do not own. Their
///   own goal is [canVerify]'s rule in reverse.
/// - edit and delete: the admin on any goal, verified ones included. The
///   owner only while the goal is unverified and not assigned — an assigned
///   goal is the admin's wording, and the owner just moves its status.
///
/// Nothing expires, so the deadline is not part of any of this.
GoalPermissions permissionsFor(
  Goal goal, {
  required String viewerId,
  required bool isAdmin,
}) {
  final isOwner = goal.ownerId == viewerId;
  final ownerMayManage = isOwner && !goal.verified && !goal.isAssigned;

  return GoalPermissions(
    canChangeStatus: !goal.verified && (isOwner || isAdmin),
    canVerify: !goal.verified && !isOwner && goal.status == GoalStatus.complete,
    canUnverify: goal.verified && isAdmin && !isOwner,
    canEdit: isAdmin || ownerMayManage,
    canDelete: isAdmin || ownerMayManage,
  );
}
