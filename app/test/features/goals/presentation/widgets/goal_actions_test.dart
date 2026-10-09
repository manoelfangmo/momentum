import 'dart:async';

import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/goals/data/goals_repository.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:app/features/goals/presentation/widgets/goal_actions.dart';
import 'package:app/features/goals/presentation/widgets/goal_status_picker.dart';
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
  GoalStatus status = GoalStatus.notStarted,
  bool verified = false,
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
    verified: verified,
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
    when(goals.verify(any)).thenAnswer((_) async => goalWith());
    when(goals.setStatus(any, any)).thenAnswer((_) async => goalWith());
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

  testWidgets('the owner of an unverified goal sees a status picker', (
    tester,
  ) async {
    await pumpActions(tester, goal: goalWith(), viewer: _ada);

    expect(find.byType(GoalStatusPicker), findsOneWidget);
    expect(find.text('Verify'), findsNothing);
  });

  testWidgets('someone else sees Verify only on a complete unverified goal', (
    tester,
  ) async {
    await pumpActions(
      tester,
      goal: goalWith(status: GoalStatus.complete),
      viewer: _sam,
    );

    expect(find.text('Verify'), findsOneWidget);
    expect(find.byType(GoalStatusPicker), findsNothing);
  });

  testWidgets('someone else sees nothing on a goal that is not complete', (
    tester,
  ) async {
    await pumpActions(tester, goal: goalWith(), viewer: _sam);

    expect(find.text('Verify'), findsNothing);
    expect(find.byType(GoalStatusPicker), findsNothing);
  });

  testWidgets('a verified goal offers a lock and nothing else', (tester) async {
    await pumpActions(
      tester,
      goal: goalWith(status: GoalStatus.complete, verified: true),
      viewer: _ada,
    );

    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.text('Verify'), findsNothing);
    expect(find.byType(GoalStatusPicker), findsNothing);
  });

  testWidgets('an overdue complete goal can still be verified', (tester) async {
    final yesterday = Period.containing(
      DateTime(2026, 10, 6, 8),
      GoalType.daily,
    );
    await pumpActions(
      tester,
      goal: goalWith(status: GoalStatus.complete, period: yesterday),
      viewer: _sam,
    );

    expect(find.text('Verify'), findsOneWidget);
  });

  testWidgets('Verify asks to confirm with the owner name first', (
    tester,
  ) async {
    await pumpActions(
      tester,
      goal: goalWith(status: GoalStatus.complete),
      viewer: _sam,
    );
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();

    expect(
      find.text("Verify 'Run 5k' for Ada? This can't be undone."),
      findsOneWidget,
    );
    verifyNever(goals.verify(any));
  });

  testWidgets('changing status does not ask to confirm', (tester) async {
    await pumpActions(tester, goal: goalWith(), viewer: _ada);
    await tester.tap(find.byType(GoalStatusPicker));
    await tester.pumpAndSettle();
    await tester.tap(find.text('In progress').last);
    await tester.pumpAndSettle();

    expect(find.text('Confirm'), findsNothing);
    verify(goals.setStatus('goal-1', GoalStatus.inProgress)).called(1);
  });

  testWidgets('choosing Complete shows the verify hint', (tester) async {
    await pumpActions(tester, goal: goalWith(), viewer: _ada);
    await tester.tap(find.byType(GoalStatusPicker));
    await tester.pumpAndSettle();

    expect(find.text('A groupmate needs to verify this.'), findsOneWidget);
  });

  testWidgets('cancelling the confirm does not call the repository', (
    tester,
  ) async {
    await pumpActions(
      tester,
      goal: goalWith(status: GoalStatus.complete),
      viewer: _sam,
    );
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(goals.verify(any));
  });

  testWidgets('Confirm on Verify calls the repository', (tester) async {
    await pumpActions(
      tester,
      goal: goalWith(status: GoalStatus.complete),
      viewer: _sam,
    );
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    verify(goals.verify('goal-1')).called(1);
  });

  testWidgets('the button spins while the call is in flight', (tester) async {
    final inFlight = Completer<Goal>();
    when(goals.verify(any)).thenAnswer((_) => inFlight.future);

    await pumpActions(
      tester,
      goal: goalWith(status: GoalStatus.complete),
      viewer: _sam,
    );
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Verify'), findsNothing);

    inFlight.complete(goalWith(status: GoalStatus.complete));
    await tester.pumpAndSettle();
  });

  testWidgets('a rejected RPC shows the mapped message in a toast', (
    tester,
  ) async {
    when(goals.verify(any)).thenThrow(
      const ValidationException(
        'That goal is already verified. Refresh to see it.',
      ),
    );

    await pumpActions(
      tester,
      goal: goalWith(status: GoalStatus.complete),
      viewer: _sam,
    );
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(
        SnackBar,
        'That goal is already verified. Refresh to see it.',
      ),
      findsOneWidget,
    );
  });
}
