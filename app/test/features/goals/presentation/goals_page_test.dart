import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/providers.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/goals/data/goals_repository.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:app/features/goals/presentation/goals_page.dart';
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
    status: GoalStatus.pending,
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
