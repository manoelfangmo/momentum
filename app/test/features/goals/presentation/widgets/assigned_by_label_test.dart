import 'dart:async';

import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:app/features/goals/presentation/widgets/assigned_by_label.dart';
import 'package:app/features/groups/data/groups_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks.dart';

const _ada = Member(id: 'user-1', name: 'Ada', groupId: 'group-1');
const _sam = Member(id: 'user-2', name: 'Sam', groupId: 'group-1');

final _today = Period.containing(DateTime(2026, 10, 7, 8), GoalType.daily);

Goal goalWith({String? assignedBy}) => Goal(
  id: 'goal-1',
  ownerId: _ada.id,
  assignedBy: assignedBy,
  groupId: 'group-1',
  title: 'Run 5k',
  type: GoalType.daily,
  deadline: _today.deadline,
  status: GoalStatus.notStarted,
  verified: false,
  createdAt: _today.start,
);

void main() {
  late MockGroupsRepository groups;

  setUp(() {
    groups = MockGroupsRepository();
    when(groups.fetchMembers('group-1')).thenAnswer((_) async => [_ada, _sam]);
  });

  Future<void> pumpLabel(WidgetTester tester, Goal goal) async {
    await tester.pumpWidget(
      ProviderScope(
        retry: (count, error) => null,
        overrides: [groupsRepositoryProvider.overrideWithValue(groups)],
        child: MaterialApp(
          home: Scaffold(body: AssignedByLabel(goal: goal)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('names the admin who assigned the goal', (tester) async {
    await pumpLabel(tester, goalWith(assignedBy: _sam.id));

    expect(find.text('Assigned by Sam'), findsOneWidget);
  });

  testWidgets('says nothing on a goal its owner set themselves', (
    tester,
  ) async {
    await pumpLabel(tester, goalWith());

    expect(find.textContaining('Assigned by'), findsNothing);
  });

  testWidgets('says nothing while the group is still loading', (tester) async {
    final inFlight = Completer<List<Member>>();
    when(groups.fetchMembers('group-1')).thenAnswer((_) => inFlight.future);

    await pumpLabel(tester, goalWith(assignedBy: _sam.id));

    expect(find.textContaining('Assigned by'), findsNothing);

    inFlight.complete([_ada, _sam]);
    await tester.pumpAndSettle();
    expect(find.text('Assigned by Sam'), findsOneWidget);
  });

  testWidgets('says nothing when the group cannot be read', (tester) async {
    when(groups.fetchMembers('group-1')).thenThrow(const NetworkException());

    await pumpLabel(tester, goalWith(assignedBy: _sam.id));

    expect(find.textContaining('Assigned by'), findsNothing);
  });
}
