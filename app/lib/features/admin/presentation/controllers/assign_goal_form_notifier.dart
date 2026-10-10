import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/features/admin/presentation/models/assign_goal_form_state.dart';
import 'package:app/features/goals/application/goal_service.dart';
import 'package:app/features/goals/data/goals_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'assign_goal_form_notifier.g.dart';

/// The draft behind the assign sheet, and the submit that turns it into a
/// row someone else owns.
///
/// Autodisposing, so closing the sheet throws the draft away and the next one
/// opens with nobody picked.
@riverpod
class AssignGoalFormNotifier extends _$AssignGoalFormNotifier {
  @override
  AssignGoalFormState build() => const AssignGoalFormState();

  void ownerChanged(String? ownerId) =>
      state = state.copyWith(ownerId: ownerId);

  void titleChanged(String title) => state = state.copyWith(title: title);

  /// Assigns the drafted goal for [type], the type of the tab the sheet was
  /// opened from.
  ///
  /// Through `GoalService` rather than the repository: the deadline is the
  /// end of the current period of [type], which needs the clock.
  ///
  /// The admin picking themselves is not a special case here. `assign_goal`
  /// leaves `assigned_by` null when the owner is the caller, so a goal the
  /// admin sets for themselves comes back as a normal own goal.
  ///
  /// Rethrows so the sheet can toast the failure and stay open with the draft
  /// still in it.
  Future<void> submit({required GoalType type}) async {
    final ownerId = state.ownerId;
    // The dropdown refuses to submit without a member, so this only catches
    // a race with someone leaving the group.
    if (ownerId == null) {
      throw const ValidationException('Choose who this goal is for.');
    }

    await ref
        .read(goalServiceProvider)
        .assignGoal(ownerId: ownerId, title: state.title.trim(), type: type);

    // The whole of both families: the new goal lands in the admin tab this
    // was opened from and in the owner's own tab, and a stale list somewhere
    // else is not worth naming each key to avoid.
    ref.invalidate(groupGoalsForPeriodProvider);
    ref.invalidate(goalsForPeriodProvider);
    state = const AssignGoalFormState();
  }
}
