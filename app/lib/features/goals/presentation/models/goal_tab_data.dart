import 'package:app/core/domain/domain.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal_tab_data.freezed.dart';

/// Everything one tab renders: the goals, plus the member and period its
/// header names and its pull to refresh re-reads.
///
/// A presentation type, not a domain one: [Goal] describes the business, this
/// describes what one screen needs in hand to build a frame.
@freezed
abstract class GoalTabData with _$GoalTabData {
  const factory GoalTabData({
    required String memberId,
    required Period period,
    required List<Goal> goals,
  }) = _GoalTabData;
}
