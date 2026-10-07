import 'package:app/core/domain/domain.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:flutter_test/flutter_test.dart';

/// A row as PostgREST sends it: snake_case keys and UTC timestamps.
///
/// The timestamps are built from local [DateTime]s so the expectations hold in
/// whatever zone the suite runs in.
Map<String, Object?> row({
  required DateTime deadline,
  required DateTime createdAt,
  String status = 'pending',
}) => {
  'id': 'goal-1',
  'owner_id': 'user-1',
  'group_id': 'group-1',
  'title': 'Run 5k',
  'type': 'daily',
  'deadline': deadline.toUtc().toIso8601String(),
  'status': status,
  'created_at': createdAt.toUtc().toIso8601String(),
};

void main() {
  final deadline = DateTime(2026, 10, 6, 23, 59, 59, 999);
  final createdAt = DateTime(2026, 10, 6, 7, 15);

  group('fromJson', () {
    test('reads UTC timestamps as local ones', () {
      final goal = Goal.fromJson(row(deadline: deadline, createdAt: createdAt));

      expect(goal.deadline, deadline);
      expect(goal.deadline.isUtc, isFalse);
      expect(goal.createdAt, createdAt);
      expect(goal.createdAt.isUtc, isFalse);
    });

    test('reads the rest of the columns', () {
      final goal = Goal.fromJson(
        row(deadline: deadline, createdAt: createdAt, status: 'complete'),
      );

      expect(goal.id, 'goal-1');
      expect(goal.ownerId, 'user-1');
      expect(goal.groupId, 'group-1');
      expect(goal.title, 'Run 5k');
      expect(goal.type, GoalType.daily);
      expect(goal.status, GoalStatus.complete);
    });

    test('an offset is the same instant as the matching Z timestamp', () {
      final zulu = Goal.fromJson(row(deadline: deadline, createdAt: createdAt));
      final offset = Goal.fromJson({
        ...row(deadline: deadline, createdAt: createdAt),
        'deadline': deadline
            .toUtc()
            .add(const Duration(hours: 2))
            .toIso8601String()
            .replaceFirst('Z', '+02:00'),
      });

      expect(offset.deadline, zulu.deadline);
    });
  });

  group('period', () {
    test('is the period its deadline is the last instant of', () {
      final goal = Goal.fromJson(row(deadline: deadline, createdAt: createdAt));

      expect(goal.period, Period.containing(createdAt, GoalType.daily));
      expect(goal.period.deadline, goal.deadline);
    });

    test('a goal created late in the evening stays in that day', () {
      final lateCreate = DateTime(2026, 10, 6, 23, 59, 59, 998);
      final goal = Goal.fromJson(
        row(deadline: deadline, createdAt: lateCreate),
      );

      expect(goal.period.start, DateTime(2026, 10, 6));
      expect(goal.period.end, DateTime(2026, 10, 7));
    });
  });

  group('isOverdue', () {
    final goal = Goal(
      id: 'goal-1',
      ownerId: 'user-1',
      groupId: 'group-1',
      title: 'Run 5k',
      type: GoalType.daily,
      deadline: deadline,
      status: GoalStatus.pending,
      createdAt: createdAt,
    );

    test('is false on the deadline itself and true one millisecond later', () {
      expect(goal.isOverdue(deadline), isFalse);
      expect(
        goal.isOverdue(deadline.add(const Duration(milliseconds: 1))),
        isTrue,
      );
    });

    test('only a pending goal is ever overdue', () {
      final tomorrow = deadline.add(const Duration(days: 1));

      expect(
        goal.copyWith(status: GoalStatus.complete).isOverdue(tomorrow),
        isFalse,
      );
      expect(
        goal.copyWith(status: GoalStatus.missed).isOverdue(tomorrow),
        isFalse,
      );
    });
  });
}
