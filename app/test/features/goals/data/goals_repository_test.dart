import 'package:app/core/database/rpc.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/features/goals/data/goals_repository.dart';
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
    test('a non-owner is a permission failure', () async {
      raise(
        Rpc.setGoalStatus,
        code: 'M0010',
        message: 'only_owner_can_change_status',
      );

      await expectLater(
        repository.setStatus('goal-1', GoalStatus.inProgress),
        throwsA(
          isA<PermissionException>().having(
            (e) => e.message,
            'message',
            'Only the member who set a goal can change its status.',
          ),
        ),
      );
    });

    test('a verified goal is locked', () async {
      raise(
        Rpc.setGoalStatus,
        code: 'M0011',
        message: 'goal_verified_locked',
      );

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
        raise(
          Rpc.verifyGoal,
          code: 'M0005',
          message: 'cannot_verify_own_goal',
        );

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

    test('a non-owner is a permission failure', () async {
      raise(Rpc.updateGoalTitle, code: 'M0014', message: 'only_owner_can_edit');

      await expectLater(
        repository.updateTitle('goal-1', 'Long run'),
        throwsA(
          isA<PermissionException>().having(
            (e) => e.message,
            'message',
            'Only the member who set a goal can edit it.',
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

    test('a non-owner is a permission failure', () async {
      raise(Rpc.deleteGoal, code: 'M0015', message: 'only_owner_can_delete');

      await expectLater(
        repository.deleteGoal('goal-1'),
        throwsA(
          isA<PermissionException>().having(
            (e) => e.message,
            'message',
            'Only the member who set a goal can delete it.',
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
        raise(
          Rpc.verifyGoal,
          code: '08006',
          message: 'connection failure',
        );

        await expectLater(
          repository.verify('goal-1'),
          throwsA(isA<DatabaseException>()),
        );
      },
    );
  });
}
