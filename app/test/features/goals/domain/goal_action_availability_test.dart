import 'package:app/core/domain/domain.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_action_availability.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:flutter_test/flutter_test.dart';

const _owner = 'user-1';
const _other = 'user-2';

Goal goalWith(GoalStatus status, {bool verified = false}) => Goal(
  id: 'goal-1',
  ownerId: _owner,
  groupId: 'group-1',
  title: 'Run 5k',
  type: GoalType.daily,
  deadline: DateTime(2026, 10, 6, 23, 59, 59, 999),
  status: status,
  verified: verified,
  createdAt: DateTime(2026, 10, 6, 7),
);

void main() {
  group('availabilityFor', () {
    for (final status in GoalStatus.values) {
      test(
        'the owner can change status on an unverified ${status.name} goal',
        () {
          expect(
            availabilityFor(goalWith(status), _owner),
            const CanChangeStatus(),
          );
        },
      );

      test(
        'a verified ${status.name} goal offers the owner nothing',
        () {
          expect(
            availabilityFor(goalWith(status, verified: true), _owner),
            const NoAction(),
          );
        },
      );

      test(
        'a verified ${status.name} goal offers everyone else nothing',
        () {
          expect(
            availabilityFor(goalWith(status, verified: true), _other),
            const NoAction(),
          );
        },
      );
    }

    test('anyone but the owner can verify an unverified complete goal', () {
      expect(
        availabilityFor(goalWith(GoalStatus.complete), _other),
        const CanVerify(),
      );
    });

    test('the owner is never offered a verify', () {
      expect(
        availabilityFor(goalWith(GoalStatus.complete), _owner),
        isNot(isA<CanVerify>()),
      );
    });

    for (final status in [GoalStatus.notStarted, GoalStatus.inProgress]) {
      test(
        'an unverified ${status.name} goal offers everyone else nothing',
        () {
          expect(availabilityFor(goalWith(status), _other), const NoAction());
        },
      );
    }

    test('an overdue complete goal can still be verified', () {
      final goal = goalWith(GoalStatus.complete);
      final tomorrow = goal.deadline.add(const Duration(days: 1));

      expect(goal.isOverdue(tomorrow), isTrue);
      expect(availabilityFor(goal, _other), const CanVerify());
    });

    test('an overdue unverified goal can still change status', () {
      final goal = goalWith(GoalStatus.notStarted);
      final tomorrow = goal.deadline.add(const Duration(days: 1));

      expect(goal.isOverdue(tomorrow), isTrue);
      expect(availabilityFor(goal, _owner), const CanChangeStatus());
    });
  });

  group('canManage', () {
    for (final status in GoalStatus.values) {
      test('the owner can manage an unverified ${status.name} goal', () {
        expect(canManage(goalWith(status), _owner), isTrue);
      });

      test('nobody else can manage an unverified ${status.name} goal', () {
        expect(canManage(goalWith(status), _other), isFalse);
      });

      test('a verified ${status.name} goal is locked for the owner', () {
        expect(canManage(goalWith(status, verified: true), _owner), isFalse);
      });

      test('a verified ${status.name} goal is locked for everyone else', () {
        expect(canManage(goalWith(status, verified: true), _other), isFalse);
      });
    }

    test('an overdue unverified goal can still be managed', () {
      final goal = goalWith(GoalStatus.notStarted);
      final tomorrow = goal.deadline.add(const Duration(days: 1));

      expect(goal.isOverdue(tomorrow), isTrue);
      expect(canManage(goal, _owner), isTrue);
    });

    test("a complete goal is the owner's until someone verifies it", () {
      expect(canManage(goalWith(GoalStatus.complete), _owner), isTrue);
      expect(
        canManage(goalWith(GoalStatus.complete, verified: true), _owner),
        isFalse,
      );
    });
  });
}
