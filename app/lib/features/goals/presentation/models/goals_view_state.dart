import 'package:freezed_annotation/freezed_annotation.dart';

part 'goals_view_state.freezed.dart';

/// What the goals tabs are looking at: whose goals, and which day.
///
/// One state for all four tabs, so a member chosen in the app bar applies
/// everywhere, and a date chosen on any tab is the date every tab derives
/// its period from. Day is that date, Week the week that contains it, and
/// so on. The admin screen keeps its own day.
///
/// [selectedDay] is a local midnight, so two reads of the clock on the same
/// day are equal and a passing second rebuilds nothing.
@freezed
abstract class GoalsViewState with _$GoalsViewState {
  const factory GoalsViewState({
    required String selectedMemberId,
    required DateTime selectedDay,
  }) = _GoalsViewState;
}
