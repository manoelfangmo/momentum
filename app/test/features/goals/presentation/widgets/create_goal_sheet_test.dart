import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/core/utils/providers.dart';
import 'package:app/features/goals/application/goal_service.dart';
import 'package:app/features/goals/data/goals_repository.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:app/features/goals/presentation/validators/goal_validators.dart';
import 'package:app/features/goals/presentation/widgets/create_goal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks.dart';

/// A Wednesday. The week it lands in ends on Sunday the 11th, the month on
/// Saturday the 31st, and the year on Thursday the 31st.
final _now = DateTime(2026, 10, 7, 9);

final _saved = Goal(
  id: 'goal-1',
  ownerId: 'user-1',
  groupId: 'group-1',
  title: 'Run 5k',
  type: GoalType.daily,
  deadline: Period.containing(_now, GoalType.daily).deadline,
  status: GoalStatus.notStarted,
  verified: false,
  createdAt: _now,
);

void main() {
  late MockGoalService service;
  late MockGoalsRepository goals;

  setUp(() {
    service = MockGoalService();
    goals = MockGoalsRepository();
    when(
      service.createGoal(title: anyNamed('title'), type: anyNamed('type')),
    ).thenAnswer((_) async => _saved);
    when(
      goals.fetchGoals(
        ownerId: anyNamed('ownerId'),
        period: anyNamed('period'),
      ),
    ).thenAnswer((_) async => []);
  });

  /// Opened the way a tab opens it, through [showCreateGoalSheet], so the
  /// sheet is on a route it can pop itself off.
  Future<void> openSheet(WidgetTester tester, GoalType type) async {
    await tester.pumpWidget(
      ProviderScope(
        retry: (count, error) => null,
        overrides: [
          goalServiceProvider.overrideWithValue(service),
          goalsRepositoryProvider.overrideWithValue(goals),
          clockProvider.overrideWithValue(() => _now),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showCreateGoalSheet(context, type),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  Finder titleField() => find.widgetWithText(TextField, 'Goal');

  testWidgets('names the type of the tab it was opened from', (tester) async {
    await openSheet(tester, GoalType.monthly);

    expect(find.text('New Month goal'), findsOneWidget);
  });

  group('shows the end of the current period as the deadline', () {
    const expected = {
      GoalType.daily: 'Due: end of today (Wed, Oct 7)',
      GoalType.weekly: 'Due: end of this week (Sun, Oct 11)',
      GoalType.monthly: 'Due: end of this month (Sat, Oct 31)',
      GoalType.yearly: 'Due: end of this year (Thu, Dec 31)',
    };

    for (final MapEntry(key: type, value: label) in expected.entries) {
      testWidgets(type.name, (tester) async {
        await openSheet(tester, type);

        expect(find.text(label), findsOneWidget);
      });
    }
  });

  testWidgets('saves the trimmed title for the tab type, then closes', (
    tester,
  ) async {
    await openSheet(tester, GoalType.weekly);
    await tester.enterText(titleField(), '  Long run  ');

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    verify(
      service.createGoal(title: 'Long run', type: GoalType.weekly),
    ).called(1);
    expect(find.text('New Week goal'), findsNothing);
  });

  testWidgets('saves on enter in the title field', (tester) async {
    await openSheet(tester, GoalType.daily);
    await tester.enterText(titleField(), 'Run 5k');

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    verify(service.createGoal(title: 'Run 5k', type: GoalType.daily)).called(1);
  });

  testWidgets('an empty title never reaches the service', (tester) async {
    await openSheet(tester, GoalType.daily);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Say what you want to get done.'), findsOneWidget);
    expect(find.text('New Day goal'), findsOneWidget);
    verifyZeroInteractions(service);
  });

  testWidgets('a too-long title never reaches the service', (tester) async {
    await openSheet(tester, GoalType.daily);
    await tester.enterText(titleField(), 'a' * (maxGoalTitleLength + 1));

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(
      find.text('Use $maxGoalTitleLength characters or fewer.'),
      findsOneWidget,
    );
    verifyZeroInteractions(service);
  });

  testWidgets('a failed save toasts and keeps the sheet on the draft', (
    tester,
  ) async {
    when(
      service.createGoal(title: anyNamed('title'), type: anyNamed('type')),
    ).thenThrow(const PermissionException('That is not your group.'));
    await openSheet(tester, GoalType.daily);
    await tester.enterText(titleField(), 'Run 5k');

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('That is not your group.'), findsOneWidget);
    expect(find.text('New Day goal'), findsOneWidget);
    expect(find.text('Run 5k'), findsOneWidget);
  });

  testWidgets('one save cannot be sent twice', (tester) async {
    await openSheet(tester, GoalType.daily);
    await tester.enterText(titleField(), 'Run 5k');

    await tester.tap(find.text('Save'));
    await tester.pump();
    // Mid-save: the button is a spinner, so the label is gone and there is
    // nothing left to tap.
    expect(find.text('Save'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    verify(
      service.createGoal(title: anyNamed('title'), type: anyNamed('type')),
    ).called(1);
  });

  testWidgets('a closed sheet leaves nothing behind', (tester) async {
    await openSheet(tester, GoalType.daily);
    await tester.enterText(titleField(), 'Run 5k');

    await tester.tapAt(const Offset(400, 40));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Run 5k'), findsNothing);
    verifyZeroInteractions(service);
  });
}
