import 'package:app/core/domain/domain.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/history/domain/history_section.dart';

/// Groups [goals] under the period each one belongs to.
///
/// Sections are newest [Period.start] first. Goals inside a section follow
/// [Goal.createdAt], oldest first, the same order a current-period list uses.
List<HistorySection> groupByPeriod(List<Goal> goals) {
  final grouped = <Period, List<Goal>>{};
  for (final goal in goals) {
    grouped.putIfAbsent(goal.period, () => []).add(goal);
  }

  final periods = grouped.keys.toList()
    ..sort((a, b) => b.start.compareTo(a.start));

  return [
    for (final period in periods)
      HistorySection(
        period: period,
        goals: List<Goal>.of(grouped[period]!)
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
      ),
  ];
}
