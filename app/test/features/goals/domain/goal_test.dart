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
  String status = 'not_started',
  bool verified = false,
}) => {
  'id': 'goal-1',
  'owner_id': 'user-1',
  'group_id': 'group-1',
  'title': 'Run 5k',
  'type': 'daily',
  'deadline': deadline.toUtc().toIso8601String(),
  'status': status,
  'verified': verified,
  'created_at': createdAt.toUtc().toIso8601String(),
};

Goal goalWith({
  required DateTime deadline,
  required DateTime createdAt,
  GoalStatus status = GoalStatus.notStarted,
  bool verified = false,
}) => Goal(
  id: 'goal-1',
  ownerId: 'user-1',
  groupId: 'group-1',
  title: 'Run 5k',
  type: GoalType.daily,
  deadline: deadline,
  status: status,
  verified: verified,
  createdAt: createdAt,
);

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
        row(
          deadline: deadline,
          createdAt: createdAt,
          status: 'complete',
          verified: true,
        ),
      );

      expect(goal.id, 'goal-1');
      expect(goal.ownerId, 'user-1');
      expect(goal.groupId, 'group-1');
      expect(goal.title, 'Run 5k');
      expect(goal.type, GoalType.daily);
      expect(goal.status, GoalStatus.complete);
      expect(goal.verified, isTrue);
    });

    test('reads verified false by default from the row', () {
      final goal = Goal.fromJson(row(deadline: deadline, createdAt: createdAt));

      expect(goal.verified, isFalse);
      expect(goal.status, GoalStatus.notStarted);
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

  group('countsAsDone', () {
    test('is true only when complete and verified', () {
      expect(
        goalWith(
          deadline: deadline,
          createdAt: createdAt,
          status: GoalStatus.complete,
          verified: true,
        ).countsAsDone,
        isTrue,
      );
    });

    test('is false when complete but not verified', () {
      expect(
        goalWith(
          deadline: deadline,
          createdAt: createdAt,
          status: GoalStatus.complete,
        ).countsAsDone,
        isFalse,
      );
    });

    test('is false for every other status', () {
      for (final status in [GoalStatus.notStarted, GoalStatus.inProgress]) {
        expect(
          goalWith(
            deadline: deadline,
            createdAt: createdAt,
            status: status,
          ).countsAsDone,
          isFalse,
        );
      }
    });
  });

  group('isLocked', () {
    test('follows verified', () {
      expect(
        goalWith(deadline: deadline, createdAt: createdAt).isLocked,
        isFalse,
      );
      expect(
        goalWith(
          deadline: deadline,
          createdAt: createdAt,
          status: GoalStatus.complete,
          verified: true,
        ).isLocked,
        isTrue,
      );
    });
  });

  group('isOverdue', () {
    final goal = goalWith(deadline: deadline, createdAt: createdAt);
    final tomorrow = deadline.add(const Duration(days: 1));

    test('is false on the deadline itself and true one millisecond later', () {
      expect(goal.isOverdue(deadline), isFalse);
      expect(
        goal.isOverdue(deadline.add(const Duration(milliseconds: 1))),
        isTrue,
      );
    });

    test('an unverified complete goal is overdue after the deadline', () {
      expect(
        goal
            .copyWith(status: GoalStatus.complete)
            .isOverdue(tomorrow),
        isTrue,
      );
    });

    test('a verified complete goal is never overdue', () {
      expect(
        goal
            .copyWith(status: GoalStatus.complete, verified: true)
            .isOverdue(tomorrow),
        isFalse,
      );
    });
  });
}
