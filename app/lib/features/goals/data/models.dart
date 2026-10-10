import 'package:app/core/database/rpc.dart';
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

/// The arguments for `assign_goal`, built by `GoalService`.
///
/// [toJson] is the `params` map, so the keys are the function's argument
/// names rather than column names. There is no group: the RPC takes the
/// admin's own group, and no `assignedBy`: it writes the caller.
///
/// The deadline travels as UTC like every other timestamp, and is the end of
/// the current period in the device's timezone — the server cannot work that
/// out for itself.
@Freezed(toJson: true)
abstract class AssignGoalCommand with _$AssignGoalCommand {
  const factory AssignGoalCommand({
    @JsonKey(name: Rpc.pOwnerId) required String ownerId,
    @JsonKey(name: Rpc.pTitle) required String title,
    @JsonKey(name: Rpc.pType) required GoalType type,
    @JsonKey(name: Rpc.pDeadline)
    @LocalDateTimeConverter()
    required DateTime deadline,
  }) = _AssignGoalCommand;
}
