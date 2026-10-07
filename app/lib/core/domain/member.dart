import 'package:freezed_annotation/freezed_annotation.dart';

part 'member.freezed.dart';
part 'member.g.dart';

/// A person in the app. Shared by auth, groups, and goals.
@freezed
abstract class Member with _$Member {
  const factory Member({
    required String id,
    required String name,
    String? groupId,
  }) = _Member;

  factory Member.fromJson(Map<String, Object?> json) => _$MemberFromJson(json);
}
