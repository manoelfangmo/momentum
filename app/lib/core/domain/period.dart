import 'package:intl/intl.dart';

import 'goal_type.dart';

/// A local calendar span for one [GoalType].
///
/// [start] is inclusive and [end] is exclusive. Both are local midnights.
/// Weeks start on Monday. A goal's deadline is the last millisecond of the
/// period, so the goal belongs to the period that contains that deadline.
final class Period {
  Period({required this.type, required this.start, required this.end})
    : assert(!start.isUtc && !end.isUtc, 'Period bounds are local'),
      assert(end.isAfter(start));

  final GoalType type;

  /// Inclusive local midnight of the first moment in the period.
  final DateTime start;

  /// Exclusive local midnight of the next period.
  final DateTime end;

  /// The period of [type] that contains [instant], in local time.
  ///
  /// Built with [DateTime] calendar constructors so a DST shift does not
  /// move [end] off local midnight the way `Duration(days:)` would.
  factory Period.containing(DateTime instant, GoalType type) {
    final local = instant.toLocal();
    switch (type) {
      case GoalType.daily:
        final start = DateTime(local.year, local.month, local.day);
        return Period(
          type: type,
          start: start,
          end: DateTime(start.year, start.month, start.day + 1),
        );
      case GoalType.weekly:
        final start = DateTime(
          local.year,
          local.month,
          local.day - (local.weekday - DateTime.monday),
        );
        return Period(
          type: type,
          start: start,
          end: DateTime(start.year, start.month, start.day + 7),
        );
      case GoalType.monthly:
        final start = DateTime(local.year, local.month, 1);
        return Period(
          type: type,
          start: start,
          end: DateTime(start.year, start.month + 1, 1),
        );
      case GoalType.yearly:
        final start = DateTime(local.year, 1, 1);
        return Period(
          type: type,
          start: start,
          end: DateTime(start.year + 1, 1, 1),
        );
    }
  }

  /// Last instant of this period: [end] minus 1 millisecond.
  DateTime get deadline => end.subtract(const Duration(milliseconds: 1));

  Period previous() =>
      Period.containing(start.subtract(const Duration(milliseconds: 1)), type);

  Period next() => Period.containing(end, type);

  /// True when [instant] is in `[start, end)`.
  bool contains(DateTime instant) =>
      !instant.isBefore(start) && instant.isBefore(end);

  /// "Tue, Oct 6" / "Week of Oct 5" / "October 2026" / "2026".
  String get label => switch (type) {
    GoalType.daily => _dayLabel.format(start),
    GoalType.weekly => 'Week of ${_weekOfLabel.format(start)}',
    GoalType.monthly => _monthLabel.format(start),
    GoalType.yearly => _yearLabel.format(start),
  };

  @override
  bool operator ==(Object other) =>
      other is Period && other.type == type && other.start == start;

  @override
  int get hashCode => Object.hash(type, start);

  @override
  String toString() => 'Period(${type.name}, $start → $end)';
}

final _dayLabel = DateFormat('EEE, MMM d', 'en_US');
final _weekOfLabel = DateFormat('MMM d', 'en_US');
final _monthLabel = DateFormat('MMMM y', 'en_US');
final _yearLabel = DateFormat('y', 'en_US');
