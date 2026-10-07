import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:app/features/stats/domain/completion_stats.dart';

/// Complete goals over every goal in [goals].
///
/// Pending and missed both count against: only [GoalStatus.complete] is in
/// the numerator. An empty list is 0 of 0, with no percent.
CompletionStats completionFor(List<Goal> goals) {
  final complete = goals
      .where((goal) => goal.status == GoalStatus.complete)
      .length;
  return CompletionStats(complete: complete, total: goals.length);
}
