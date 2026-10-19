import 'package:app/core/domain/domain.dart';
import 'package:flutter/material.dart';

/// Which period a screen is on: one step of [type] at a time with the
/// arrows, or any date from the calendar.
///
/// It holds nothing. The caller passes the day it is showing and takes the
/// chosen one back, so the goals tabs and the admin tabs can each point it
/// at their own selection without sharing one. Every tab on a screen writes
/// that same day: the arrows step by this tab's grain, and the other tabs
/// derive their period from whatever lands.
class PeriodNavigator extends StatelessWidget {
  const PeriodNavigator({
    super.key,
    required this.type,
    required this.selectedDay,
    required this.now,
    required this.onDaySelected,
  });

  /// The grain the arrows step by, and the period the label names.
  final GoalType type;

  /// Any instant inside the day on screen.
  final DateTime selectedDay;

  /// Any instant inside today, from the caller's clock.
  final DateTime now;

  /// Given the local midnight of the day the member moved to.
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final visible = Period.containing(selectedDay, type);
    final current = Period.containing(now, type);
    final today = Period.containing(now, GoalType.daily);
    final grain = type.label.toLowerCase();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous $grain',
            onPressed: _stepTo(
              Period.stepDay(selectedDay, type, steps: -1),
              today,
            ),
          ),
          TextButton.icon(
            icon: const Icon(Icons.calendar_today_outlined, size: 16),
            label: Text(_navigatorLabel(visible, current)),
            onPressed: () => _pickDay(context, today),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next $grain',
            onPressed: _stepTo(
              Period.stepDay(selectedDay, type, steps: 1),
              today,
            ),
          ),
          const Spacer(),
          // The label already names the current period when the screen is on
          // it, so this is only ever a way back, never a repeat of where
          // you are.
          if (visible != current)
            TextButton(
              onPressed: () => onDaySelected(today.start),
              child: Text(_currentName(type)),
            ),
        ],
      ),
    );
  }

  /// Moves to [target], or nothing when it is outside the range the calendar
  /// offers, which disables the arrow at either end.
  VoidCallback? _stepTo(DateTime target, Period today) {
    if (target.isBefore(_firstDay) || target.isAfter(_lastDay(today))) {
      return null;
    }
    return () => onDaySelected(target);
  }

  Future<void> _pickDay(BuildContext context, Period today) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: Period.containing(selectedDay, GoalType.daily).start,
      firstDate: _firstDay,
      lastDate: _lastDay(today),
    );
    if (picked == null || !context.mounted) return;
    onDaySelected(picked);
  }
}

/// A friendly name when [visible] is current or adjacent, else [Period.label].
String _navigatorLabel(Period visible, Period current) {
  if (visible == current) return _currentName(visible.type);
  if (visible == current.previous()) return _lastName(visible.type);
  if (visible == current.next()) return _nextName(visible.type);
  return visible.label;
}

String _currentName(GoalType type) => switch (type) {
  GoalType.daily => 'Today',
  GoalType.weekly => 'This week',
  GoalType.monthly => 'This month',
  GoalType.yearly => 'This year',
};

String _lastName(GoalType type) => switch (type) {
  GoalType.daily => 'Yesterday',
  GoalType.weekly => 'Last week',
  GoalType.monthly => 'Last month',
  GoalType.yearly => 'Last year',
};

String _nextName(GoalType type) => switch (type) {
  GoalType.daily => 'Tomorrow',
  GoalType.weekly => 'Next week',
  GoalType.monthly => 'Next month',
  GoalType.yearly => 'Next year',
};

/// Goals cannot predate the app, and nobody is planning further out than this.
/// Both bounds are local midnights, like every [Period] edge.
final _firstDay = DateTime(2020, 1, 1);

DateTime _lastDay(Period today) =>
    DateTime(today.start.year + 5, today.start.month, today.start.day);
