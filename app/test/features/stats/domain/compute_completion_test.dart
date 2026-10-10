import 'package:app/core/domain/domain.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:app/features/stats/domain/completion_stats.dart';
import 'package:app/features/stats/domain/compute_completion.dart';
import 'package:flutter_test/flutter_test.dart';

final _today = Period.containing(DateTime(2026, 10, 7, 9), GoalType.daily);

Goal goalWith(
  String id,
  GoalStatus status, {
  bool verified = false,
}) => Goal(
  id: id,
  ownerId: 'user-1',
  groupId: 'group-1',
  title: id,
  type: _today.type,
  deadline: _today.deadline,
  status: status,
  verified: verified,
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

  test('all complete and verified is 100%', () {
    final stats = completionFor([
      goalWith('a', GoalStatus.complete, verified: true),
      goalWith('b', GoalStatus.complete, verified: true),
      goalWith('c', GoalStatus.complete, verified: true),
    ]);

    expect(stats, const CompletionStats(complete: 3, total: 3));
    expect(stats.percent, 1);
    expect(wholePercent(stats), 100);
  });

  test('complete but unverified counts as a miss', () {
    final stats = completionFor([
      goalWith('claimed', GoalStatus.complete),
    ]);

    expect(stats, const CompletionStats(complete: 0, total: 1));
    expect(stats.percent, 0);
    expect(wholePercent(stats), 0);
  });

  test('unverified and incomplete both count against', () {
    final stats = completionFor([
      goalWith('done', GoalStatus.complete, verified: true),
      goalWith('waiting', GoalStatus.notStarted),
      goalWith('claimed', GoalStatus.complete),
    ]);

    expect(stats, const CompletionStats(complete: 1, total: 3));
    expect(wholePercent(stats), 33);
  });

  test('2 of 3 complete and verified rounds to 67%', () {
    final stats = completionFor([
      goalWith('a', GoalStatus.complete, verified: true),
      goalWith('b', GoalStatus.complete, verified: true),
      goalWith('c', GoalStatus.inProgress),
    ]);

    expect(stats, const CompletionStats(complete: 2, total: 3));
    expect(stats.percent, closeTo(2 / 3, 1e-10));
    expect(wholePercent(stats), 67);
  });
}
