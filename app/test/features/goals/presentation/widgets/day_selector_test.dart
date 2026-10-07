import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/providers.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/goals/data/goals_repository.dart';
import 'package:app/features/goals/presentation/controllers/goals_view_controller.dart';
import 'package:app/features/goals/presentation/widgets/day_selector.dart';
import 'package:app/features/goals/presentation/widgets/goal_tab_view.dart';
import 'package:app/features/groups/data/groups_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks.dart';

const _ada = Member(id: 'user-1', name: 'Ada', groupId: 'group-1');

/// A Wednesday, so the days either side are in the same week and month.
final _now = DateTime(2026, 10, 7, 9);

void main() {
  late MockGoalsRepository goals;
  late MockGroupsRepository groups;
  late ProviderContainer container;

  setUp(() {
    goals = MockGoalsRepository();
    groups = MockGroupsRepository();
    // Every day is empty: this is about which day the tab is on, not about
    // what is in it.
    when(
      goals.fetchGoals(
        ownerId: anyNamed('ownerId'),
        period: anyNamed('period'),
      ),
    ).thenAnswer((_) async => []);
    when(groups.fetchMembers('group-1')).thenAnswer((_) async => [_ada]);
    container = ProviderContainer(
      retry: (count, error) => null,
      overrides: [
        goalsRepositoryProvider.overrideWithValue(goals),
        groupsRepositoryProvider.overrideWithValue(groups),
        currentMemberProvider.overrideWith((ref) => _ada),
        clockProvider.overrideWithValue(() => _now),
      ],
    );
    addTearDown(container.dispose);
  });

  Future<void> pumpTab(WidgetTester tester, GoalType type) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: Scaffold(body: GoalTabView(type: type))),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('starts on today, with nothing to come back from', (
    tester,
  ) async {
    await pumpTab(tester, GoalType.daily);

    // One "Today" is the label: a second one would be the shortcut back, and
    // there is nowhere to come back from.
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Wed, Oct 7'), findsOneWidget);
  });

  testWidgets('the next day arrow moves the tab on a day', (tester) async {
    await pumpTab(tester, GoalType.daily);

    await tester.tap(find.byTooltip('Next day'));
    await tester.pumpAndSettle();

    expect(find.text('Tomorrow'), findsOneWidget);
    expect(find.text('Thu, Oct 8'), findsOneWidget);
    verify(
      goals.fetchGoals(
        ownerId: 'user-1',
        period: Period.containing(DateTime(2026, 10, 8), GoalType.daily),
      ),
    ).called(1);
  });

  testWidgets('the previous day arrow moves it back', (tester) async {
    await pumpTab(tester, GoalType.daily);

    await tester.tap(find.byTooltip('Previous day'));
    await tester.pumpAndSettle();

    expect(find.text('Yesterday'), findsOneWidget);
    expect(find.text('Tue, Oct 6'), findsOneWidget);
  });

  testWidgets('names a day further out rather than calling it today', (
    tester,
  ) async {
    container
        .read(goalsViewControllerProvider.notifier)
        .selectDay(DateTime(2026, 10, 2));

    await pumpTab(tester, GoalType.daily);

    expect(find.text('Fri, Oct 2'), findsNWidgets(2));
  });

  testWidgets('the Today button comes back to the clock day', (tester) async {
    container
        .read(goalsViewControllerProvider.notifier)
        .selectDay(DateTime(2026, 10, 2));

    await pumpTab(tester, GoalType.daily);
    // Off today the only "Today" on screen is the shortcut.
    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();

    expect(find.text('Wed, Oct 7'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets('the calendar picks a day in the past', (tester) async {
    await pumpTab(tester, GoalType.daily);

    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('3'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Sat, Oct 3'), findsNWidgets(2));
  });

  testWidgets('keeps the chosen day when the member changes', (tester) async {
    await pumpTab(tester, GoalType.daily);
    await tester.tap(find.byTooltip('Previous day'));
    await tester.pumpAndSettle();

    container.read(goalsViewControllerProvider.notifier).selectMember('user-2');
    await tester.pumpAndSettle();

    expect(find.text('Yesterday'), findsOneWidget);
    expect(find.text('Tue, Oct 6'), findsOneWidget);
  });

  testWidgets('the other tabs have no day to move', (tester) async {
    for (final type in [GoalType.weekly, GoalType.monthly, GoalType.yearly]) {
      await pumpTab(tester, type);

      expect(find.byType(DaySelector), findsNothing);
    }
  });
}
