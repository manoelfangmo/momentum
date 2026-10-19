import 'package:app/core/domain/domain.dart';
import 'package:app/core/widgets/period_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A Wednesday, so the days either side are in the same week and month.
final _now = DateTime(2026, 10, 7, 9);
final _today = DateTime(2026, 10, 7);

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required GoalType type,
    required DateTime selectedDay,
    required List<DateTime> selected,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PeriodNavigator(
            type: type,
            selectedDay: selectedDay,
            now: _now,
            onDaySelected: selected.add,
          ),
        ),
      ),
    );
  }

  testWidgets('starts on the current period, with nothing to come back from', (
    tester,
  ) async {
    await pump(tester, type: GoalType.daily, selectedDay: _today, selected: []);

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('This week'), findsNothing);
  });

  testWidgets('names current and adjacent periods, else Period.label', (
    tester,
  ) async {
    final cases = <(GoalType, DateTime, String)>[
      (GoalType.daily, DateTime(2026, 10, 7), 'Today'),
      (GoalType.daily, DateTime(2026, 10, 6), 'Yesterday'),
      (GoalType.daily, DateTime(2026, 10, 8), 'Tomorrow'),
      (GoalType.daily, DateTime(2026, 10, 2), 'Fri, Oct 2'),
      (GoalType.weekly, DateTime(2026, 10, 7), 'This week'),
      (GoalType.weekly, DateTime(2026, 9, 30), 'Last week'),
      (GoalType.weekly, DateTime(2026, 10, 14), 'Next week'),
      (GoalType.weekly, DateTime(2026, 9, 16), 'Week of Sep 14'),
      (GoalType.monthly, DateTime(2026, 10, 7), 'This month'),
      (GoalType.monthly, DateTime(2026, 9, 7), 'Last month'),
      (GoalType.monthly, DateTime(2026, 11, 7), 'Next month'),
      (GoalType.monthly, DateTime(2026, 8, 7), 'August 2026'),
      (GoalType.yearly, DateTime(2026, 10, 7), 'This year'),
      (GoalType.yearly, DateTime(2025, 10, 7), 'Last year'),
      (GoalType.yearly, DateTime(2027, 10, 7), 'Next year'),
      (GoalType.yearly, DateTime(2024, 10, 7), '2024'),
    ];

    for (final (type, day, label) in cases) {
      await pump(tester, type: type, selectedDay: day, selected: []);
      expect(find.text(label), findsOneWidget, reason: '$type $day');
    }
  });

  testWidgets('reset is hidden on the current period of that tab', (
    tester,
  ) async {
    // Yesterday is still this week / this month / this year.
    await pump(
      tester,
      type: GoalType.weekly,
      selectedDay: DateTime(2026, 10, 6),
      selected: [],
    );

    expect(find.text('This week'), findsOneWidget);
    // The label is the only text button; the reset would be a second.
    expect(find.byType(TextButton), findsOneWidget);
  });

  testWidgets('reset names the current period and returns today', (
    tester,
  ) async {
    final selected = <DateTime>[];
    await pump(
      tester,
      type: GoalType.weekly,
      selectedDay: DateTime(2026, 9, 30),
      selected: selected,
    );

    expect(find.text('Last week'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'This week'));
    expect(selected, [_today]);
  });

  testWidgets('a week step keeps the weekday', (tester) async {
    final selected = <DateTime>[];
    await pump(
      tester,
      type: GoalType.weekly,
      selectedDay: _today,
      selected: selected,
    );

    await tester.tap(find.byTooltip('Previous week'));

    expect(selected, [DateTime(2026, 9, 30)]);
  });

  testWidgets('a month step from the 31st clamps to the last day', (
    tester,
  ) async {
    final selected = <DateTime>[];
    await pump(
      tester,
      type: GoalType.monthly,
      selectedDay: DateTime(2026, 10, 31),
      selected: selected,
    );

    await tester.tap(find.byTooltip('Previous month'));

    expect(selected, [DateTime(2026, 9, 30)]);
  });

  testWidgets('a year step from 29 Feb lands on 28 Feb', (tester) async {
    final selected = <DateTime>[];
    await pump(
      tester,
      type: GoalType.yearly,
      selectedDay: DateTime(2028, 2, 29),
      selected: selected,
    );

    await tester.tap(find.byTooltip('Previous year'));

    expect(selected, [DateTime(2027, 2, 28)]);
  });

  testWidgets('previous disables at 1 Jan 2020 for every type', (tester) async {
    final first = DateTime(2020, 1, 1);
    for (final type in GoalType.values) {
      final selected = <DateTime>[];
      await pump(tester, type: type, selectedDay: first, selected: selected);
      await tester.tap(find.byIcon(Icons.chevron_left));
      expect(selected, isEmpty, reason: type.name);
    }
  });

  testWidgets('next disables at today plus five years for every type', (
    tester,
  ) async {
    final last = DateTime(2031, 10, 7);
    for (final type in GoalType.values) {
      final selected = <DateTime>[];
      await pump(tester, type: type, selectedDay: last, selected: selected);
      await tester.tap(find.byIcon(Icons.chevron_right));
      expect(selected, isEmpty, reason: type.name);
    }
  });

  testWidgets('the date picker uses the selected day and the same bounds', (
    tester,
  ) async {
    await pump(
      tester,
      type: GoalType.weekly,
      selectedDay: DateTime(2026, 10, 2),
      selected: [],
    );

    await tester.tap(find.text('Last week'));
    await tester.pumpAndSettle();

    final picker = tester.widget<CalendarDatePicker>(
      find.byType(CalendarDatePicker),
    );
    expect(picker.initialDate, DateTime(2026, 10, 2));
    expect(picker.firstDate, DateTime(2020, 1, 1));
    expect(picker.lastDate, DateTime(2031, 10, 7));
  });
}
