import 'dart:async';

import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/core/utils/providers.dart';
import 'package:app/features/goals/data/goals_repository.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:app/features/goals/presentation/validators/goal_validators.dart';
import 'package:app/features/goals/presentation/widgets/edit_goal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks.dart';

/// A Wednesday. The daily goal below is due at the end of it.
final _now = DateTime(2026, 10, 7, 9);

Goal goalWith({GoalType type = GoalType.daily}) {
  final period = Period.containing(_now, type);
  return Goal(
    id: 'goal-1',
    ownerId: 'user-1',
    groupId: 'group-1',
    title: 'Run 5k',
    type: type,
    deadline: period.deadline,
    status: GoalStatus.notStarted,
    verified: false,
    createdAt: period.start,
  );
}

void main() {
  late MockGoalsRepository goals;

  setUp(() {
    goals = MockGoalsRepository();
    when(goals.updateTitle(any, any)).thenAnswer((_) async => goalWith());
    when(
      goals.fetchGoals(
        ownerId: anyNamed('ownerId'),
        period: anyNamed('period'),
      ),
    ).thenAnswer((_) async => []);
  });

  /// Opened the way the menu opens it, so the sheet is on a route it can pop
  /// itself off.
  Future<void> openSheet(WidgetTester tester, Goal goal) async {
    await tester.pumpWidget(
      ProviderScope(
        retry: (count, error) => null,
        overrides: [
          goalsRepositoryProvider.overrideWithValue(goals),
          clockProvider.overrideWithValue(() => _now),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showEditGoalSheet(context, goal),
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

  testWidgets('opens on the stored title, named for the goal type', (
    tester,
  ) async {
    await openSheet(tester, goalWith(type: GoalType.weekly));

    expect(find.text('Edit Week goal'), findsOneWidget);
    expect(find.text('Run 5k'), findsOneWidget);
  });

  testWidgets('shows the deadline the goal already has, read only', (
    tester,
  ) async {
    await openSheet(tester, goalWith());

    expect(find.text('Due: Oct 7, 2026, 11:59 PM'), findsOneWidget);
    expect(titleField(), findsOneWidget);
    // The title is the only field: nothing else can be typed into.
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('saves the trimmed title, then closes', (tester) async {
    await openSheet(tester, goalWith());
    await tester.enterText(titleField(), '  Long run  ');

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    verify(goals.updateTitle('goal-1', 'Long run')).called(1);
    expect(find.text('Edit Day goal'), findsNothing);
  });

  testWidgets('saves on enter in the title field', (tester) async {
    await openSheet(tester, goalWith());
    await tester.enterText(titleField(), 'Long run');

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    verify(goals.updateTitle('goal-1', 'Long run')).called(1);
  });

  testWidgets('an empty title never reaches the repository', (tester) async {
    await openSheet(tester, goalWith());
    await tester.enterText(titleField(), '   ');

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Say what you want to get done.'), findsOneWidget);
    expect(find.text('Edit Day goal'), findsOneWidget);
    verifyNever(goals.updateTitle(any, any));
  });

  testWidgets('a too-long title never reaches the repository', (tester) async {
    await openSheet(tester, goalWith());
    await tester.enterText(titleField(), 'a' * (maxGoalTitleLength + 1));

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(
      find.text('Use $maxGoalTitleLength characters or fewer.'),
      findsOneWidget,
    );
    verifyNever(goals.updateTitle(any, any));
  });

  testWidgets('a rejected save toasts and keeps the sheet on the draft', (
    tester,
  ) async {
    when(goals.updateTitle(any, any)).thenThrow(
      const ValidationException("This goal is verified and can't be changed."),
    );
    await openSheet(tester, goalWith());
    await tester.enterText(titleField(), 'Long run');

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(
        SnackBar,
        "This goal is verified and can't be changed.",
      ),
      findsOneWidget,
    );
    expect(find.text('Edit Day goal'), findsOneWidget);
    expect(find.text('Long run'), findsOneWidget);
  });

  testWidgets('one save cannot be sent twice', (tester) async {
    final inFlight = Completer<Goal>();
    when(goals.updateTitle(any, any)).thenAnswer((_) => inFlight.future);
    await openSheet(tester, goalWith());
    await tester.enterText(titleField(), 'Long run');

    await tester.tap(find.text('Save'));
    await tester.pump();
    // Mid-save: the button is a spinner, so the label is gone and there is
    // nothing left to tap.
    expect(find.text('Save'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    inFlight.complete(goalWith());
    await tester.pumpAndSettle();
    verify(goals.updateTitle(any, any)).called(1);
  });

  testWidgets('closing the sheet changes nothing', (tester) async {
    await openSheet(tester, goalWith());
    await tester.enterText(titleField(), 'Long run');

    await tester.tapAt(const Offset(400, 40));
    await tester.pumpAndSettle();

    verifyNever(goals.updateTitle(any, any));
  });
}
