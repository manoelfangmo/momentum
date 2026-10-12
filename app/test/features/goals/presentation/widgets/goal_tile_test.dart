import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/providers.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:app/features/goals/presentation/widgets/goal_actions.dart';
import 'package:app/features/goals/presentation/widgets/goal_menu.dart';
import 'package:app/features/goals/presentation/widgets/goal_status_chip.dart';
import 'package:app/features/goals/presentation/widgets/goal_tile.dart';
import 'package:app/features/goals/presentation/widgets/verified_badge.dart';
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
  String? assignedBy,
  Period? period,
}) {
  final goals = period ?? _today;
  return Goal(
    id: 'goal-1',
    ownerId: 'user-1',
    assignedBy: assignedBy,
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
  late MockGroupsRepository groups;

  setUp(() {
    groups = MockGroupsRepository();
    when(groups.fetchMembers('group-1')).thenAnswer((_) async => [_ada, _sam]);
  });

  Future<void> pumpTile(
    WidgetTester tester,
    Goal goal,
    DateTime now, {
    // Nobody signed in by default: the tile still renders, and GoalActions
    // and GoalMenu both offer nothing. Which control each one shows lives in
    // goal_actions_test and goal_menu_test.
    Member? viewer,
    bool isAdmin = false,
  }) {
    return tester.pumpWidget(
      ProviderScope(
        retry: (count, error) => null,
        overrides: [
          clockProvider.overrideWithValue(() => now),
          currentMemberProvider.overrideWith((ref) => viewer),
          groupsRepositoryProvider.overrideWithValue(groups),
          isGroupAdminProvider.overrideWith((ref) async => isAdmin),
        ],
        child: MaterialApp(
          home: Scaffold(body: GoalTile(goal: goal)),
        ),
      ),
    );
  }

  testWidgets('shows the title, the deadline and the status', (tester) async {
    await pumpTile(tester, goalWith(), DateTime(2026, 10, 7, 9));

    expect(find.text('Run 5k'), findsOneWidget);
    expect(find.text('Due Oct 7, 2026, 11:59 PM'), findsOneWidget);
    expect(find.text('Not started'), findsOneWidget);
    expect(find.byType(GoalStatusChip), findsOneWidget);
  });

  testWidgets('an in-progress goal says so', (tester) async {
    await pumpTile(
      tester,
      goalWith(status: GoalStatus.inProgress),
      DateTime(2026, 10, 7, 9),
    );

    expect(find.text('In progress'), findsOneWidget);
  });

  testWidgets('reads as overdue once the deadline has passed', (tester) async {
    await pumpTile(tester, goalWith(), DateTime(2026, 10, 8, 9));

    expect(find.text('Overdue'), findsOneWidget);
  });

  testWidgets('a verified complete goal is never overdue', (tester) async {
    await pumpTile(
      tester,
      goalWith(status: GoalStatus.complete, verified: true),
      DateTime(2026, 10, 8, 9),
    );

    expect(find.text('Complete'), findsOneWidget);
    expect(find.text('Overdue'), findsNothing);
  });

  testWidgets('a complete unverified goal can still read as overdue', (
    tester,
  ) async {
    await pumpTile(
      tester,
      goalWith(status: GoalStatus.complete),
      DateTime(2026, 10, 8, 9),
    );

    expect(find.text('Overdue'), findsOneWidget);
    expect(find.text('Awaiting verification'), findsOneWidget);
  });

  testWidgets('a verified goal shows the badge', (tester) async {
    await pumpTile(
      tester,
      goalWith(status: GoalStatus.complete, verified: true),
      DateTime(2026, 10, 7, 9),
    );

    expect(find.byType(VerifiedBadge), findsOneWidget);
    expect(find.text('Verified'), findsOneWidget);
    expect(find.text('Awaiting verification'), findsNothing);
  });

  testWidgets('carries the actions and the menu', (tester) async {
    await pumpTile(tester, goalWith(), DateTime(2026, 10, 7, 9));

    expect(find.byType(GoalActions), findsOneWidget);
    expect(find.byType(GoalMenu), findsOneWidget);
  });

  testWidgets('says who assigned the goal', (tester) async {
    await pumpTile(
      tester,
      goalWith(assignedBy: _sam.id),
      DateTime(2026, 10, 7, 9),
      viewer: _ada,
    );
    await tester.pumpAndSettle();

    expect(find.text('Assigned by Sam'), findsOneWidget);
  });

  testWidgets('says nothing about assigning on an own goal', (tester) async {
    await pumpTile(tester, goalWith(), DateTime(2026, 10, 7, 9), viewer: _ada);
    await tester.pumpAndSettle();

    expect(find.textContaining('Assigned by'), findsNothing);
  });

  testWidgets("fits everything the admin is owed on a narrow phone", (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    // A status picker, a Verify and the menu, all on a goal with the longest
    // badge row there is.
    await pumpTile(
      tester,
      goalWith(status: GoalStatus.complete),
      DateTime(2026, 10, 8, 9),
      viewer: _sam,
      isAdmin: true,
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Verify'), findsOneWidget);
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
  });

  testWidgets('offers the owner of an assigned goal no menu', (tester) async {
    await pumpTile(
      tester,
      goalWith(assignedBy: _sam.id),
      DateTime(2026, 10, 7, 9),
      viewer: _ada,
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.more_vert), findsNothing);
  });

  testWidgets('offers the owner the menu on an unverified goal', (
    tester,
  ) async {
    await pumpTile(tester, goalWith(), DateTime(2026, 10, 7, 9), viewer: _ada);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.more_vert), findsOneWidget);
  });

  testWidgets('offers nobody else the menu', (tester) async {
    await pumpTile(tester, goalWith(), DateTime(2026, 10, 7, 9), viewer: _sam);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.more_vert), findsNothing);
  });

  testWidgets('takes the menu away once the goal is verified', (tester) async {
    await pumpTile(
      tester,
      goalWith(status: GoalStatus.complete, verified: true),
      DateTime(2026, 10, 7, 9),
      viewer: _ada,
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.more_vert), findsNothing);
  });
}
