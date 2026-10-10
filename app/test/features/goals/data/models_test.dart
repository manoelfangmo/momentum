import 'package:app/core/database/rpc.dart';
import 'package:app/core/domain/domain.dart';
import 'package:app/features/goals/data/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final deadline = Period.containing(
    DateTime(2026, 10, 6, 9),
    GoalType.daily,
  ).deadline;

  CreateGoalCommand commandFor(DateTime deadline) => CreateGoalCommand(
    ownerId: 'user-1',
    groupId: 'group-1',
    title: 'Run 5k',
    type: GoalType.daily,
    deadline: deadline,
  );

  AssignGoalCommand assignFor(DateTime deadline) => AssignGoalCommand(
    ownerId: 'user-2',
    title: 'Run 5k',
    type: GoalType.daily,
    deadline: deadline,
  );

  group('CreateGoalCommand.toJson', () {
    test('uses the column names the insert expects', () {
      expect(commandFor(deadline).toJson().keys, [
        'owner_id',
        'group_id',
        'title',
        'type',
        'deadline',
      ]);
    });

    test('sends a local deadline as the same instant in UTC', () {
      final json = commandFor(deadline).toJson();

      expect(json['deadline'], deadline.toUtc().toIso8601String());
      expect(json['deadline'], endsWith('Z'));
      expect(DateTime.parse(json['deadline']! as String).toLocal(), deadline);
    });

    test('a deadline already in UTC is sent unchanged', () {
      expect(
        commandFor(deadline.toUtc()).toJson()['deadline'],
        commandFor(deadline).toJson()['deadline'],
      );
    });

    test('writes the type as the Postgres enum value', () {
      expect(commandFor(deadline).toJson()['type'], 'daily');
      expect(
        commandFor(deadline).copyWith(type: GoalType.weekly).toJson()['type'],
        'weekly',
      );
    });

    test('leaves status, verified, and created_at to the database', () {
      final json = commandFor(deadline).toJson();

      expect(json.containsKey('status'), isFalse);
      expect(json.containsKey('verified'), isFalse);
      expect(json.containsKey('created_at'), isFalse);
      expect(json.containsKey('id'), isFalse);
    });
  });

  group('AssignGoalCommand.toJson', () {
    test('uses the argument names assign_goal takes', () {
      expect(assignFor(deadline).toJson().keys, [
        Rpc.pOwnerId,
        Rpc.pTitle,
        Rpc.pType,
        Rpc.pDeadline,
      ]);
    });

    test('names the member who will own the goal, not the admin', () {
      final json = assignFor(deadline).toJson();

      expect(json[Rpc.pOwnerId], 'user-2');
      expect(json.containsKey('p_assigned_by'), isFalse);
      expect(json.containsKey(Rpc.pGroupId), isFalse);
    });

    test('sends a local deadline as the same instant in UTC', () {
      final json = assignFor(deadline).toJson();

      expect(json[Rpc.pDeadline], deadline.toUtc().toIso8601String());
      expect(json[Rpc.pDeadline], endsWith('Z'));
    });

    test('writes the type as the Postgres enum value', () {
      expect(assignFor(deadline).toJson()[Rpc.pType], 'daily');
      expect(
        assignFor(deadline).copyWith(type: GoalType.yearly).toJson()[Rpc.pType],
        'yearly',
      );
    });
  });
}
