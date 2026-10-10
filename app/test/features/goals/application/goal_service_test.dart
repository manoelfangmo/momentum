import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/core/utils/providers.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/goals/application/goal_service.dart';
import 'package:app/features/goals/data/goals_repository.dart';
import 'package:app/features/goals/data/models.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_permissions.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:app/features/groups/data/groups_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../mocks.dart';

const _ada = Member(id: 'user-1', name: 'Ada', groupId: 'group-1');
const _grace = Member(id: 'user-2', name: 'Grace', groupId: 'group-1');
const _unjoined = Member(id: 'user-3', name: 'Lin');

/// A Friday morning: the week it lands in ends on Sunday the 11th.
final _frozen = DateTime(2026, 10, 9, 8, 30);

Goal goalOwnedBy(
  String ownerId, {
  GoalStatus status = GoalStatus.notStarted,
  bool verified = false,
}) => Goal(
  id: 'goal-1',
  ownerId: ownerId,
  groupId: 'group-1',
  title: 'Run 5k',
  type: GoalType.daily,
  deadline: DateTime(2026, 10, 9, 23, 59, 59, 999),
  status: status,
  verified: verified,
  createdAt: _frozen,
);

void main() {
  late MockGoalsRepository repository;

  setUp(() {
    repository = MockGoalsRepository();
    when(repository.createGoal(any))
        .thenAnswer((_) async => goalOwnedBy(_ada.id));
    when(repository.assignGoal(any))
        .thenAnswer((_) async => goalOwnedBy(_grace.id));
  });

  ProviderContainer containerFor(Member? signedIn, {bool isAdmin = false}) {
    final container = ProviderContainer(
      overrides: [
        goalsRepositoryProvider.overrideWithValue(repository),
        currentMemberProvider.overrideWith((ref) async => signedIn),
        isGroupAdminProvider.overrideWith((ref) async => isAdmin),
        clockProvider.overrideWithValue(() => _frozen),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// The captured command, so a test can assert on what was sent rather than
  /// on how the service put it together.
  CreateGoalCommand sentCommand() =>
      verify(repository.createGoal(captureAny)).captured.single
          as CreateGoalCommand;

  AssignGoalCommand sentAssignCommand() =>
      verify(repository.assignGoal(captureAny)).captured.single
          as AssignGoalCommand;

  group('createGoal', () {
    test('owns the goal to the signed-in member and their group', () async {
      await containerFor(_ada)
          .read(goalServiceProvider)
          .createGoal(title: 'Run 5k', type: GoalType.daily);

      final command = sentCommand();
      expect(command.ownerId, _ada.id);
      expect(command.groupId, _ada.groupId);
      expect(command.title, 'Run 5k');
    });

    test(
      'deadlines a goal at the end of the current period of its type',
      () async {
        final service = containerFor(_ada).read(goalServiceProvider);

        for (final type in GoalType.values) {
          await service.createGoal(title: 'Run 5k', type: type);

          final command = sentCommand();
          expect(command.type, type);
          expect(command.deadline, Period.containing(_frozen, type).deadline);
          clearInteractions(repository);
        }
      },
    );

    test(
      'takes the deadline from the clock, not from the wall clock',
      () async {
        await containerFor(_ada)
            .read(goalServiceProvider)
            .createGoal(title: 'Run 5k', type: GoalType.weekly);

        // The week of Monday the 5th, which only holds if the clock is frozen.
        expect(sentCommand().deadline, DateTime(2026, 10, 11, 23, 59, 59, 999));
      },
    );

    test('returns the stored goal the repository read back', () async {
      final stored = goalOwnedBy(_ada.id);
      when(repository.createGoal(any)).thenAnswer((_) async => stored);

      final goal = await containerFor(_ada)
          .read(goalServiceProvider)
          .createGoal(title: 'Run 5k', type: GoalType.daily);

      expect(goal, stored);
    });

    test('fails without inserting when the member has no group', () async {
      await expectLater(
        containerFor(_unjoined)
            .read(goalServiceProvider)
            .createGoal(title: 'Run 5k', type: GoalType.daily),
        throwsA(isA<NotFoundException>()),
      );
      verifyZeroInteractions(repository);
    });

    test('fails without inserting when nobody is signed in', () async {
      await expectLater(
        containerFor(null)
            .read(goalServiceProvider)
            .createGoal(title: 'Run 5k', type: GoalType.daily),
        throwsA(isA<NotFoundException>()),
      );
      verifyZeroInteractions(repository);
    });
  });

  group('assignGoal', () {
    test('owns the goal to the member the admin picked', () async {
      await containerFor(_ada, isAdmin: true)
          .read(goalServiceProvider)
          .assignGoal(
            ownerId: _grace.id,
            title: 'Run 5k',
            type: GoalType.daily,
          );

      final command = sentAssignCommand();
      expect(command.ownerId, _grace.id);
      expect(command.title, 'Run 5k');
    });

    test(
      'deadlines an assigned goal at the end of the current period',
      () async {
        final service = containerFor(
          _ada,
          isAdmin: true,
        ).read(goalServiceProvider);

        for (final type in GoalType.values) {
          await service.assignGoal(
            ownerId: _grace.id,
            title: 'Run 5k',
            type: type,
          );

          final command = sentAssignCommand();
          expect(command.type, type);
          expect(command.deadline, Period.containing(_frozen, type).deadline);
          clearInteractions(repository);
        }
      },
    );

    test(
      'takes the deadline from the clock, not from the wall clock',
      () async {
        await containerFor(_ada, isAdmin: true)
            .read(goalServiceProvider)
            .assignGoal(
              ownerId: _grace.id,
              title: 'Run 5k',
              type: GoalType.weekly,
            );

        // The week of Monday the 5th, which only holds if the clock is frozen.
        expect(
          sentAssignCommand().deadline,
          DateTime(2026, 10, 11, 23, 59, 59, 999),
        );
      },
    );

    test('returns the stored goal the repository read back', () async {
      final stored = goalOwnedBy(_grace.id);
      when(repository.assignGoal(any)).thenAnswer((_) async => stored);

      final goal = await containerFor(_ada, isAdmin: true)
          .read(goalServiceProvider)
          .assignGoal(
            ownerId: _grace.id,
            title: 'Run 5k',
            type: GoalType.daily,
          );

      expect(goal, stored);
    });

    test('leaves the admin check to the RPC', () async {
      await containerFor(_ada)
          .read(goalServiceProvider)
          .assignGoal(
            ownerId: _grace.id,
            title: 'Run 5k',
            type: GoalType.daily,
          );

      verify(repository.assignGoal(any)).called(1);
    });
  });

  group('goalPermissions', () {
    /// The provider reads both the member and the admin flag synchronously,
    /// so both have to be resolved before the first read.
    Future<GoalPermissions> permissions(
      Member? signedIn,
      Goal goal, {
      bool isAdmin = false,
    }) async {
      final container = containerFor(signedIn, isAdmin: isAdmin);
      container.listen(currentMemberProvider, (_, _) {}, onError: (_, _) {});
      container.listen(isGroupAdminProvider, (_, _) {}, onError: (_, _) {});
      await container.read(currentMemberProvider.future);
      await container.read(isGroupAdminProvider.future);
      return container.read(goalPermissionsProvider(goal));
    }

    test('lets the owner move and manage their own goal', () async {
      final permitted = await permissions(_ada, goalOwnedBy(_ada.id));

      expect(permitted.canChangeStatus, isTrue);
      expect(permitted.canEdit, isTrue);
      expect(permitted.canVerify, isFalse);
    });

    test(
      'offers everyone else a verify on an unverified complete goal',
      () async {
        final permitted = await permissions(
          _grace,
          goalOwnedBy(_ada.id, status: GoalStatus.complete),
        );

        expect(permitted.canVerify, isTrue);
        expect(permitted.canChangeStatus, isFalse);
      },
    );

    test('gives the admin a verified goal they do not own', () async {
      final verified = goalOwnedBy(
        _ada.id,
        status: GoalStatus.complete,
        verified: true,
      );

      expect(
        await permissions(_grace, verified, isAdmin: true),
        const GoalPermissions(
          canChangeStatus: false,
          canVerify: false,
          canUnverify: true,
          canEdit: true,
          canDelete: true,
        ),
      );
    });

    test('offers nothing while there is no member to compare against', () {
      final container = containerFor(null);

      expect(
        container.read(goalPermissionsProvider(goalOwnedBy(_ada.id))),
        GoalPermissions.none,
      );
    });

    test('treats an admin flag that has not loaded as not the admin', () async {
      final container = containerFor(_grace, isAdmin: true);
      container.listen(currentMemberProvider, (_, _) {}, onError: (_, _) {});
      await container.read(currentMemberProvider.future);
      final verified = goalOwnedBy(
        _ada.id,
        status: GoalStatus.complete,
        verified: true,
      );

      expect(
        container.read(goalPermissionsProvider(verified)).canUnverify,
        isFalse,
      );
    });

    test('keeps one cache per goal', () async {
      final container = containerFor(_grace);
      container.listen(currentMemberProvider, (_, _) {}, onError: (_, _) {});
      await container.read(currentMemberProvider.future);
      final mine = goalOwnedBy(_grace.id);
      final theirs = goalOwnedBy(_ada.id, status: GoalStatus.complete);

      expect(
        container.read(goalPermissionsProvider(mine)).canChangeStatus,
        isTrue,
      );
      expect(container.read(goalPermissionsProvider(theirs)).canVerify, isTrue);
    });
  });
}
