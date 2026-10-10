import 'package:freezed_annotation/freezed_annotation.dart';

part 'completion_stats.freezed.dart';

/// How many of a set of goals are complete, and what share that is.
///
/// Unverified and incomplete goals count against the rate: they sit in
/// [total] but not in [complete]. [percent] is null when there are no
/// goals, so a badge can show an em dash rather than 0% or NaN.
@freezed
abstract class CompletionStats with _$CompletionStats {
  const factory CompletionStats({required int complete, required int total}) =
      _CompletionStats;

  const CompletionStats._();

  double? get percent => total == 0 ? null : complete / total;
}
