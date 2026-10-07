import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/core/utils/providers.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/goals/data/goals_repository.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:app/features/goals/presentation/widgets/goal_tile.dart';
import 'package:app/features/history/presentation/widgets/history_period_header.dart';
import 'package:app/features/history/presentation/widgets/history_type_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks.dart';

const _ada = Member(id: 'user-1', name: 'Ada', groupId: 'group-1');

final _now = DateTime(2026, 10, 7, 9);
final _today = Period.containing(_now, GoalType.daily);
final _yesterday = _today.previous();
final _monday = Period.containing(DateTime(2026, 10, 5), GoalType.daily);

Goal goalCalled(
  String title,
  Period period, {
  GoalStatus status = GoalStatus.pending,
}) => Goal(
  id: 'goal-$title',
  ownerId: 'user-1',
  groupId: 'group-1',
  title: title,
  type: period.type,
  deadline: period.deadline,
  status: status,
  createdAt: period.start,
);

void main() {
  late MockGoalsRepository goals;

  setUp(() {
    goals = MockGoalsRepository();
    when(
      goals.fetchGoalsBefore(
        ownerId: anyNamed('ownerId'),
        type: anyNamed('type'),
        before: anyNamed('before'),
      ),
    ).thenAnswer((_) async => []);
  });

  Future<void> pumpList(WidgetTester tester, {GoalType type = GoalType.daily}) {
    return tester.pumpWidget(
      ProviderScope(
        retry: (count, error) => null,
        overrides: [
          goalsRepositoryProvider.overrideWithValue(goals),
          currentMemberProvider.overrideWith((ref) => _ada),
          clockProvider.overrideWithValue(() => _now),
        ],
        child: MaterialApp(
          home: Scaffold(body: HistoryTypeList(type: type)),
        ),
      ),
    );
  }

  testWidgets('groups past goals under period headers, newest first', (
    tester,
  ) async {
    when(
      goals.fetchGoalsBefore(
        ownerId: 'user-1',
        type: GoalType.daily,
        before: _today.start,
      ),
    ).thenAnswer(
      (_) async => [
        goalCalled('Read', _yesterday),
        goalCalled('Run 5k', _monday),
      ],
    );

    await pumpList(tester);
    await tester.pumpAndSettle();

    expect(find.byType(HistoryPeriodHeader), findsNWidgets(2));
    expect(find.text('Mon, Oct 5'), findsOneWidget);
    expect(find.text('Tue, Oct 6'), findsOneWidget);
    expect(find.byType(GoalTile), findsNWidgets(2));
    expect(find.text('Run 5k'), findsOneWidget);
    expect(find.text('Read'), findsOneWidget);

    final mondayTop = tester.getTopLeft(find.text('Mon, Oct 5')).dy;
    final tuesdayTop = tester.getTopLeft(find.text('Tue, Oct 6')).dy;
    expect(tuesdayTop, lessThan(mondayTop));
  });

  testWidgets('a pending past goal still offers Missed', (tester) async {
    when(
      goals.fetchGoalsBefore(
        ownerId: 'user-1',
        type: GoalType.daily,
        before: _today.start,
      ),
    ).thenAnswer((_) async => [goalCalled('Run 5k', _yesterday)]);

    await pumpList(tester);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextButton, 'Missed'), findsOneWidget);
    expect(find.text('Verify'), findsNothing);
  });

  testWidgets('complete and missed goals still show under their period', (
    tester,
  ) async {
    when(
      goals.fetchGoalsBefore(
        ownerId: 'user-1',
        type: GoalType.daily,
        before: _today.start,
      ),
    ).thenAnswer(
      (_) async => [
        goalCalled('Run 5k', _yesterday, status: GoalStatus.complete),
        goalCalled('Read', _monday, status: GoalStatus.missed),
      ],
    );

    await pumpList(tester);
    await tester.pumpAndSettle();

    expect(find.text('Complete'), findsOneWidget);
    expect(find.text('Missed'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Missed'), findsNothing);
  });

  testWidgets('says so when there are no past goals', (tester) async {
    await pumpList(tester, type: GoalType.weekly);
    await tester.pumpAndSettle();

    expect(find.text('No past Week goals yet.'), findsOneWidget);
    expect(find.byType(GoalTile), findsNothing);
  });

  testWidgets('offers a retry when the goals fail to load', (tester) async {
    when(
      goals.fetchGoalsBefore(
        ownerId: 'user-1',
        type: GoalType.daily,
        before: _today.start,
      ),
    ).thenThrow(const NetworkException());

    await pumpList(tester);
    await tester.pumpAndSettle();

    expect(find.text('Try again'), findsOneWidget);

    when(
      goals.fetchGoalsBefore(
        ownerId: 'user-1',
        type: GoalType.daily,
        before: _today.start,
      ),
    ).thenAnswer((_) async => [goalCalled('Run 5k', _yesterday)]);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Run 5k'), findsOneWidget);
  });
}
