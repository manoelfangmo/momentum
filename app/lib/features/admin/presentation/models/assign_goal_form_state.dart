import 'package:freezed_annotation/freezed_annotation.dart';

part 'assign_goal_form_state.freezed.dart';

/// The goal being drafted in the assign sheet.
///
/// Two fields where the member's own sheet has one: the admin picks who the
/// goal is for. [ownerId] is null until they do, which is what the dropdown
/// renders as an empty field rather than a guess at who they meant.
///
/// The type comes from the tab that opened the sheet and the deadline is the
/// end of the current period of that type, so neither is drafted here.
@freezed
abstract class AssignGoalFormState with _$AssignGoalFormState {
  const factory AssignGoalFormState({
    String? ownerId,
    @Default('') String title,
  }) = _AssignGoalFormState;
}
