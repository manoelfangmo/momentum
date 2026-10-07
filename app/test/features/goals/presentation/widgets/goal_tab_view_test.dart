import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/core/utils/providers.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/goals/data/goals_repository.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:app/features/goals/presentation/controllers/goals_view_controller.dart';
import 'package:app/features/goals/presentation/widgets/goal_tab_view.dart';
import 'package:app/features/goals/presentation/widgets/goal_tile.dart';
import 'package:app/features/groups/data/groups_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks.dart';

const _ada = Member(id: 'user-1', name: 'Ada', groupId: 'group-1');
const _grace = Member(id: 'user-2', name: 'Grace', groupId: 'group-1');

final _now = DateTime(2026, 10, 7, 9);
final _today = Period.containing(_now, GoalType.daily);

Goal goalCalled(String title) => Goal(
  id: 'goal-$title',
  ownerId: 'user-1',
  groupId: 'group-1',
  title: title,
  type: _today.type,
  deadline: _today.deadline,
  status: GoalStatus.pending,
  createdAt: _today.start,
);

void main() {
  late MockGoalsRepository goals;
  late MockGroupsRepository groups;
  late ProviderContainer container;

  setUp(() {
    goals = MockGoalsRepository();
    groups = MockGroupsRepository();
    when(
      groups.fetchMembers('group-1'),
    ).thenAnswer((_) async => [_ada, _grace]);
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

  Future<void> pumpTab(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: GoalTabView(type: GoalType.daily)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('heads the list with the period and whose goals', (tester) async {
    when(
      goals.fetchGoals(ownerId: 'user-1', period: _today),
    ).thenAnswer((_) async => [goalCalled('Run 5k'), goalCalled('Read')]);

    await pumpTab(tester);

    expect(find.text('Wed, Oct 7'), findsOneWidget);
    expect(find.text('Your goals'), findsOneWidget);
    expect(find.byType(GoalTile), findsNWidgets(2));
  });

  testWidgets('names the member when it is not you', (tester) async {
    when(
      goals.fetchGoals(ownerId: 'user-2', period: _today),
    ).thenAnswer((_) async => []);
    container.read(goalsViewControllerProvider.notifier).selectMember('user-2');

    await pumpTab(tester);

    expect(find.text("Grace's goals"), findsOneWidget);
  });

  testWidgets('says so when the period is empty', (tester) async {
    when(
      goals.fetchGoals(ownerId: 'user-1', period: _today),
    ).thenAnswer((_) async => []);

    await pumpTab(tester);

    expect(find.text('No goals for this period yet.'), findsOneWidget);
    expect(find.byType(GoalTile), findsNothing);
  });

  testWidgets('offers a retry when the goals fail to load', (tester) async {
    when(
      goals.fetchGoals(ownerId: 'user-1', period: _today),
    ).thenThrow(const NetworkException());

    await pumpTab(tester);

    expect(find.text('Try again'), findsOneWidget);

    when(
      goals.fetchGoals(ownerId: 'user-1', period: _today),
    ).thenAnswer((_) async => [goalCalled('Run 5k')]);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Run 5k'), findsOneWidget);
  });

  testWidgets('pulling down re-reads the period', (tester) async {
    when(
      goals.fetchGoals(ownerId: 'user-1', period: _today),
    ).thenAnswer((_) async => [goalCalled('Run 5k')]);

    await pumpTab(tester);
    when(
      goals.fetchGoals(ownerId: 'user-1', period: _today),
    ).thenAnswer((_) async => [goalCalled('Run 5k'), goalCalled('Read')]);
    await tester.fling(find.byType(GoalTile).first, const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    expect(find.byType(GoalTile), findsNWidgets(2));
    verify(goals.fetchGoals(ownerId: 'user-1', period: _today)).called(2);
  });
}
