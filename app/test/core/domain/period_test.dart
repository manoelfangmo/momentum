import 'package:app/core/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tuesday = DateTime(2026, 10, 6, 15, 30);

  group('daily boundaries', () {
    test('23:59:59.999 stays on that day and midnight starts the next', () {
      final lastInstant = DateTime(2026, 10, 6, 23, 59, 59, 999);
      final nextMidnight = DateTime(2026, 10, 7);

      final period = Period.containing(lastInstant, GoalType.daily);

      expect(period.start, DateTime(2026, 10, 6));
      expect(period.end, nextMidnight);
      expect(period.contains(lastInstant), isTrue);
      expect(period.deadline, lastInstant);
      expect(period.contains(period.deadline), isTrue);
      expect(period.contains(nextMidnight), isFalse);
      expect(
        Period.containing(nextMidnight, GoalType.daily).start,
        nextMidnight,
      );
    });

    test('a UTC instant uses the local calendar day', () {
      final localEvening = DateTime(2026, 10, 6, 23, 30);
      final period = Period.containing(localEvening.toUtc(), GoalType.daily);

      expect(period, Period.containing(localEvening, GoalType.daily));
      expect(period.start.isUtc, isFalse);
      expect(period.end.isUtc, isFalse);
    });
  });

  group('weeks start Monday', () {
    test('Sunday maps to the previous Monday', () {
      final sunday = DateTime(2026, 10, 11, 23, 59, 59, 999);
      final period = Period.containing(sunday, GoalType.weekly);

      expect(period.start, DateTime(2026, 10, 5));
      expect(period.end, DateTime(2026, 10, 12));
      expect(period.contains(sunday), isTrue);
      expect(period.contains(DateTime(2026, 10, 12)), isFalse);
      expect(period.contains(period.deadline), isTrue);
    });

    test('Tuesday belongs to the week of the preceding Monday', () {
      final period = Period.containing(tuesday, GoalType.weekly);

      expect(period.start, DateTime(2026, 10, 5));
      expect(period.end, DateTime(2026, 10, 12));
    });
  });

  group('month and year rollover', () {
    test('December rolls into January', () {
      final newYearsEve = DateTime(2026, 12, 31, 23, 59, 59, 999);

      final day = Period.containing(newYearsEve, GoalType.daily);
      expect(day.start, DateTime(2026, 12, 31));
      expect(day.end, DateTime(2027, 1, 1));
      expect(day.next().start, DateTime(2027, 1, 1));
      expect(day.contains(newYearsEve), isTrue);
      expect(day.contains(DateTime(2027, 1, 1)), isFalse);

      final month = Period.containing(newYearsEve, GoalType.monthly);
      expect(month.start, DateTime(2026, 12, 1));
      expect(month.end, DateTime(2027, 1, 1));
      expect(month.next().start, DateTime(2027, 1, 1));
      expect(month.next().end, DateTime(2027, 2, 1));

      final year = Period.containing(newYearsEve, GoalType.yearly);
      expect(year.start, DateTime(2026, 1, 1));
      expect(year.end, DateTime(2027, 1, 1));
      expect(
        year.next(),
        Period.containing(DateTime(2027, 6, 1), GoalType.yearly),
      );

      final week = Period.containing(newYearsEve, GoalType.weekly);
      expect(week.start, DateTime(2026, 12, 28));
      expect(week.end, DateTime(2027, 1, 4));
      expect(week.contains(DateTime(2027, 1, 3, 23, 59, 59, 999)), isTrue);
      expect(week.contains(DateTime(2027, 1, 4)), isFalse);
    });
  });

  group('leap year', () {
    test('February 2028 includes the 29th and ends on March 1', () {
      final leapDay = DateTime(2028, 2, 29, 23, 59, 59, 999);

      final day = Period.containing(leapDay, GoalType.daily);
      expect(day.start, DateTime(2028, 2, 29));
      expect(day.end, DateTime(2028, 3, 1));
      expect(day.contains(leapDay), isTrue);
      expect(day.next().start, DateTime(2028, 3, 1));
      expect(day.previous().start, DateTime(2028, 2, 28));

      final month = Period.containing(leapDay, GoalType.monthly);
      expect(month.start, DateTime(2028, 2, 1));
      expect(month.end, DateTime(2028, 3, 1));
      expect(month.contains(leapDay), isTrue);
      expect(month.previous().start, DateTime(2028, 1, 1));
      expect(month.next().start, DateTime(2028, 3, 1));

      final year = Period.containing(leapDay, GoalType.yearly);
      expect(year.start, DateTime(2028, 1, 1));
      expect(year.end, DateTime(2029, 1, 1));
      expect(year.contains(leapDay), isTrue);

      final week = Period.containing(leapDay, GoalType.weekly);
      expect(week.start, DateTime(2028, 2, 28));
      expect(week.end, DateTime(2028, 3, 6));
      expect(week.contains(DateTime(2028, 2, 29)), isTrue);
    });

    test('February 2027 ends on the 28th', () {
      final month = Period.containing(DateTime(2027, 2, 10), GoalType.monthly);
      expect(month.start, DateTime(2027, 2, 1));
      expect(month.end, DateTime(2027, 3, 1));
      expect(
        Period.containing(
          DateTime(2027, 2, 28, 23, 59, 59, 999),
          GoalType.daily,
        ).end,
        DateTime(2027, 3, 1),
      );
    });
  });

  group('DST', () {
    test('spring-forward week ends at the next Monday midnight', () {
      // 2026-03-08 is the US spring-forward Sunday. The ISO week is Mon 3/2.
      final period = Period.containing(
        DateTime(2026, 3, 8, 12),
        GoalType.weekly,
      );

      expect(period.start, DateTime(2026, 3, 2));
      expect(period.end, DateTime(2026, 3, 9));
      expect(period.end.hour, 0);
      expect(period.contains(DateTime(2026, 3, 8, 3)), isTrue);
      expect(period.contains(DateTime(2026, 3, 9)), isFalse);
      expect(period.contains(period.deadline), isTrue);
      expect(period.deadline.isBefore(period.end), isTrue);
    });

    test('fall-back week ends at the next Monday midnight', () {
      // 2026-11-01 is the US fall-back Sunday. The ISO week is Mon 10/26.
      final period = Period.containing(
        DateTime(2026, 11, 1, 1, 30),
        GoalType.weekly,
      );

      expect(period.start, DateTime(2026, 10, 26));
      expect(period.end, DateTime(2026, 11, 2));
      expect(period.contains(DateTime(2026, 11, 1, 1, 30)), isTrue);
      expect(period.contains(DateTime(2026, 11, 1, 23, 30)), isTrue);
      expect(period.contains(DateTime(2026, 11, 2)), isFalse);
    });
  });

  group('deadline, navigation, equality, labels', () {
    test('deadline is inside its period and end is not', () {
      for (final type in GoalType.values) {
        final period = Period.containing(tuesday, type);
        expect(period.contains(period.deadline), isTrue, reason: type.name);
        expect(period.contains(period.end), isFalse, reason: type.name);
        expect(
          Period.containing(period.deadline, type),
          period,
          reason: type.name,
        );
      }
    });

    test('previous and next round-trip across each boundary', () {
      final anchors = [
        tuesday,
        DateTime(2026, 12, 31, 23, 59, 59, 999),
        DateTime(2028, 2, 29, 12),
        DateTime(2026, 3, 8, 12),
        DateTime(2026, 11, 1, 1, 30),
        DateTime(2026, 10, 11),
      ];

      for (final type in GoalType.values) {
        for (final anchor in anchors) {
          final period = Period.containing(anchor, type);
          expect(period.next().previous(), period, reason: '$type $anchor');
          expect(period.previous().next(), period, reason: '$type $anchor');
        }
      }
    });

    test('equality and hashCode use type and start', () {
      final morning = Period.containing(
        DateTime(2026, 10, 6, 1),
        GoalType.daily,
      );
      final evening = Period.containing(
        DateTime(2026, 10, 6, 22),
        GoalType.daily,
      );
      final sameStartDifferentEnd = Period(
        type: GoalType.daily,
        start: morning.start,
        end: DateTime(2026, 10, 8),
      );

      expect(evening, morning);
      expect(evening.hashCode, morning.hashCode);
      expect({morning, evening, sameStartDifferentEnd}, hasLength(1));
      expect(
        morning,
        isNot(Period.containing(DateTime(2026, 10, 6), GoalType.weekly)),
      );
      expect(
        morning,
        isNot(Period.containing(DateTime(2026, 10, 7), GoalType.daily)),
      );
    });

    test('labels', () {
      expect(
        Period.containing(DateTime(2026, 10, 6), GoalType.daily).label,
        'Tue, Oct 6',
      );
      expect(
        Period.containing(DateTime(2026, 10, 6), GoalType.weekly).label,
        'Week of Oct 5',
      );
      expect(
        Period.containing(DateTime(2026, 10, 6), GoalType.monthly).label,
        'October 2026',
      );
      expect(
        Period.containing(DateTime(2026, 10, 6), GoalType.yearly).label,
        '2026',
      );
      expect(
        Period.containing(DateTime(2026, 12, 31), GoalType.weekly).label,
        'Week of Dec 28',
      );
    });
  });
}
