import 'package:app/core/database/groups_table.dart';
import 'package:app/core/database/members_table.dart';
import 'package:app/core/database/rpc.dart';
import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/core/utils/providers.dart';
import 'package:app/core/utils/uuid.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/groups/domain/group.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'groups_repository.g.dart';

/// Reads `public.groups` and the members of one group, and owns the two
/// membership RPCs.
///
/// Creating and joining go through `create_group` and `join_group` because
/// clients have no `UPDATE` on `members.group_id`. Both functions set the
/// caller's membership, so neither takes a member id.
class GroupsRepository {
  GroupsRepository(this._supabase);

  final SupabaseClient _supabase;

  /// Creates a group and makes the caller its first member.
  Future<Group> createGroup(String name) {
    return _group(
      () => _supabase.rpc(Rpc.createGroup, params: {'p_name': name}),
    );
  }

  /// Joins the group whose invite code is [groupId].
  ///
  /// The shape check is here as well as in the form: an invite code arrives by
  /// paste, and a truncated one would otherwise come back from PostgREST as an
  /// unparseable-uuid error rather than as something to show the user.
  ///
  /// `async`, so a rejected code fails the future like every other failure
  /// here instead of being thrown at the call site.
  Future<Group> joinGroup(String groupId) async {
    if (!isUuid(groupId)) throw const ValidationException(_badCodeMessage);
    return _group(
      () => _supabase.rpc(Rpc.joinGroup, params: {'p_group_id': groupId}),
    );
  }

  Future<Group> fetchGroup(String id) async {
    try {
      final row = await _supabase
          .from(GroupsTable.name)
          .select()
          .eq(GroupsTable.id, id)
          .maybeSingle();
      if (row == null) throw const NotFoundException();
      return Group.fromJson(row);
    } on PostgrestException catch (error) {
      throw _mapped(error);
    }
  }

  /// Everyone in [groupId], by name, which is the order both the group page
  /// and the goals member picker show them in.
  Future<List<Member>> fetchMembers(String groupId) async {
    try {
      final rows = await _supabase
          .from(MembersTable.name)
          .select()
          .eq(MembersTable.groupId, groupId)
          .order(MembersTable.memberName, ascending: true);
      return rows.map(Member.fromJson).toList();
    } on PostgrestException catch (error) {
      throw _mapped(error);
    }
  }

  /// Both RPCs return one `public.groups` row.
  Future<Group> _group(Future<dynamic> Function() call) async {
    try {
      final row = await call();
      return Group.fromJson(row as Map<String, dynamic>);
    } on PostgrestException catch (error) {
      throw _mapped(error);
    }
  }
}

const _badCodeMessage =
    'That is not a valid invite code. Paste the whole '
    'code you were sent.';

/// Turns what Postgres raised into an exception a widget can render.
AppException _mapped(PostgrestException error) {
  switch (_tokenFor(error)) {
    case 'already_in_group':
      return const ValidationException(
        'You are already in a group, so you cannot create or join another.',
      );
    case 'group_not_found':
      return const ValidationException(
        'No group has that code. Check it with whoever invited you.',
      );
    // insufficient_privilege: the grant or an RLS policy said no.
    case '42501':
      return const PermissionException();
  }
  return DatabaseException(error.message);
}

/// What failure this is.
///
/// The RPCs raise application-defined SQLSTATEs (class M0, listed at the top
/// of the RLS migration) and repeat the token in the message, so the message
/// is a usable fallback when there is no code at all.
String _tokenFor(PostgrestException error) => switch (error.code) {
  null => error.message,
  'M0001' => 'already_in_group',
  'M0002' => 'group_not_found',
  final code => code,
};

@riverpod
GroupsRepository groupsRepository(Ref ref) =>
    GroupsRepository(ref.read(supabaseProvider));

/// The signed-in member's group.
///
/// The router keeps a member without a group on onboarding, so by the time
/// anything watches this there is a group id to read.
@riverpod
Future<Group> currentGroup(Ref ref) async {
  final member = await ref.watch(currentMemberProvider.future);
  final groupId = member?.groupId;
  if (groupId == null) throw const NotFoundException();
  return ref.watch(groupsRepositoryProvider).fetchGroup(groupId);
}

/// Everyone in [groupId]. A family, so the group page and the member picker
/// in the goals tabs share one cache.
@riverpod
Future<List<Member>> groupMembers(Ref ref, String groupId) =>
    ref.watch(groupsRepositoryProvider).fetchMembers(groupId);
