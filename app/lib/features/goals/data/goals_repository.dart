import 'package:app/core/database/goals_table.dart';
import 'package:app/core/database/rpc.dart';
import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/core/utils/providers.dart';
import 'package:app/features/goals/data/models.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'goals_repository.g.dart';

/// Reads `public.goals` and owns the two status RPCs.
///
/// Verifying and marking missed go through `verify_goal_complete` and
/// `mark_goal_missed` because clients have no `UPDATE` on `goals`. Both act as
/// the caller, so neither takes an actor id.
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
  /// `pending` status, and `created_at` the database filled in.
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

  /// Marks someone else's pending goal complete.
  Future<Goal> verifyComplete(String goalId) {
    return _goal(
      () =>
          _supabase.rpc(Rpc.verifyGoalComplete, params: {'p_goal_id': goalId}),
    );
  }

  /// Marks the caller's own pending goal missed.
  Future<Goal> markMissed(String goalId) {
    return _goal(
      () => _supabase.rpc(Rpc.markGoalMissed, params: {'p_goal_id': goalId}),
    );
  }

  /// Both RPCs return the updated `public.goals` row.
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
/// The two races a member can actually hit are a goal someone else already
/// closed and a goal that was deleted under them, so those get text that says
/// to refresh. The rest describe a rule and read as one.
AppException _mapped(PostgrestException error) {
  switch (_tokenFor(error)) {
    case 'goal_not_found':
      return const ValidationException(
        'That goal is no longer there. Refresh and try again.',
      );
    case 'goal_not_pending':
      return const ValidationException(
        'That goal was already settled. Refresh to see where it landed.',
      );
    case 'cannot_verify_own_goal':
      return const PermissionException(
        'Someone else in your group has to verify your goals.',
      );
    case 'only_owner_can_mark_missed':
      return const PermissionException(
        'Only the member who set a goal can mark it missed.',
      );
    case 'not_same_group':
      return const PermissionException('That goal belongs to another group.');
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
  'M0003' => 'goal_not_found',
  'M0004' => 'not_same_group',
  'M0005' => 'cannot_verify_own_goal',
  'M0006' => 'goal_not_pending',
  'M0007' => 'only_owner_can_mark_missed',
  final code => code,
};

@riverpod
GoalsRepository goalsRepository(Ref ref) =>
    GoalsRepository(ref.read(supabaseProvider));

/// One member's goals for one period.
///
/// A family keyed by both arguments: [Period] has `==`/`hashCode`, so a tab
/// and the history page asking for the same member and period share a cache.
@riverpod
Future<List<Goal>> goalsForPeriod(Ref ref, String memberId, Period period) =>
    ref
        .watch(goalsRepositoryProvider)
        .fetchGoals(ownerId: memberId, period: period);
