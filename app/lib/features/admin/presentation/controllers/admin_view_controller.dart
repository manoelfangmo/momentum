import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'admin_view_controller.g.dart';

/// Which day the admin tabs are on, as a local midnight.
///
/// Its own notifier rather than a field on `GoalsViewController`: the admin
/// moves between the two screens to compare one member's week with the
/// group's, and a date picked on one has no business moving the other.
///
/// Nothing else is selected here. Every admin tab shows the whole group, and
/// every tab derives its period from this day: Day is the date, Week the
/// week that contains it, and so on.
@riverpod
class AdminViewController extends _$AdminViewController {
  @override
  DateTime build() => _dayOf(ref.watch(clockProvider)());

  /// Points every admin tab at the day containing [date].
  void selectDay(DateTime date) => state = _dayOf(date);
}

/// Local midnight of the day containing [instant].
///
/// Through [Period] so the tab and the goals it reads agree on where a day
/// starts.
DateTime _dayOf(DateTime instant) =>
    Period.containing(instant, GoalType.daily).start;
