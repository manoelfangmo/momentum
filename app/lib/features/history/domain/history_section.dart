import 'package:app/core/domain/domain.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'history_section.freezed.dart';

/// One ended period and the viewer's goals that belonged to it.
@freezed
abstract class HistorySection with _$HistorySection {
  const factory HistorySection({
    required Period period,
    required List<Goal> goals,
  }) = _HistorySection;
}
