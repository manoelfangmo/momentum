import 'package:app/core/database/rpc.dart';
import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/features/goals/data/goals_repository.dart';
import 'package:app/features/goals/data/models.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../mocks.dart';

void main() {
  late MockSupabaseClient supabase;
  late GoalsRepository repository;

  setUp(() {
    supabase = MockSupabaseClient();
    repository = GoalsRepository(supabase);
  });

  /// Makes the next call to [function] fail the way Postgres would.
  void raise(String function, {String? code, required String message}) {
    when(supabase.rpc(function, params: anyNamed('params')))
        .thenThrow(PostgrestException(message: message, code: code));
  }

  /// What the call that just failed was asked to do.
  ///
  /// `rpc` hands back a builder rather than a future, so a mock client cannot
  /// stand in for a successful call. Making it fail is what leaves a call to
  /// read the arguments off.
  void verifyCalled(String function, Map<String, dynamic> params) {
    verify(supabase.rpc(function, params: params)).called(1);
  }

  group('setStatus', () {
    test('neither the owner nor the admin is a permission failure', () async {
      raise(
        Rpc.setGoalStatus,
        code: 'M0010',
        message: 'not_allowed_to_change_status',
      );

      await expectLater(
        repository.setStatus('goal-1', GoalStatus.inProgress),
        throwsA(
          isA<PermissionException>().having(
            (e) => e.message,
            'message',
            startsWith('Only the member who set a goal, or the group admin,'),
          ),
        ),
      );
    });

    test('a verified goal is locked', () async {
      raise(Rpc.setGoalStatus, code: 'M0011', message: 'goal_verified_locked');

      await expectLater(
        repository.setStatus('goal-1', GoalStatus.complete),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            "This goal is verified and can't be changed.",
          ),
        ),
      );
    });

    test('a goal that is gone says to refresh', () async {
      raise(Rpc.setGoalStatus, code: 'M0003', message: 'goal_not_found');

      await expectLater(
        repository.setStatus('goal-1', GoalStatus.complete),
        throwsA(isA<ValidationException>()),
      );
    });

    test('an RLS or grant refusal is a permission failure', () async {
      raise(
        Rpc.setGoalStatus,
        code: '42501',
        message: 'permission denied for function set_goal_status',
      );

      await expectLater(
        repository.setStatus('goal-1', GoalStatus.complete),
        throwsA(isA<PermissionException>()),
      );
    });
  });

  group('verify', () {
    test(
      'the owner trying to verify their own goal is a permission failure',
      () async {
        raise(Rpc.verifyGoal, code: 'M0005', message: 'cannot_verify_own_goal');

        await expectLater(
          repository.verify('goal-1'),
          throwsA(
            isA<PermissionException>().having(
              (e) => e.message,
              'message',
              'Someone else in your group has to verify your goals.',
            ),
          ),
        );
      },
    );

    test('an incomplete goal cannot be verified', () async {
      raise(Rpc.verifyGoal, code: 'M0012', message: 'goal_not_complete');

      await expectLater(
        repository.verify('goal-1'),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            startsWith('That goal has to be complete'),
          ),
        ),
      );
    });

    test('an already verified goal says to refresh', () async {
      raise(Rpc.verifyGoal, code: 'M0013', message: 'goal_already_verified');

      await expectLater(
        repository.verify('goal-1'),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            startsWith('That goal is already verified.'),
          ),
        ),
      );
    });

    test('a goal that is gone says to refresh', () async {
      raise(Rpc.verifyGoal, code: 'M0003', message: 'goal_not_found');

      await expectLater(
        repository.verify('goal-1'),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('unverify', () {
    test('sends the goal id', () async {
      raise(Rpc.unverifyGoal, code: 'M0003', message: 'goal_not_found');

      await expectLater(
        repository.unverify('goal-1'),
        throwsA(isA<AppException>()),
      );

      verifyCalled(Rpc.unverifyGoal, {Rpc.pGoalId: 'goal-1'});
    });

    test('a member who is not the admin is a permission failure', () async {
      raise(Rpc.unverifyGoal, code: 'M0018', message: 'admin_only');

      await expectLater(
        repository.unverify('goal-1'),
        throwsA(
          isA<PermissionException>().having(
            (e) => e.message,
            'message',
            'Only the group admin can do that.',
          ),
        ),
      );
    });

    test("the admin's own goal is a permission failure", () async {
      raise(
        Rpc.unverifyGoal,
        code: 'M0019',
        message: 'cannot_unverify_own_goal',
      );

      await expectLater(
        repository.unverify('goal-1'),
        throwsA(
          isA<PermissionException>().having(
            (e) => e.message,
            'message',
            startsWith('You cannot take back the verification'),
          ),
        ),
      );
    });

    test('a goal nobody verified says to refresh', () async {
      raise(Rpc.unverifyGoal, code: 'M0020', message: 'goal_not_verified');

      await expectLater(
        repository.unverify('goal-1'),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            startsWith('That goal is not verified.'),
          ),
        ),
      );
    });
  });

  group('assignGoal', () {
    final command = AssignGoalCommand(
      ownerId: 'user-2',
      title: 'Run 5k',
      type: GoalType.daily,
      deadline: DateTime(2026, 10, 9, 23, 59, 59, 999),
    );

    test('sends the command as the function arguments', () async {
      raise(Rpc.assignGoal, code: 'M0018', message: 'admin_only');

      await expectLater(
        repository.assignGoal(command),
        throwsA(isA<AppException>()),
      );

      verifyCalled(Rpc.assignGoal, command.toJson());
    });

    test('a member who is not the admin is a permission failure', () async {
      raise(Rpc.assignGoal, code: 'M0018', message: 'admin_only');

      await expectLater(
        repository.assignGoal(command),
        throwsA(
          isA<PermissionException>().having(
            (e) => e.message,
            'message',
            'Only the group admin can do that.',
          ),
        ),
      );
    });

    test('an owner outside the group says to refresh', () async {
      raise(Rpc.assignGoal, code: 'M0021', message: 'member_not_in_group');

      await expectLater(
        repository.assignGoal(command),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            startsWith('That member is not in your group.'),
          ),
        ),
      );
    });

    test('a title the database refuses says what is allowed', () async {
      raise(Rpc.assignGoal, code: 'M0016', message: 'invalid_title');

      await expectLater(
        repository.assignGoal(command),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            'Give the goal a title of 140 characters or fewer.',
          ),
        ),
      );
    });
  });

  group('updateTitle', () {
    test('sends the goal id and the title the sheet produced', () async {
      raise(Rpc.updateGoalTitle, code: 'M0003', message: 'goal_not_found');

      await expectLater(
        repository.updateTitle('goal-1', 'Long run'),
        throwsA(isA<AppException>()),
      );

      verifyCalled(Rpc.updateGoalTitle, {
        Rpc.pGoalId: 'goal-1',
        Rpc.pTitle: 'Long run',
      });
    });

    test('neither the owner nor the admin is a permission failure', () async {
      raise(Rpc.updateGoalTitle, code: 'M0014', message: 'not_allowed_to_edit');

      await expectLater(
        repository.updateTitle('goal-1', 'Long run'),
        throwsA(
          isA<PermissionException>().having(
            (e) => e.message,
            'message',
            'Only the member who set a goal, or the group admin, can edit it.',
          ),
        ),
      );
    });

    test('the owner of an assigned goal is sent to the admin', () async {
      raise(
        Rpc.updateGoalTitle,
        code: 'M0017',
        message: 'assigned_goal_admin_only',
      );

      await expectLater(
        repository.updateTitle('goal-1', 'Long run'),
        throwsA(
          isA<PermissionException>().having(
            (e) => e.message,
            'message',
            startsWith('The group admin set this goal for you'),
          ),
        ),
      );
    });

    test('a verified goal is locked', () async {
      raise(
        Rpc.updateGoalTitle,
        code: 'M0011',
        message: 'goal_verified_locked',
      );

      await expectLater(
        repository.updateTitle('goal-1', 'Long run'),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            "This goal is verified and can't be changed.",
          ),
        ),
      );
    });

    test('a title the database refuses says what is allowed', () async {
      raise(Rpc.updateGoalTitle, code: 'M0016', message: 'invalid_title');

      await expectLater(
        repository.updateTitle('goal-1', ''),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            'Give the goal a title of 140 characters or fewer.',
          ),
        ),
      );
    });

    test('a goal that is gone says to refresh', () async {
      raise(Rpc.updateGoalTitle, code: 'M0003', message: 'goal_not_found');

      await expectLater(
        repository.updateTitle('goal-1', 'Long run'),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('deleteGoal', () {
    test('sends the goal id', () async {
      raise(Rpc.deleteGoal, code: 'M0003', message: 'goal_not_found');

      await expectLater(
        repository.deleteGoal('goal-1'),
        throwsA(isA<AppException>()),
      );

      verifyCalled(Rpc.deleteGoal, {Rpc.pGoalId: 'goal-1'});
    });

    test('neither the owner nor the admin is a permission failure', () async {
      raise(Rpc.deleteGoal, code: 'M0015', message: 'not_allowed_to_delete');

      await expectLater(
        repository.deleteGoal('goal-1'),
        throwsA(
          isA<PermissionException>().having(
            (e) => e.message,
            'message',
            startsWith('Only the member who set a goal, or the group admin,'),
          ),
        ),
      );
    });

    test('a verified goal is locked', () async {
      raise(Rpc.deleteGoal, code: 'M0011', message: 'goal_verified_locked');

      await expectLater(
        repository.deleteGoal('goal-1'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('a goal that is already gone says to refresh', () async {
      raise(Rpc.deleteGoal, code: 'M0003', message: 'goal_not_found');

      await expectLater(
        repository.deleteGoal('goal-1'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('an RLS or grant refusal is a permission failure', () async {
      raise(
        Rpc.deleteGoal,
        code: '42501',
        message: 'permission denied for function delete_goal',
      );

      await expectLater(
        repository.deleteGoal('goal-1'),
        throwsA(isA<PermissionException>()),
      );
    });
  });

  group('unrecognised failures', () {
    test(
      'fall back to the token in the message when there is no code',
      () async {
        raise(Rpc.setGoalStatus, message: 'goal_verified_locked');

        await expectLater(
          repository.setStatus('goal-1', GoalStatus.complete),
          throwsA(isA<ValidationException>()),
        );
      },
    );

    test(
      'become a DatabaseException, which is not shown to the member',
      () async {
        raise(Rpc.verifyGoal, code: '08006', message: 'connection failure');

        await expectLater(
          repository.verify('goal-1'),
          throwsA(isA<DatabaseException>()),
        );
      },
    );
  });
}
