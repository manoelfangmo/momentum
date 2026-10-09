import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/stats/domain/completion_stats.dart';

/// Complete-and-verified goals over every goal in [goals].
///
/// Everything else counts as a miss: only [Goal.countsAsDone] is in the
/// numerator. An empty list is 0 of 0, with no percent.
CompletionStats completionFor(List<Goal> goals) {
  final complete = goals.where((goal) => goal.countsAsDone).length;
  return CompletionStats(complete: complete, total: goals.length);
}
