import 'dart:async';

import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/goals/data/goals_repository.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:app/features/goals/presentation/widgets/goal_actions.dart';
import 'package:app/features/groups/data/groups_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks.dart';

const _ada = Member(id: 'user-1', name: 'Ada', groupId: 'group-1');
const _sam = Member(id: 'user-2', name: 'Sam', groupId: 'group-1');

final _today = Period.containing(DateTime(2026, 10, 7, 8), GoalType.daily);

Goal goalWith({
  GoalStatus status = GoalStatus.pending,
  String ownerId = 'user-1',
  Period? period,
}) {
  final goals = period ?? _today;
  return Goal(
    id: 'goal-1',
    ownerId: ownerId,
    groupId: 'group-1',
    title: 'Run 5k',
    type: goals.type,
    deadline: goals.deadline,
    status: status,
    createdAt: goals.start,
  );
}

void main() {
  late MockGoalsRepository goals;
  late MockGroupsRepository groups;

  setUp(() {
    goals = MockGoalsRepository();
    groups = MockGroupsRepository();
    when(groups.fetchMembers('group-1')).thenAnswer((_) async => [_ada, _sam]);
    when(goals.verifyComplete(any)).thenAnswer((_) async => goalWith());
    when(goals.markMissed(any)).thenAnswer((_) async => goalWith());
    when(
      goals.fetchGoals(
        ownerId: anyNamed('ownerId'),
        period: anyNamed('period'),
      ),
    ).thenAnswer((_) async => []);
  });

  Future<void> pumpActions(
    WidgetTester tester, {
    required Goal goal,
    required Member viewer,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        retry: (count, error) => null,
        overrides: [
          goalsRepositoryProvider.overrideWithValue(goals),
          groupsRepositoryProvider.overrideWithValue(groups),
          currentMemberProvider.overrideWith((ref) => viewer),
        ],
        child: MaterialApp(
          home: Scaffold(body: GoalActions(goal: goal)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets("the owner of a pending goal sees only Missed", (tester) async {
    await pumpActions(tester, goal: goalWith(), viewer: _ada);

    expect(find.widgetWithText(TextButton, 'Missed'), findsOneWidget);
    expect(find.text('Verify'), findsNothing);
  });

  testWidgets("someone else sees only Verify", (tester) async {
    await pumpActions(tester, goal: goalWith(), viewer: _sam);

    expect(find.text('Verify'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Missed'), findsNothing);
  });

  testWidgets('a settled goal offers nothing', (tester) async {
    await pumpActions(
      tester,
      goal: goalWith(status: GoalStatus.complete),
      viewer: _sam,
    );

    expect(find.text('Verify'), findsNothing);
    expect(find.widgetWithText(TextButton, 'Missed'), findsNothing);
  });

  testWidgets('an overdue pending goal can still be verified', (tester) async {
    final yesterday = Period.containing(
      DateTime(2026, 10, 6, 8),
      GoalType.daily,
    );
    await pumpActions(
      tester,
      goal: goalWith(period: yesterday),
      viewer: _sam,
    );

    expect(find.text('Verify'), findsOneWidget);
  });

  testWidgets('Verify asks to confirm with the owner name first', (
    tester,
  ) async {
    await pumpActions(tester, goal: goalWith(), viewer: _sam);
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();

    expect(find.text("Mark 'Run 5k' as complete for Ada?"), findsOneWidget);
    verifyNever(goals.verifyComplete(any));
  });

  testWidgets('Missed asks to confirm first', (tester) async {
    await pumpActions(tester, goal: goalWith(), viewer: _ada);
    await tester.tap(find.text('Missed'));
    await tester.pumpAndSettle();

    expect(find.text("Mark 'Run 5k' as missed?"), findsOneWidget);
    verifyNever(goals.markMissed(any));
  });

  testWidgets('cancelling the confirm does not call the repository', (
    tester,
  ) async {
    await pumpActions(tester, goal: goalWith(), viewer: _ada);
    await tester.tap(find.text('Missed'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(goals.markMissed(any));
  });

  testWidgets('Confirm on Verify calls the repository', (tester) async {
    await pumpActions(tester, goal: goalWith(), viewer: _sam);
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    verify(goals.verifyComplete('goal-1')).called(1);
  });

  testWidgets('Confirm on Missed calls the repository', (tester) async {
    await pumpActions(tester, goal: goalWith(), viewer: _ada);
    await tester.tap(find.text('Missed'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    verify(goals.markMissed('goal-1')).called(1);
  });

  testWidgets('the button spins while the call is in flight', (tester) async {
    final inFlight = Completer<Goal>();
    when(goals.verifyComplete(any)).thenAnswer((_) => inFlight.future);

    await pumpActions(tester, goal: goalWith(), viewer: _sam);
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Verify'), findsNothing);

    inFlight.complete(goalWith());
    await tester.pumpAndSettle();
  });

  testWidgets('a rejected RPC shows the mapped message in a toast', (
    tester,
  ) async {
    when(goals.verifyComplete(any)).thenThrow(
      const ValidationException(
        'That goal was already settled. Refresh to see where it landed.',
      ),
    );

    await pumpActions(tester, goal: goalWith(), viewer: _sam);
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(
        SnackBar,
        'That goal was already settled. Refresh to see where it landed.',
      ),
      findsOneWidget,
    );
  });
}
