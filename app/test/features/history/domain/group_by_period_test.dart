import 'package:app/core/domain/domain.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:app/features/history/domain/group_by_period.dart';
import 'package:app/features/history/domain/history_section.dart';
import 'package:flutter_test/flutter_test.dart';

final _oct5 = Period.containing(DateTime(2026, 10, 5), GoalType.daily);
final _oct4 = Period.containing(DateTime(2026, 10, 4), GoalType.daily);
final _oct3 = Period.containing(DateTime(2026, 10, 3), GoalType.daily);

Goal goalCalled(
  String title,
  Period period, {
  DateTime? createdAt,
  GoalStatus status = GoalStatus.notStarted,
  bool verified = false,
}) => Goal(
  id: 'goal-$title',
  ownerId: 'user-1',
  groupId: 'group-1',
  title: title,
  type: period.type,
  deadline: period.deadline,
  status: status,
  verified: verified,
  createdAt: createdAt ?? period.start,
);

void main() {
  test('an empty list is no sections', () {
    expect(groupByPeriod(const []), isEmpty);
  });

  test('goals in the same period share a section', () {
    final run = goalCalled('Run', _oct5, createdAt: _oct5.start);
    final read = goalCalled(
      'Read',
      _oct5,
      createdAt: _oct5.start.add(const Duration(hours: 1)),
    );

    expect(groupByPeriod([read, run]), [
      HistorySection(period: _oct5, goals: [run, read]),
    ]);
  });

  test('sections are newest period first', () {
    final oldest = goalCalled('Oldest', _oct3);
    final newest = goalCalled('Newest', _oct5);
    final middle = goalCalled('Middle', _oct4);

    final sections = groupByPeriod([oldest, newest, middle]);

    expect(sections.map((section) => section.period), [_oct5, _oct4, _oct3]);
  });

  test('goals inside a section follow createdAt, oldest first', () {
    final later = goalCalled(
      'Later',
      _oct5,
      createdAt: _oct5.start.add(const Duration(hours: 2)),
    );
    final earlier = goalCalled('Earlier', _oct5, createdAt: _oct5.start);

    expect(groupByPeriod([later, earlier]).single.goals, [earlier, later]);
  });

  test('not started, in progress and complete all belong', () {
    final notStarted = goalCalled('Not started', _oct5);
    final complete = goalCalled(
      'Complete',
      _oct4,
      status: GoalStatus.complete,
    );
    final inProgress = goalCalled(
      'In progress',
      _oct3,
      status: GoalStatus.inProgress,
    );

    final sections = groupByPeriod([notStarted, complete, inProgress]);

    expect(sections, [
      HistorySection(period: _oct5, goals: [notStarted]),
      HistorySection(period: _oct4, goals: [complete]),
      HistorySection(period: _oct3, goals: [inProgress]),
    ]);
  });

  test('does not mutate the list it was given', () {
    final later = goalCalled(
      'Later',
      _oct5,
      createdAt: _oct5.start.add(const Duration(hours: 1)),
    );
    final earlier = goalCalled('Earlier', _oct5, createdAt: _oct5.start);
    final input = [later, earlier];

    groupByPeriod(input);

    expect(input, [later, earlier]);
  });
}
