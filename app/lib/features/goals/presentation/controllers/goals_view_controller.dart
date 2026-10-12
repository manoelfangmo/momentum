import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/providers.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/goals/presentation/models/goals_view_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'goals_view_controller.g.dart';

/// The selection the four goal tabs share.
///
/// It lives above the tabs rather than inside one, so picking a member or a
/// day holds while the member moves between Day, Week, Month and Year.
///
/// Watching the member row rather than reading it means a sign-in or a group
/// change starts the page over on that member, which is the only sensible
/// thing to show once the previous selection may no longer be in the group.
@riverpod
class GoalsViewController extends _$GoalsViewController {
  @override
  GoalsViewState build() {
    // The router waits for the member row before `/goals` is reachable, so no
    // member here is a session on its way out rather than a load in flight.
    // Nobody is selected until one comes back, and `goalTabData` is where that
    // shows: throwing from here would escape a rebuild nothing is reading.
    final memberId = ref.watch(currentMemberProvider).value?.id;

    return GoalsViewState(
      selectedMemberId: memberId ?? noMemberSelected,
      selectedDay: _dayOf(ref.watch(clockProvider)()),
    );
  }

  /// Shows [memberId]'s goals in every tab.
  void selectMember(String memberId) {
    state = state.copyWith(selectedMemberId: memberId);
  }

  /// Points the Day tab at the day containing [date]. The way back to today
  /// is this with the clock's date: the selector has no other kind of move.
  void selectDay(DateTime date) {
    state = state.copyWith(selectedDay: _dayOf(date));
  }
}

/// The member id of nobody, which is what the tabs see while the session is on
/// its way out.
const noMemberSelected = '';

/// Local midnight of the day containing [instant].
///
/// Through [Period] so the Day tab and this agree on where a day starts.
DateTime _dayOf(DateTime instant) =>
    Period.containing(instant, GoalType.daily).start;
