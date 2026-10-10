import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/providers.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/goals/data/goals_repository.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:app/features/goals/presentation/goals_page.dart';
import 'package:app/features/goals/presentation/widgets/create_goal_sheet.dart';
import 'package:app/features/goals/presentation/widgets/member_picker.dart';
import 'package:app/features/groups/data/groups_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../mocks.dart';

const _ada = Member(id: 'user-1', name: 'Ada', groupId: 'group-1');
const _grace = Member(id: 'user-2', name: 'Grace', groupId: 'group-1');

final _now = DateTime(2026, 10, 7, 9);

Goal goalCalled(String title, GoalType type) {
  final period = Period.containing(_now, type);
  return Goal(
    id: 'goal-$title',
    ownerId: 'user-1',
    groupId: 'group-1',
    title: title,
    type: type,
    deadline: period.deadline,
    status: GoalStatus.notStarted,
    verified: false,
    createdAt: period.start,
  );
}

void main() {
  late MockGoalsRepository goals;
  late MockGroupsRepository groups;

  setUp(() {
    goals = MockGoalsRepository();
    groups = MockGroupsRepository();
    when(
      groups.fetchMembers('group-1'),
    ).thenAnswer((_) async => [_ada, _grace]);
    when(
      goals.fetchGoals(
        ownerId: anyNamed('ownerId'),
        period: anyNamed('period'),
      ),
    ).thenAnswer((_) async => []);
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        retry: (count, error) => null,
        overrides: [
          goalsRepositoryProvider.overrideWithValue(goals),
          groupsRepositoryProvider.overrideWithValue(groups),
          currentMemberProvider.overrideWith((ref) => _ada),
          clockProvider.overrideWithValue(() => _now),
        ],
        child: const MaterialApp(home: GoalsPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('has a tab per goal type and the picker above them', (
    tester,
  ) async {
    await pumpPage(tester);

    for (final type in GoalType.values) {
      expect(find.text(type.label), findsOneWidget);
    }
    expect(find.byType(MemberPicker), findsOneWidget);
  });

  testWidgets('the new goal button names the tab in front', (tester) async {
    await pumpPage(tester);
    expect(find.text('New Day goal'), findsOneWidget);

    await tester.tap(find.text('Month'));
    await tester.pumpAndSettle();

    expect(find.text('New Month goal'), findsOneWidget);
  });

  testWidgets('the new goal button opens the sheet for that tab', (
    tester,
  ) async {
    await pumpPage(tester);
    await tester.tap(find.text('Year'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(CreateGoalSheet), findsOneWidget);
    // The deadline the sheet offers is the one the Year tab implies.
    expect(find.text('Due: end of this year (Thu, Dec 31)'), findsOneWidget);
  });

  testWidgets('a saved goal is in the list without a refresh', (tester) async {
    final today = Period.containing(_now, GoalType.daily);
    final run = goalCalled('Run 5k', GoalType.daily);
    var saved = false;
    when(
      goals.fetchGoals(ownerId: 'user-1', period: today),
    ).thenAnswer((_) async => saved ? [run] : []);
    when(goals.createGoal(any)).thenAnswer((_) async {
      saved = true;
      return run;
    });

    await pumpPage(tester);
    expect(find.text('Run 5k'), findsNothing);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Goal'), 'Run 5k');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Run 5k'), findsOneWidget);
  });

  testWidgets('there is no new goal button on another member', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.byType(MemberPicker));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Grace'));
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('each tab shows its own period', (tester) async {
    when(
      goals.fetchGoals(
        ownerId: 'user-1',
        period: Period.containing(_now, GoalType.weekly),
      ),
    ).thenAnswer((_) async => [goalCalled('Long run', GoalType.weekly)]);

    await pumpPage(tester);
    expect(find.text('Wed, Oct 7'), findsOneWidget);

    await tester.tap(find.text('Week'));
    await tester.pumpAndSettle();

    expect(find.text('Week of Oct 5'), findsOneWidget);
    expect(find.text('Long run'), findsOneWidget);
  });
}
