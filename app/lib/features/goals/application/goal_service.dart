import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/core/utils/providers.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/goals/data/goals_repository.dart';
import 'package:app/features/goals/data/models.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_permissions.dart';
import 'package:app/features/groups/data/groups_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'goal_service.g.dart';

/// Making a goal, which needs more than the goals feature owns: the member
/// row from auth for the owner and group, and the clock for the deadline.
class GoalService {
  GoalService(this._ref);

  final Ref _ref;

  /// Creates a goal for the signed-in member, due at the end of the current
  /// period of [type].
  ///
  /// Members only create goals for themselves, so there is no owner argument;
  /// the tab decides [type]. The deadline is the last instant of the period
  /// containing now, which is also what the insert policy expects to see on a
  /// not_started, unverified row.
  Future<Goal> createGoal({
    required String title,
    required GoalType type,
  }) async {
    final member = await _ref.read(currentMemberProvider.future);
    final groupId = member?.groupId;
    if (member == null || groupId == null) throw const NotFoundException();

    final now = _ref.read(clockProvider)();
    return _ref
        .read(goalsRepositoryProvider)
        .createGoal(
          CreateGoalCommand(
            ownerId: member.id,
            groupId: groupId,
            title: title,
            type: type,
            deadline: Period.containing(now, type).deadline,
          ),
        );
  }

  /// Gives [ownerId] a goal, due at the end of the current period of [type].
  ///
  /// Here rather than on the repository for the same reason as [createGoal]:
  /// the deadline is computed from the clock. It is always the current
  /// period, never the day the admin has picked on the Day tab — an assigned
  /// goal is for now.
  ///
  /// No group argument and no check that the admin is the admin: the RPC
  /// takes both from the caller, and refuses anyone else.
  Future<Goal> assignGoal({
    required String ownerId,
    required String title,
    required GoalType type,
  }) {
    final now = _ref.read(clockProvider)();
    return _ref
        .read(goalsRepositoryProvider)
        .assignGoal(
          AssignGoalCommand(
            ownerId: ownerId,
            title: title,
            type: type,
            deadline: Period.containing(now, type).deadline,
          ),
        );
  }
}

@Riverpod(keepAlive: true)
GoalService goalService(Ref ref) => GoalService(ref);

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
@riverpod
GoalPermissions goalPermissions(Ref ref, Goal goal) {
  final viewerId = ref.watch(currentMemberProvider).value?.id;
  if (viewerId == null) return GoalPermissions.none;

  return permissionsFor(
    goal,
    viewerId: viewerId,
    isAdmin: ref.watch(isGroupAdminProvider).value ?? false,
  );
}
