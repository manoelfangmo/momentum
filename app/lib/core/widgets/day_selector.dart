import 'package:app/core/domain/domain.dart';
import 'package:flutter/material.dart';

/// Which day a screen is on: one step at a time with the arrows, or any date
/// from the calendar.
///
/// It holds nothing. The caller passes the day it is showing and takes the
/// chosen one back, so the goals tabs and the admin tabs can each point it at
/// their own selection without sharing one.
class DaySelector extends StatelessWidget {
  const DaySelector({
    super.key,
    required this.selectedDay,
    required this.now,
    required this.onDaySelected,
  });

  /// Any instant inside the day on screen.
  final DateTime selectedDay;

  /// Any instant inside today, from the caller's clock.
  final DateTime now;

  /// Given the local midnight of the day the member moved to.
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final day = Period.containing(selectedDay, GoalType.daily);
    final today = Period.containing(now, GoalType.daily);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous day',
            onPressed: _stepTo(day.previous(), today),
          ),
          TextButton.icon(
            icon: const Icon(Icons.calendar_today_outlined, size: 16),
            label: Text(_label(day, today)),
            onPressed: () => _pickDay(context, day, today),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next day',
            onPressed: _stepTo(day.next(), today),
          ),
          const Spacer(),
          // The label already reads "Today" when the screen is on today, so
          // this is only ever a way back, never a repeat of where you are.
          if (day != today)
            TextButton(
              onPressed: () => onDaySelected(today.start),
              child: const Text('Today'),
            ),
        ],
      ),
    );
  }

  /// Moves to [target], or nothing when it is outside the range the calendar
  /// offers, which disables the arrow at either end.
  VoidCallback? _stepTo(Period target, Period today) {
    if (target.start.isBefore(_firstDay) ||
        target.start.isAfter(_lastDay(today))) {
      return null;
    }
    return () => onDaySelected(target.start);
  }

  Future<void> _pickDay(BuildContext context, Period day, Period today) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: day.start,
      firstDate: _firstDay,
      lastDate: _lastDay(today),
    );
    if (picked == null || !context.mounted) return;
    onDaySelected(picked);
  }
}

/// "Today" / "Yesterday" / "Tomorrow", else the day the header shows.
///
/// The three names cover the days a member moves between most, and reading
/// them beats working out whether "Tue, Oct 6" was yesterday.
String _label(Period day, Period today) {
  if (day == today) return 'Today';
  if (day == today.previous()) return 'Yesterday';
  if (day == today.next()) return 'Tomorrow';
  return day.label;
}

/// Goals cannot predate the app, and nobody is planning further out than this.
/// Both bounds are local midnights, like every [Period] edge.
final _firstDay = DateTime(2020, 1, 1);

DateTime _lastDay(Period today) =>
    DateTime(today.start.year + 5, today.start.month, today.start.day);
