import 'package:app/core/database/members_table.dart';
import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/core/utils/providers.dart';
import 'package:app/features/auth/data/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'member_repository.g.dart';

/// Reads `public.members`. RLS narrows this to the caller and their group.
class MemberRepository {
  MemberRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<Member> fetchMember(String id) async {
    try {
      final row = await _supabase
          .from(MembersTable.name)
          .select()
          .eq(MembersTable.id, id)
          .maybeSingle();
      if (row == null) throw const NotFoundException();
      return Member.fromJson(row);
    } on PostgrestException catch (error) {
      // 42501 insufficient_privilege: the grant or an RLS policy said no.
      if (error.code == '42501') throw const PermissionException();
      throw DatabaseException(error.message);
    }
  }
}

@riverpod
MemberRepository memberRepository(Ref ref) =>
    MemberRepository(ref.read(supabaseProvider));

/// The signed-in member, or null when signed out.
///
/// Anything that changes the member row — creating or joining a group —
/// invalidates this so the next read picks up the new `groupId`.
@Riverpod(keepAlive: true)
Future<Member?> currentMember(Ref ref) async {
  final userId = await ref.watch(authUserIdProvider.future);
  if (userId == null) return null;
  return ref.watch(memberRepositoryProvider).fetchMember(userId);
}
