import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/providers.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:app/features/goals/presentation/widgets/goal_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _today = Period.containing(DateTime(2026, 10, 7, 8), GoalType.daily);

Goal goalWith({GoalStatus status = GoalStatus.pending, Period? period}) {
  final goals = period ?? _today;
  return Goal(
    id: 'goal-1',
    ownerId: 'user-1',
    groupId: 'group-1',
    title: 'Run 5k',
    type: goals.type,
    deadline: goals.deadline,
    status: status,
    createdAt: goals.start,
  );
}

void main() {
  Future<void> pumpTile(WidgetTester tester, Goal goal, DateTime now) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [clockProvider.overrideWithValue(() => now)],
        child: MaterialApp(home: Scaffold(body: GoalTile(goal: goal))),
      ),
    );
  }

  testWidgets('shows the title, the deadline and the status', (tester) async {
    await pumpTile(tester, goalWith(), DateTime(2026, 10, 7, 9));

    expect(find.text('Run 5k'), findsOneWidget);
    expect(find.text('Due Oct 7, 2026, 11:59 PM'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
  });

  testWidgets('reads as overdue once the deadline has passed', (tester) async {
    await pumpTile(tester, goalWith(), DateTime(2026, 10, 8, 9));

    expect(find.text('Overdue'), findsOneWidget);
  });

  testWidgets('a settled goal is never overdue', (tester) async {
    await pumpTile(
      tester,
      goalWith(status: GoalStatus.complete),
      DateTime(2026, 10, 8, 9),
    );

    expect(find.text('Complete'), findsOneWidget);
    expect(find.text('Overdue'), findsNothing);
  });

  testWidgets('a missed goal says so', (tester) async {
    await pumpTile(
      tester,
      goalWith(status: GoalStatus.missed),
      DateTime(2026, 10, 8, 9),
    );

    expect(find.text('Missed'), findsOneWidget);
  });
}
