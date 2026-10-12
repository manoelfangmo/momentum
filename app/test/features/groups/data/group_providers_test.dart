import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/groups/data/groups_repository.dart';
import 'package:app/features/groups/domain/group.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../mocks.dart';

const _group = Group(id: 'group-1', name: 'Morning crew', createdBy: 'user-1');
const _ada = Member(id: 'user-1', name: 'Ada', groupId: 'group-1');
const _grace = Member(id: 'user-2', name: 'Grace', groupId: 'group-1');
const _unjoined = Member(id: 'user-3', name: 'Lin');

void main() {
  late MockGroupsRepository repository;

  setUp(() => repository = MockGroupsRepository());

  /// Riverpod retries a failed provider ten times with a growing backoff,
  /// which outlives the test timeout. Tests assert on the first result.
  Duration? noRetry(int count, Object error) => null;

  ProviderContainer containerFor(Member? signedIn) {
    final container = ProviderContainer(
      retry: noRetry,
      overrides: [
        groupsRepositoryProvider.overrideWithValue(repository),
        currentMemberProvider.overrideWith((ref) async => signedIn),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('currentGroup', () {
    test('is the group the member row points at', () async {
      when(repository.fetchGroup('group-1')).thenAnswer((_) async => _group);
      final container = containerFor(_ada);
      // An async provider does not start until something listens to it.
      container.listen(currentGroupProvider, (_, _) {}, onError: (_, _) {});

      expect(await container.read(currentGroupProvider.future), _group);
      verify(repository.fetchGroup('group-1')).called(1);
    });

    test('fails instead of querying when the member has no group', () async {
      final container = containerFor(_unjoined);
      container.listen(currentGroupProvider, (_, _) {}, onError: (_, _) {});

      await expectLater(
        container.read(currentGroupProvider.future),
        throwsA(isA<NotFoundException>()),
      );
      verifyZeroInteractions(repository);
    });

    test('fails when nobody is signed in', () async {
      final container = containerFor(null);
      container.listen(currentGroupProvider, (_, _) {}, onError: (_, _) {});

      await expectLater(
        container.read(currentGroupProvider.future),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('groupMembers', () {
    test('returns the members the repository gives for that id', () async {
      when(repository.fetchMembers('group-1'))
          .thenAnswer((_) async => [_ada, _grace]);
      final container = containerFor(_ada);
      final members = groupMembersProvider('group-1');
      container.listen(members, (_, _) {}, onError: (_, _) {});

      expect(await container.read(members.future), [_ada, _grace]);
    });

    test('keeps one cache per group id', () async {
      when(repository.fetchMembers('group-1')).thenAnswer((_) async => [_ada]);
      when(repository.fetchMembers('group-2'))
          .thenAnswer((_) async => [_grace]);
      final container = containerFor(_ada);
      for (final id in ['group-1', 'group-2']) {
        container.listen(
          groupMembersProvider(id),
          (_, _) {},
          onError: (_, _) {},
        );
      }

      expect(await container.read(groupMembersProvider('group-1').future), [
        _ada,
      ]);
      expect(await container.read(groupMembersProvider('group-2').future), [
        _grace,
      ]);
    });
  });

  group('isGroupAdmin', () {
    Future<bool> isAdminFor(Member? signedIn) async {
      when(repository.fetchGroup('group-1')).thenAnswer((_) async => _group);
      final container = containerFor(signedIn);
      container.listen(isGroupAdminProvider, (_, _) {}, onError: (_, _) {});
      return container.read(isGroupAdminProvider.future);
    }

    test('is true for the member who created the group', () async {
      expect(await isAdminFor(_ada), isTrue);
    });

    test('is false for every other member of that group', () async {
      expect(await isAdminFor(_grace), isFalse);
    });

    test('is false without asking for a group when there is none', () async {
      expect(await isAdminFor(_unjoined), isFalse);
      verifyNever(repository.fetchGroup(any));
    });

    test('is false when nobody is signed in', () async {
      expect(await isAdminFor(null), isFalse);
    });
  });
}
