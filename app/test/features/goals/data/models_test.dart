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

  group('toJson', () {
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
}
