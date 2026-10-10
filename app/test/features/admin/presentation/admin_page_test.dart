import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/providers.dart';
import 'package:app/features/admin/presentation/admin_page.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/goals/data/goals_repository.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_status.dart';
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
    ownerId: _grace.id,
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
      goals.fetchGroupGoals(
        groupId: anyNamed('groupId'),
        period: anyNamed('period'),
      ),
    ).thenAnswer((_) async => []);
    when(groups.fetchMembers('group-1'))
        .thenAnswer((_) async => [_ada, _grace]);
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        retry: (count, error) => null,
        overrides: [
          goalsRepositoryProvider.overrideWithValue(goals),
          groupsRepositoryProvider.overrideWithValue(groups),
          currentMemberProvider.overrideWith((ref) => _ada),
          isGroupAdminProvider.overrideWith((ref) async => true),
          clockProvider.overrideWithValue(() => _now),
        ],
        child: const MaterialApp(home: AdminPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('has a tab per goal type and nothing to pick', (tester) async {
    await pumpPage(tester);

    for (final type in GoalType.values) {
      expect(find.text(type.label), findsOneWidget);
    }
    // Every tab is the whole group, and assigning comes later.
    expect(find.byType(MemberPicker), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('each tab shows its own period, for everyone', (tester) async {
    when(
      goals.fetchGroupGoals(
        groupId: 'group-1',
        period: Period.containing(_now, GoalType.weekly),
      ),
    ).thenAnswer((_) async => [goalCalled('Long run', GoalType.weekly)]);

    await pumpPage(tester);
    expect(find.text('Wed, Oct 7'), findsOneWidget);

    await tester.tap(find.text('Week'));
    await tester.pumpAndSettle();

    expect(find.text('Week of Oct 5'), findsOneWidget);
    expect(find.text('Long run'), findsOneWidget);
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('Grace'), findsOneWidget);
  });
}
