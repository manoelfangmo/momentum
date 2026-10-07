import 'package:app/core/domain/domain.dart';
import 'package:app/features/goals/application/goal_service.dart';
import 'package:app/features/goals/data/goals_repository.dart';
import 'package:app/features/goals/presentation/models/create_goal_form_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_goal_form_notifier.g.dart';

/// The draft behind the new goal sheet, and the submit that turns it into a
/// row.
///
/// Autodisposing, so closing the sheet throws the draft away and the next one
/// opens empty.
@riverpod
class CreateGoalFormNotifier extends _$CreateGoalFormNotifier {
  @override
  CreateGoalFormState build() => const CreateGoalFormState();

  void titleChanged(String title) => state = state.copyWith(title: title);

  /// Creates the drafted goal for [type], the type of the tab the sheet was
  /// opened from.
  ///
  /// Through `GoalService` rather than the repository: the insert needs the
  /// member row from auth and the clock, so it is more than one step and more
  /// than one feature.
  ///
  /// Rethrows so the sheet can toast the failure and stay open with the draft
  /// still in it.
  Future<void> submit({required GoalType type}) async {
    await ref
        .read(goalServiceProvider)
        .createGoal(title: state.title.trim(), type: type);

    // The whole family: the new goal belongs to the current period of [type],
    // but History and the other tabs read the same provider, and a stale list
    // somewhere else is not worth naming each key to avoid.
    ref.invalidate(goalsForPeriodProvider);
    state = const CreateGoalFormState();
  }
}
