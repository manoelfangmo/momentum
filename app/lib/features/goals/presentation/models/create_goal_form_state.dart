import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_goal_form_state.freezed.dart';

/// The goal being typed into the new goal sheet.
///
/// Only the title: the type comes from the tab that opened the sheet, and the
/// deadline is the end of the current period of that type, so neither is
/// something the member edits.
@freezed
abstract class CreateGoalFormState with _$CreateGoalFormState {
  const factory CreateGoalFormState({@Default('') String title}) =
      _CreateGoalFormState;
}
