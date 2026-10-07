import 'package:app/core/domain/domain.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:app/features/stats/domain/completion_stats.dart';
import 'package:app/features/stats/domain/compute_completion.dart';
import 'package:flutter_test/flutter_test.dart';

final _today = Period.containing(DateTime(2026, 10, 7, 9), GoalType.daily);

Goal goalWith(String id, GoalStatus status) => Goal(
  id: id,
  ownerId: 'user-1',
  groupId: 'group-1',
  title: id,
  type: _today.type,
  deadline: _today.deadline,
  status: status,
  createdAt: _today.start,
);

int? wholePercent(CompletionStats stats) {
  final percent = stats.percent;
  if (percent == null) return null;
  return (percent * 100).round();
}

void main() {
  test('an empty list is 0 of 0 with no percent', () {
    final stats = completionFor(const []);

    expect(stats, const CompletionStats(complete: 0, total: 0));
    expect(stats.percent, isNull);
    expect(wholePercent(stats), isNull);
  });

  test('all complete is 100%', () {
    final stats = completionFor([
      goalWith('a', GoalStatus.complete),
      goalWith('b', GoalStatus.complete),
      goalWith('c', GoalStatus.complete),
    ]);

    expect(stats, const CompletionStats(complete: 3, total: 3));
    expect(stats.percent, 1);
    expect(wholePercent(stats), 100);
  });

  test('pending and missed both count against', () {
    final stats = completionFor([
      goalWith('done', GoalStatus.complete),
      goalWith('waiting', GoalStatus.pending),
      goalWith('missed', GoalStatus.missed),
    ]);

    expect(stats, const CompletionStats(complete: 1, total: 3));
    expect(wholePercent(stats), 33);
  });

  test('2 of 3 complete rounds to 67%', () {
    final stats = completionFor([
      goalWith('a', GoalStatus.complete),
      goalWith('b', GoalStatus.complete),
      goalWith('c', GoalStatus.pending),
    ]);

    expect(stats, const CompletionStats(complete: 2, total: 3));
    expect(stats.percent, closeTo(2 / 3, 1e-10));
    expect(wholePercent(stats), 67);
  });
}
