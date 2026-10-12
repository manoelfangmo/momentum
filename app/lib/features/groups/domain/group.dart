import 'package:freezed_annotation/freezed_annotation.dart';

part 'group.freezed.dart';
part 'group.g.dart';

/// The one group a member belongs to.
///
/// [id] doubles as the invite code: it is what a member copies and sends to
/// someone they want in the group, and what `join_group` takes.
@freezed
abstract class Group with _$Group {
  const factory Group({
    required String id,
    required String name,
    required String createdBy,
  }) = _Group;

  factory Group.fromJson(Map<String, Object?> json) => _$GroupFromJson(json);
}
