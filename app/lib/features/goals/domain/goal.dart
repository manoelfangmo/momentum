import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/json_converters.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'goal_status.dart';

part 'goal.freezed.dart';
part 'goal.g.dart';

/// One thing a member said they would do inside one period.
///
/// [deadline] is the last instant of that period, so the goal belongs to the
/// period that contains it; [period] recovers it. Both timestamps are local:
/// the converter turns the UTC column into local time on read.
@freezed
abstract class Goal with _$Goal {
  const factory Goal({
    required String id,
    required String ownerId,
    required String groupId,
    required String title,
    required GoalType type,
    @LocalDateTimeConverter() required DateTime deadline,
    required GoalStatus status,
    @LocalDateTimeConverter() required DateTime createdAt,
  }) = _Goal;

  const Goal._();

  factory Goal.fromJson(Map<String, Object?> json) => _$GoalFromJson(json);

  /// The period this goal was set for.
  Period get period => Period.containing(deadline, type);

  /// Past its deadline and still pending.
  ///
  /// Nothing expires: an overdue goal can still be verified or marked missed.
  /// This only changes how it reads in a list.
  bool isOverdue(DateTime now) =>
      status == GoalStatus.pending && now.isAfter(deadline);
}
