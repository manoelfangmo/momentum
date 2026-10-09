import 'dart:async';

import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/core/utils/providers.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/goals/data/goals_repository.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:app/features/goals/presentation/widgets/goal_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks.dart';

const _ada = Member(id: 'user-1', name: 'Ada', groupId: 'group-1');
const _sam = Member(id: 'user-2', name: 'Sam', groupId: 'group-1');

final _now = DateTime(2026, 10, 7, 9);
final _today = Period.containing(_now, GoalType.daily);

Goal goalWith({
  GoalStatus status = GoalStatus.notStarted,
  bool verified = false,
  String ownerId = 'user-1',
}) => Goal(
  id: 'goal-1',
  ownerId: ownerId,
  groupId: 'group-1',
  title: 'Run 5k',
  type: GoalType.daily,
  deadline: _today.deadline,
  status: status,
  verified: verified,
  createdAt: _today.start,
);

void main() {
  late MockGoalsRepository goals;

  setUp(() {
    goals = MockGoalsRepository();
    when(goals.deleteGoal(any)).thenAnswer((_) async {});
    when(goals.updateTitle(any, any)).thenAnswer((_) async => goalWith());
    when(
      goals.fetchGoals(
        ownerId: anyNamed('ownerId'),
        period: anyNamed('period'),
      ),
    ).thenAnswer((_) async => []);
  });

  Future<void> pumpMenu(
    WidgetTester tester, {
    required Goal goal,
    required Member viewer,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        retry: (count, error) => null,
        overrides: [
          goalsRepositoryProvider.overrideWithValue(goals),
          currentMemberProvider.overrideWith((ref) => viewer),
          clockProvider.overrideWithValue(() => _now),
        ],
        child: MaterialApp(
          home: Scaffold(body: GoalMenu(goal: goal)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
  }

  testWidgets('the owner of an unverified goal gets Edit and Delete', (
    tester,
  ) async {
    await pumpMenu(tester, goal: goalWith(), viewer: _ada);
    await openMenu(tester);

    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('nobody else gets a menu at all', (tester) async {
    await pumpMenu(tester, goal: goalWith(), viewer: _sam);

    expect(find.byIcon(Icons.more_vert), findsNothing);
  });

  testWidgets('a verified goal offers the owner no menu', (tester) async {
    await pumpMenu(
      tester,
      goal: goalWith(status: GoalStatus.complete, verified: true),
      viewer: _ada,
    );

    expect(find.byIcon(Icons.more_vert), findsNothing);
  });

  testWidgets('a complete goal still has a menu until it is verified', (
    tester,
  ) async {
    await pumpMenu(
      tester,
      goal: goalWith(status: GoalStatus.complete),
      viewer: _ada,
    );

    expect(find.byIcon(Icons.more_vert), findsOneWidget);
  });

  testWidgets('Edit opens the sheet on the stored title', (tester) async {
    await pumpMenu(tester, goal: goalWith(), viewer: _ada);
    await openMenu(tester);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Day goal'), findsOneWidget);
    expect(find.text('Run 5k'), findsOneWidget);
  });

  testWidgets('Delete names the goal and says it cannot be undone', (
    tester,
  ) async {
    await pumpMenu(tester, goal: goalWith(), viewer: _ada);
    await openMenu(tester);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text("Delete 'Run 5k'? This can't be undone."), findsOneWidget);
    verifyNever(goals.deleteGoal(any));
  });

  testWidgets('cancelling the confirm keeps the goal', (tester) async {
    await pumpMenu(tester, goal: goalWith(), viewer: _ada);
    await openMenu(tester);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(goals.deleteGoal(any));
  });

  testWidgets('confirming deletes the goal and says so', (tester) async {
    await pumpMenu(tester, goal: goalWith(), viewer: _ada);
    await openMenu(tester);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    verify(goals.deleteGoal('goal-1')).called(1);
    expect(find.widgetWithText(SnackBar, 'Goal deleted'), findsOneWidget);
  });

  testWidgets('a rejected delete toasts the reason instead', (tester) async {
    when(goals.deleteGoal(any)).thenThrow(
      const PermissionException(
        'Only the member who set a goal can delete it.',
      ),
    );

    await pumpMenu(tester, goal: goalWith(), viewer: _ada);
    await openMenu(tester);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(
        SnackBar,
        'Only the member who set a goal can delete it.',
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(SnackBar, 'Goal deleted'), findsNothing);
  });

  testWidgets('the delete waits for the call before it reports', (
    tester,
  ) async {
    final inFlight = Completer<void>();
    when(goals.deleteGoal(any)).thenAnswer((_) => inFlight.future);

    await pumpMenu(tester, goal: goalWith(), viewer: _ada);
    await openMenu(tester);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pump();

    expect(find.widgetWithText(SnackBar, 'Goal deleted'), findsNothing);

    inFlight.complete();
    await tester.pumpAndSettle();
    expect(find.widgetWithText(SnackBar, 'Goal deleted'), findsOneWidget);
  });
}
