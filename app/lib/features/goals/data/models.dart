import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/json_converters.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
part 'models.g.dart';

/// The insert payload for a new goal, built by `GoalService`.
///
/// `status`, `verified`, and `created_at` are left out: the column defaults
/// make the row `not_started` and unverified, and the insert policy only
/// accepts that. [deadline] is written as UTC by the converter.
///
/// Write-only, so [toJson] is asked for explicitly instead of coming along
/// with a `fromJson` nothing would call: goals are read back as `Goal`.
@Freezed(toJson: true)
abstract class CreateGoalCommand with _$CreateGoalCommand {
  const factory CreateGoalCommand({
    required String ownerId,
    required String groupId,
    required String title,
    required GoalType type,
    @LocalDateTimeConverter() required DateTime deadline,
  }) = _CreateGoalCommand;
}
