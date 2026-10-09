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
/// Changing status, verifying, renaming, and deleting all go through
/// functions because clients have no `UPDATE` or `DELETE` on `goals`. Each
/// acts as the caller, so none takes an actor id. The two status functions
/// also write a `goal_events` row in the same transaction; a rename and a
/// delete write no event.
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

  /// Renames the caller's own unverified goal. Nothing else about the goal
  /// can move: the RPC takes no type, deadline, status, or verified.
  Future<Goal> updateTitle(String goalId, String title) {
    return _goal(
      () => _supabase.rpc(
        Rpc.updateGoalTitle,
        params: {Rpc.pGoalId: goalId, Rpc.pTitle: title},
      ),
    );
  }

  /// Removes the caller's own unverified goal. Its `goal_events` go with it,
  /// through the cascade on the foreign key.
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
    case 'only_owner_can_change_status':
      return const PermissionException(
        'Only the member who set a goal can change its status.',
      );
    case 'only_owner_can_edit':
      return const PermissionException(
        'Only the member who set a goal can edit it.',
      );
    case 'only_owner_can_delete':
      return const PermissionException(
        'Only the member who set a goal can delete it.',
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
/// of the status-rework migration) and repeat the token in the message, so
/// the message is a usable fallback when there is no code at all.
String _tokenFor(PostgrestException error) => switch (error.code) {
  null => error.message,
  'M0003' => 'goal_not_found',
  'M0005' => 'cannot_verify_own_goal',
  'M0010' => 'only_owner_can_change_status',
  'M0011' => 'goal_verified_locked',
  'M0012' => 'goal_not_complete',
  'M0013' => 'goal_already_verified',
  'M0014' => 'only_owner_can_edit',
  'M0015' => 'only_owner_can_delete',
  'M0016' => 'invalid_title',
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
