import 'dart:async';

import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/core/utils/providers.dart';
import 'package:app/core/widgets/day_selector.dart';
import 'package:app/features/admin/presentation/controllers/admin_view_controller.dart';
import 'package:app/features/admin/presentation/widgets/admin_tab_view.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/goals/data/goals_repository.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:app/features/goals/presentation/widgets/goal_tile.dart';
import 'package:app/features/groups/data/groups_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks.dart';

/// Ada created the group, so she is the one looking at this screen.
const _ada = Member(id: 'user-1', name: 'Ada', groupId: 'group-1');
const _grace = Member(id: 'user-2', name: 'Grace', groupId: 'group-1');

/// A Wednesday, so the days either side are in the same week and month.
final _now = DateTime(2026, 10, 7, 9);
final _today = Period.containing(_now, GoalType.daily);

Goal goalCalled(
  String title, {
  required String ownerId,
  Period? period,
  GoalStatus status = GoalStatus.notStarted,
  bool verified = false,
}) {
  final its = period ?? _today;
  return Goal(
    id: 'goal-$title',
    ownerId: ownerId,
    groupId: 'group-1',
    title: title,
    type: its.type,
    deadline: its.deadline,
    status: status,
    verified: verified,
    createdAt: its.start,
  );
}

void main() {
  late MockGoalsRepository goals;
  late MockGroupsRepository groups;
  late ProviderContainer container;

  setUp(() {
    goals = MockGoalsRepository();
    groups = MockGroupsRepository();
    when(
      goals.fetchGroupGoals(
        groupId: anyNamed('groupId'),
        period: anyNamed('period'),
      ),
    ).thenAnswer((_) async => []);
    when(groups.fetchMembers('group-1'))
        .thenAnswer((_) async => [_ada, _grace]);
    container = ProviderContainer(
      retry: (count, error) => null,
      overrides: [
        goalsRepositoryProvider.overrideWithValue(goals),
        groupsRepositoryProvider.overrideWithValue(groups),
        currentMemberProvider.overrideWith((ref) => _ada),
        isGroupAdminProvider.overrideWith((ref) async => true),
        clockProvider.overrideWithValue(() => _now),
      ],
    );
    addTearDown(container.dispose);
  });

  Future<void> pumpTab(WidgetTester tester, GoalType type) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(body: AdminTabView(type: type)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('heads each member with their name and their rate', (
    tester,
  ) async {
    when(goals.fetchGroupGoals(groupId: 'group-1', period: _today)).thenAnswer(
      (_) async => [
        goalCalled(
          'Run 5k',
          ownerId: _ada.id,
          status: GoalStatus.complete,
          verified: true,
        ),
        goalCalled('Stretch', ownerId: _ada.id),
        goalCalled('Read', ownerId: _grace.id),
      ],
    );

    await pumpTab(tester, GoalType.daily);

    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('1/2 verified · 50%'), findsOneWidget);
    expect(find.text('Grace'), findsOneWidget);
    expect(find.text('0/1 verified · 0%'), findsOneWidget);
    expect(find.byType(GoalTile), findsNWidgets(3));
  });

  testWidgets('says so under a member with nothing set', (tester) async {
    when(goals.fetchGroupGoals(groupId: 'group-1', period: _today))
        .thenAnswer((_) async => [goalCalled('Run 5k', ownerId: _ada.id)]);

    await pumpTab(tester, GoalType.daily);

    // Only Grace's section is empty, and an empty one has no rate.
    expect(find.text('No goals'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('the admin is in the list, first', (tester) async {
    await pumpTab(tester, GoalType.daily);

    final names = tester
        .widgetList<Text>(find.byType(Text))
        .map((text) => text.data)
        .where((label) => label == 'Ada' || label == 'Grace');
    expect(names, ['Ada', 'Grace']);
  });

  testWidgets('the Day tab moves a day and re-reads the group', (tester) async {
    await pumpTab(tester, GoalType.daily);

    await tester.tap(find.byTooltip('Previous day'));
    await tester.pumpAndSettle();

    expect(find.text('Yesterday'), findsOneWidget);
    expect(find.text('Tue, Oct 6'), findsOneWidget);
    verify(
      goals.fetchGroupGoals(
        groupId: 'group-1',
        period: Period.containing(DateTime(2026, 10, 6), GoalType.daily),
      ),
    ).called(1);
  });

  testWidgets('the calendar picks a day in the past', (tester) async {
    await pumpTab(tester, GoalType.daily);

    // On today the only "Today" on screen is the selector's label.
    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('3'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Sat, Oct 3'), findsNWidgets(2));
    verify(
      goals.fetchGroupGoals(
        groupId: 'group-1',
        period: Period.containing(DateTime(2026, 10, 3), GoalType.daily),
      ),
    ).called(1);
  });

  testWidgets('the other tabs have no day to move', (tester) async {
    for (final type in [GoalType.weekly, GoalType.monthly, GoalType.yearly]) {
      await pumpTab(tester, type);

      expect(find.byType(DaySelector), findsNothing);
      expect(find.text(Period.containing(_now, type).label), findsOneWidget);
    }
  });

  testWidgets('a day picked here does not follow the Day tab back', (
    tester,
  ) async {
    container
        .read(adminViewControllerProvider.notifier)
        .selectDay(DateTime(2026, 10, 2));

    await pumpTab(tester, GoalType.weekly);

    // The week is still the one containing now, not the one containing the
    // date the Day tab is on.
    expect(find.text('Week of Oct 5'), findsOneWidget);
  });

  testWidgets('shows a spinner while the group loads', (tester) async {
    final inFlight = Completer<List<Goal>>();
    when(goals.fetchGroupGoals(groupId: 'group-1', period: _today))
        .thenAnswer((_) => inFlight.future);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: AdminTabView(type: GoalType.daily)),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    inFlight.complete([]);
    await tester.pumpAndSettle();
  });

  testWidgets('pulling down re-reads the period', (tester) async {
    when(goals.fetchGroupGoals(groupId: 'group-1', period: _today))
        .thenAnswer((_) async => [goalCalled('Run 5k', ownerId: _ada.id)]);

    await pumpTab(tester, GoalType.daily);
    when(goals.fetchGroupGoals(groupId: 'group-1', period: _today)).thenAnswer(
      (_) async => [
        goalCalled('Run 5k', ownerId: _ada.id),
        goalCalled('Read', ownerId: _grace.id),
      ],
    );
    await tester.fling(find.byType(GoalTile).first, const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    expect(find.byType(GoalTile), findsNWidgets(2));
    verify(goals.fetchGroupGoals(groupId: 'group-1', period: _today)).called(2);
  });

  testWidgets('offers a retry when the group fails to load', (tester) async {
    when(goals.fetchGroupGoals(groupId: 'group-1', period: _today))
        .thenThrow(const NetworkException());

    await pumpTab(tester, GoalType.daily);

    expect(find.text('Try again'), findsOneWidget);

    when(goals.fetchGroupGoals(groupId: 'group-1', period: _today))
        .thenAnswer((_) async => [goalCalled('Run 5k', ownerId: _grace.id)]);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Run 5k'), findsOneWidget);
  });

  testWidgets("the admin can act on another member's goal from here", (
    tester,
  ) async {
    when(goals.fetchGroupGoals(groupId: 'group-1', period: _today)).thenAnswer(
      (_) async => [
        goalCalled('Read', ownerId: _grace.id, status: GoalStatus.complete),
      ],
    );

    await pumpTab(tester, GoalType.daily);

    // The same tile the goals tabs draw, so the admin's permissions are
    // already on it: Grace's complete goal is one Ada may verify.
    expect(find.text('Verify'), findsOneWidget);
  });
}
