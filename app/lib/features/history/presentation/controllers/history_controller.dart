import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/core/utils/providers.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/goals/data/goals_repository.dart';
import 'package:app/features/history/domain/group_by_period.dart';
import 'package:app/features/history/domain/history_section.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'history_controller.g.dart';

/// The signed-in member's past [type] goals, grouped by ended period.
///
/// History is self-only: there is no member picker. [before] is the start of
/// the current period, so the period still open stays on Goals.
///
/// A family keyed by [type]: the four tabs are four caches.
///
/// TODO: paginate past periods instead of loading all of them.
@riverpod
Future<List<HistorySection>> historySections(Ref ref, GoalType type) async {
  final member = await ref.watch(currentMemberProvider.future);
  if (member == null) throw const NotFoundException();

  final now = ref.watch(clockProvider)();
  final before = Period.containing(now, type).start;
  final goals = await ref.watch(
    historyGoalsProvider(member.id, type, before).future,
  );
  return groupByPeriod(goals);
}
