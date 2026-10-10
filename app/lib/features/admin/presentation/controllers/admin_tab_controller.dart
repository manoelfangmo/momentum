import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/core/utils/providers.dart';
import 'package:app/features/admin/presentation/controllers/admin_view_controller.dart';
import 'package:app/features/admin/presentation/models/member_goals.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/goals/data/goals_repository.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/groups/data/groups_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'admin_tab_controller.g.dart';

/// Which period the [type] admin tab is on.
///
/// Only Day follows a selection. Week, Month and Year are the period
/// containing now and there is no way back through them: ended periods are
/// History's, and the admin screen has none.
///
/// A provider of its own so the tab's data and its header read one answer
/// rather than each working the rule out again.
@riverpod
Period adminPeriod(Ref ref, GoalType type) {
  if (type != GoalType.daily) {
    return Period.containing(ref.watch(clockProvider)(), type);
  }
  return Period.containing(
    ref.watch(adminViewControllerProvider),
    GoalType.daily,
  );
}

/// Every member of the admin's group with their [type] goals for that period.
///
/// One section per member, the ones with nothing set included: the admin is
/// looking for who has not started as much as for who has finished. The
/// signed-in admin comes first, then everyone else by name, which is the
/// order the members read arrives in.
///
/// A family keyed by [type]: the four tabs are four caches, and each one
/// reloads on its own.
@riverpod
Future<List<MemberGoals>> adminTabData(Ref ref, GoalType type) async {
  final member = await ref.watch(currentMemberProvider.future);
  final groupId = member?.groupId;
  if (member == null || groupId == null) throw const NotFoundException();

  final period = ref.watch(adminPeriodProvider(type));
  // Both futures are in hand before either is awaited, so the two reads run
  // at once rather than one after the other.
  final goals = ref.watch(groupGoalsForPeriodProvider(groupId, period).future);
  final members = ref.watch(groupMembersProvider(groupId).future);

  return _byMember(await members, await goals, adminId: member.id);
}

/// [goals] filed under the member who owns each one, admin first.
///
/// A goal whose owner is not in [members] is left out: the two reads can
/// disagree for a moment after somebody leaves the group, and there is no
/// section to show it in.
List<MemberGoals> _byMember(
  List<Member> members,
  List<Goal> goals, {
  required String adminId,
}) {
  final byOwner = <String, List<Goal>>{};
  for (final goal in goals) {
    (byOwner[goal.ownerId] ??= []).add(goal);
  }

  MemberGoals sectionFor(Member member) =>
      MemberGoals(member: member, goals: byOwner[member.id] ?? const []);

  return [
    for (final member in members)
      if (member.id == adminId) sectionFor(member),
    for (final member in members)
      if (member.id != adminId) sectionFor(member),
  ];
}
