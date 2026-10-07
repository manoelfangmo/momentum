import 'package:app/core/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('toDb and fromDb round-trip the Postgres values', () {
    expect(GoalType.daily.toDb(), 'daily');
    expect(GoalType.weekly.toDb(), 'weekly');
    expect(GoalType.monthly.toDb(), 'monthly');
    expect(GoalType.yearly.toDb(), 'yearly');

    for (final type in GoalType.values) {
      expect(GoalType.fromDb(type.toDb()), type);
    }
  });

  test('fromDb rejects an unknown value', () {
    expect(() => GoalType.fromDb('hourly'), throwsArgumentError);
  });

  test('labels are the tab names', () {
    expect(GoalType.daily.label, 'Day');
    expect(GoalType.weekly.label, 'Week');
    expect(GoalType.monthly.label, 'Month');
    expect(GoalType.yearly.label, 'Year');
  });
}
