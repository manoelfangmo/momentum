import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/core/utils/providers.dart';
import 'package:app/features/goals/data/goals_repository.dart';
import 'package:app/features/goals/presentation/controllers/goals_view_controller.dart';
import 'package:app/features/goals/presentation/models/goal_tab_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'goal_tab_controller.g.dart';

/// What the [type] tab shows: the shared selection turned into a period, and
/// the selected member's goals for it.
///
/// Only the Day tab follows `selectedDay`. Week, Month and Year always show
/// the period containing now, so there is nothing to put them out of date.
///
/// A family keyed by [type]: the four tabs are four caches, and each one
/// reloads on its own.
@riverpod
Future<GoalTabData> goalTabData(Ref ref, GoalType type) async {
  final view = ref.watch(goalsViewControllerProvider);
  // Signing out empties the selection a frame before the router takes the page
  // away. Failing here is what keeps that frame from asking the database for
  // nobody's goals.
  if (view.selectedMemberId == noMemberSelected) {
    throw const NotFoundException();
  }

  final now = ref.watch(clockProvider)();
  final period = type == GoalType.daily
      ? Period.containing(view.selectedDay, GoalType.daily)
      : Period.containing(now, type);

  final goals = await ref.watch(
    goalsForPeriodProvider(view.selectedMemberId, period).future,
  );
  return GoalTabData(
    memberId: view.selectedMemberId,
    period: period,
    goals: goals,
  );
}
