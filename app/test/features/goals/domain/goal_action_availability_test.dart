import 'package:app/core/domain/domain.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_action_availability.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:flutter_test/flutter_test.dart';

const _owner = 'user-1';
const _other = 'user-2';

Goal goalWith(GoalStatus status) => Goal(
  id: 'goal-1',
  ownerId: _owner,
  groupId: 'group-1',
  title: 'Run 5k',
  type: GoalType.daily,
  deadline: DateTime(2026, 10, 6, 23, 59, 59, 999),
  status: status,
  createdAt: DateTime(2026, 10, 6, 7),
);

void main() {
  group('a pending goal', () {
    test('can be verified by anyone but the owner', () {
      expect(
        availabilityFor(goalWith(GoalStatus.pending), _other),
        const CanVerify(),
      );
    });

    test('can be marked missed by the owner', () {
      expect(
        availabilityFor(goalWith(GoalStatus.pending), _owner),
        const CanMarkMissed(),
      );
    });

    test('never offers the owner a verify', () {
      expect(
        availabilityFor(goalWith(GoalStatus.pending), _owner),
        isNot(isA<CanVerify>()),
      );
    });
  });

  group('a settled goal offers nothing', () {
    for (final status in [GoalStatus.complete, GoalStatus.missed]) {
      test('${status.name}, to the owner and to everyone else', () {
        expect(availabilityFor(goalWith(status), _owner), const NoAction());
        expect(availabilityFor(goalWith(status), _other), const NoAction());
      });
    }
  });

  test('the overdue pending goal of someone else can still be verified', () {
    final goal = goalWith(GoalStatus.pending);
    final tomorrow = goal.deadline.add(const Duration(days: 1));

    expect(goal.isOverdue(tomorrow), isTrue);
    expect(availabilityFor(goal, _other), const CanVerify());
  });
}
