import 'package:app/core/database/rpc.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/features/goals/data/goals_repository.dart';
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

  group('verifyComplete', () {
    test(
      'the owner trying to verify their own goal is a permission failure',
      () async {
        raise(
          Rpc.verifyGoalComplete,
          code: 'M0005',
          message: 'cannot_verify_own_goal',
        );

        await expectLater(
          repository.verifyComplete('goal-1'),
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

    test('a goal someone else already settled says to refresh', () async {
      raise(Rpc.verifyGoalComplete, code: 'M0006', message: 'goal_not_pending');

      await expectLater(
        repository.verifyComplete('goal-1'),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            startsWith('That goal was already settled.'),
          ),
        ),
      );
    });

    test('a goal that is gone says to refresh', () async {
      raise(Rpc.verifyGoalComplete, code: 'M0003', message: 'goal_not_found');

      await expectLater(
        repository.verifyComplete('goal-1'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('a goal in another group is a permission failure', () async {
      raise(Rpc.verifyGoalComplete, code: 'M0004', message: 'not_same_group');

      await expectLater(
        repository.verifyComplete('goal-1'),
        throwsA(isA<PermissionException>()),
      );
    });
  });

  group('markMissed', () {
    test('a non-owner is a permission failure', () async {
      raise(
        Rpc.markGoalMissed,
        code: 'M0007',
        message: 'only_owner_can_mark_missed',
      );

      await expectLater(
        repository.markMissed('goal-1'),
        throwsA(
          isA<PermissionException>().having(
            (e) => e.message,
            'message',
            'Only the member who set a goal can mark it missed.',
          ),
        ),
      );
    });

    test('an RLS or grant refusal is a permission failure', () async {
      raise(
        Rpc.markGoalMissed,
        code: '42501',
        message: 'permission denied for function mark_goal_missed',
      );

      await expectLater(
        repository.markMissed('goal-1'),
        throwsA(isA<PermissionException>()),
      );
    });
  });

  group('unrecognised failures', () {
    test(
      'fall back to the token in the message when there is no code',
      () async {
        raise(Rpc.markGoalMissed, message: 'goal_not_pending');

        await expectLater(
          repository.markMissed('goal-1'),
          throwsA(isA<ValidationException>()),
        );
      },
    );

    test(
      'become a DatabaseException, which is not shown to the member',
      () async {
        raise(
          Rpc.verifyGoalComplete,
          code: '08006',
          message: 'connection failure',
        );

        await expectLater(
          repository.verifyComplete('goal-1'),
          throwsA(isA<DatabaseException>()),
        );
      },
    );
  });
}
