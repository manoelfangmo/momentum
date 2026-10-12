import 'package:app/core/database/goals_table.dart';
import 'package:app/core/database/rpc.dart';
import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/core/utils/providers.dart';
import 'package:app/features/goals/data/models.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'goals_repository.g.dart';

/// Reads `public.goals` and owns the RPCs that write it.
///
/// Changing status, verifying, un-verifying, renaming, and deleting all go
/// through functions because clients have no `UPDATE` or `DELETE` on
/// `goals`. Each acts as the caller, so none takes an actor id, and each
/// writes a `goal_events` row in the same transaction. Inserting is the
/// exception: a member writes their own goal directly, and only the admin's
/// `assign_goal` makes one for someone else.
class GoalsRepository {
  GoalsRepository(this._supabase);

  final SupabaseClient _supabase;

  /// One member's goals of one type, for one period.
  ///
  /// Range on the deadline, not on `created_at`: the deadline is what decides
  /// which period a goal belongs to. Bounds go out as UTC because the column
  /// is `timestamptz` while [Period] is local.
  Future<List<Goal>> fetchGoals({
    required String ownerId,
    required Period period,
  }) async {
    try {
      final rows = await _supabase
          .from(GoalsTable.name)
          .select()
          .eq(GoalsTable.ownerId, ownerId)
          .eq(GoalsTable.type, period.type.toDb())
          .gte(GoalsTable.deadline, period.start.toUtc().toIso8601String())
          .lt(GoalsTable.deadline, period.end.toUtc().toIso8601String())
          .order(GoalsTable.createdAt, ascending: true);
      return rows.map(Goal.fromJson).toList();
    } on PostgrestException catch (error) {
      throw _mapped(error);
    }
  }

  /// Every member's goals of one type, for one period.
  ///
  /// One query rather than one per member: the admin tab shows the whole
  /// group at once. Ordered by owner first so the caller can group the rows
  /// under a member without sorting them again, then by `created_at` so each
  /// member's goals read in the order they appeared.
  Future<List<Goal>> fetchGroupGoals({
    required String groupId,
    required Period period,
  }) async {
    try {
      final rows = await _supabase
          .from(GoalsTable.name)
          .select()
          .eq(GoalsTable.groupId, groupId)
          .eq(GoalsTable.type, period.type.toDb())
          .gte(GoalsTable.deadline, period.start.toUtc().toIso8601String())
          .lt(GoalsTable.deadline, period.end.toUtc().toIso8601String())
          .order(GoalsTable.ownerId, ascending: true)
          .order(GoalsTable.createdAt, ascending: true);
      return rows.map(Goal.fromJson).toList();
    } on PostgrestException catch (error) {
      throw _mapped(error);
    }
  }

  /// Goals of one type with a deadline before [before], newest first.
  ///
  /// History pages backwards through periods, so it asks for everything older
  /// than the period it is showing rather than for one period at a time.
  Future<List<Goal>> fetchGoalsBefore({
    required String ownerId,
    required GoalType type,
    required DateTime before,
  }) async {
    try {
      final rows = await _supabase
          .from(GoalsTable.name)
          .select()
          .eq(GoalsTable.ownerId, ownerId)
          .eq(GoalsTable.type, type.toDb())
          .lt(GoalsTable.deadline, before.toUtc().toIso8601String())
          .order(GoalsTable.deadline, ascending: false);
      return rows.map(Goal.fromJson).toList();
    } on PostgrestException catch (error) {
      throw _mapped(error);
    }
  }

  /// Inserts one goal and returns the stored row, which carries the id,
  /// `not_started` status, `verified = false`, and `created_at` the database
  /// filled in.
  Future<Goal> createGoal(CreateGoalCommand command) async {
    try {
      final row = await _supabase
          .from(GoalsTable.name)
          .insert(command.toJson())
          .select()
          .single();
      return Goal.fromJson(row);
    } on PostgrestException catch (error) {
      throw _mapped(error);
    }
  }

  /// Gives one member of the admin's group a goal of their own.
  ///
  /// Admin only, and one member per call. The command carries the arguments
  /// rather than a row: the function picks the group and writes itself into
  /// `assigned_by`, except when the admin is the owner — that is an ordinary
  /// goal they set for themselves.
  Future<Goal> assignGoal(AssignGoalCommand command) {
    return _goal(() => _supabase.rpc(Rpc.assignGoal, params: command.toJson()));
  }

  /// Sets the caller's own unverified goal to [status].
  Future<Goal> setStatus(String goalId, GoalStatus status) {
    return _goal(
      () => _supabase.rpc(
        Rpc.setGoalStatus,
        params: {Rpc.pGoalId: goalId, Rpc.pStatus: status.toDb()},
      ),
    );
  }

  /// Marks someone else's complete, unverified goal as verified.
  Future<Goal> verify(String goalId) {
    return _goal(
      () => _supabase.rpc(Rpc.verifyGoal, params: {Rpc.pGoalId: goalId}),
    );
  }

  /// Takes a verification back, on a goal the admin does not own.
  ///
  /// The goal stays complete and becomes unlocked: its status can move again
  /// and someone can verify it again.
  Future<Goal> unverify(String goalId) {
    return _goal(
      () => _supabase.rpc(Rpc.unverifyGoal, params: {Rpc.pGoalId: goalId}),
    );
  }

  /// Renames a goal. Nothing else about it can move: the RPC takes no type,
  /// deadline, status, or verified.
  Future<Goal> updateTitle(String goalId, String title) {
    return _goal(
      () => _supabase.rpc(
        Rpc.updateGoalTitle,
        params: {Rpc.pGoalId: goalId, Rpc.pTitle: title},
      ),
    );
  }

  /// Removes a goal. Its `goal_events` stay: each one carries a copy of the
  /// goal, so the log survives the delete.
  Future<void> deleteGoal(String goalId) async {
    try {
      await _supabase.rpc(Rpc.deleteGoal, params: {Rpc.pGoalId: goalId});
    } on PostgrestException catch (error) {
      throw _mapped(error);
    }
  }

  /// Every RPC here but `delete_goal` returns the updated `public.goals` row.
  Future<Goal> _goal(Future<dynamic> Function() call) async {
    try {
      final row = await call();
      return Goal.fromJson(row as Map<String, dynamic>);
    } on PostgrestException catch (error) {
      throw _mapped(error);
    }
  }
}

/// Turns what Postgres raised into an exception a widget can render.
///
/// The races a member can actually hit are a goal someone else already
/// verified and a goal that was deleted under them, so those get text that
/// says to refresh. The rest describe a rule and read as one.
AppException _mapped(PostgrestException error) {
  switch (_tokenFor(error)) {
    case 'goal_not_found':
      return const ValidationException(
        'That goal is no longer there. Refresh and try again.',
      );
    case 'not_allowed_to_change_status':
      return const PermissionException(
        'Only the member who set a goal, or the group admin, can change its '
        'status.',
      );
    case 'not_allowed_to_edit':
      return const PermissionException(
        'Only the member who set a goal, or the group admin, can edit it.',
      );
    case 'not_allowed_to_delete':
      return const PermissionException(
        'Only the member who set a goal, or the group admin, can delete it.',
      );
    case 'assigned_goal_admin_only':
      return const PermissionException(
        'The group admin set this goal for you, so only they can change or '
        'remove it.',
      );
    case 'admin_only':
      return const PermissionException('Only the group admin can do that.');
    case 'cannot_unverify_own_goal':
      return const PermissionException(
        'You cannot take back the verification of your own goal.',
      );
    case 'goal_not_verified':
      return const ValidationException(
        'That goal is not verified. Refresh to see it.',
      );
    case 'member_not_in_group':
      return const ValidationException(
        'That member is not in your group. Refresh and try again.',
      );
    case 'goal_verified_locked':
      return const ValidationException(
        "This goal is verified and can't be changed.",
      );
    case 'invalid_title':
      return const ValidationException(
        'Give the goal a title of 140 characters or fewer.',
      );
    case 'cannot_verify_own_goal':
      return const PermissionException(
        'Someone else in your group has to verify your goals.',
      );
    case 'goal_not_complete':
      return const ValidationException(
        'That goal has to be complete before it can be verified.',
      );
    case 'goal_already_verified':
      return const ValidationException(
        'That goal is already verified. Refresh to see it.',
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
/// of the migration that adds each one) and repeat the token in the message,
/// so the message is a usable fallback when there is no code at all.
///
/// M0010, M0014, and M0015 kept their SQLSTATE through the admin migration
/// under a wider name: the check is in the same place, but it now lets the
/// admin through as well as the owner.
String _tokenFor(PostgrestException error) => switch (error.code) {
  null => error.message,
  'M0003' => 'goal_not_found',
  'M0005' => 'cannot_verify_own_goal',
  'M0010' => 'not_allowed_to_change_status',
  'M0011' => 'goal_verified_locked',
  'M0012' => 'goal_not_complete',
  'M0013' => 'goal_already_verified',
  'M0014' => 'not_allowed_to_edit',
  'M0015' => 'not_allowed_to_delete',
  'M0016' => 'invalid_title',
  'M0017' => 'assigned_goal_admin_only',
  'M0018' => 'admin_only',
  'M0019' => 'cannot_unverify_own_goal',
  'M0020' => 'goal_not_verified',
  'M0021' => 'member_not_in_group',
  final code => code,
};

@riverpod
GoalsRepository goalsRepository(Ref ref) =>
    GoalsRepository(ref.read(supabaseProvider));

/// One member's goals for one period.
///
/// A family keyed by both arguments: [Period] has `==`/`hashCode`, so two
/// widgets asking for the same member and period share a cache.
@riverpod
Future<List<Goal>> goalsForPeriod(Ref ref, String memberId, Period period) =>
    ref
        .watch(goalsRepositoryProvider)
        .fetchGoals(ownerId: memberId, period: period);

/// Every member's goals in [groupId] for one period.
///
/// What the admin tab watches: one cache for the whole group rather than one
/// per member, because it shows all of them together.
@riverpod
Future<List<Goal>> groupGoalsForPeriod(
  Ref ref,
  String groupId,
  Period period,
) => ref
    .watch(goalsRepositoryProvider)
    .fetchGroupGoals(groupId: groupId, period: period);

/// One member's goals of [type] whose deadline is before [before].
///
/// History uses this for every period that has already ended: [before] is the
/// start of the current period, so the current one stays on Goals. Load all
/// for MVP.
///
/// TODO: paginate past periods instead of loading all of them.
@riverpod
Future<List<Goal>> historyGoals(
  Ref ref,
  String ownerId,
  GoalType type,
  DateTime before,
) => ref
    .watch(goalsRepositoryProvider)
    .fetchGoalsBefore(ownerId: ownerId, type: type, before: before);
