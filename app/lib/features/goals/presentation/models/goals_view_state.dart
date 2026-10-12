import 'package:freezed_annotation/freezed_annotation.dart';

part 'goals_view_state.freezed.dart';

/// What the goals tabs are looking at: whose goals, and which day.
///
/// One state for all four tabs, so a member chosen in the app bar applies
/// everywhere. [selectedDay] only concerns the Day tab; Week, Month and Year
/// always show the current period.
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
