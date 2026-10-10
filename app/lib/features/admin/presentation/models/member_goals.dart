import 'package:app/core/domain/domain.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'member_goals.freezed.dart';

/// One section of an admin tab: a member of the group and what they set for
/// the period on screen.
///
/// A presentation type, not a domain one. The database returns a period as a
/// flat list of goals; the admin reads it as a list of people, including the
/// ones with nothing set.
@freezed
abstract class MemberGoals with _$MemberGoals {
  const factory MemberGoals({
    required Member member,
    required List<Goal> goals,
  }) = _MemberGoals;
}
