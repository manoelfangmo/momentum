import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/providers.dart';
import 'package:app/features/goals/presentation/controllers/goals_view_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which day the Day tab is on: one step at a time with the arrows, or any
/// date from the calendar.
///
/// It writes the day to the shared view controller, the same place the member
/// picker writes to, so the Day tab and the goals it reads never disagree
/// about which day is showing.
class DaySelector extends ConsumerWidget {
  const DaySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = Period.containing(
      ref.watch(goalsViewControllerProvider).selectedDay,
      GoalType.daily,
    );
    final today = Period.containing(ref.watch(clockProvider)(), GoalType.daily);
    final controller = ref.read(goalsViewControllerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous day',
            onPressed: _stepTo(controller, day.previous(), today),
          ),
          TextButton.icon(
            icon: const Icon(Icons.calendar_today_outlined, size: 16),
            label: Text(_label(day, today)),
            onPressed: () => _pickDay(context, ref, day, today),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next day',
            onPressed: _stepTo(controller, day.next(), today),
          ),
          const Spacer(),
          // The label already reads "Today" when the tab is on today, so this
          // is only ever a way back, never a repeat of where you are.
          if (day != today)
            TextButton(
              onPressed: controller.resetDayToToday,
              child: const Text('Today'),
            ),
        ],
      ),
    );
  }

  /// Moves to [target], or nothing when it is outside the range the calendar
  /// offers, which disables the arrow at either end.
  VoidCallback? _stepTo(
    GoalsViewController controller,
    Period target,
    Period today,
  ) {
    if (target.start.isBefore(_firstDay) ||
        target.start.isAfter(_lastDay(today))) {
      return null;
    }
    return () => controller.selectDay(target.start);
  }

  Future<void> _pickDay(
    BuildContext context,
    WidgetRef ref,
    Period day,
    Period today,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: day.start,
      firstDate: _firstDay,
      lastDate: _lastDay(today),
    );
    if (picked == null || !context.mounted) return;
    ref.read(goalsViewControllerProvider.notifier).selectDay(picked);
  }
}

/// "Today" / "Yesterday" / "Tomorrow", else the day the tab header shows.
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
