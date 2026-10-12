import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/features/auth/data/auth_repository.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../mocks.dart';

const _ada = Member(id: 'user-1', name: 'Ada', groupId: 'group-1');

void main() {
  late MockAuthRepository authRepository;
  late MockMemberRepository memberRepository;

  setUp(() {
    authRepository = MockAuthRepository();
    memberRepository = MockMemberRepository();
  });

  /// Riverpod retries a failed provider ten times with a growing backoff,
  /// which outlives the test timeout. Tests assert on the first result.
  Duration? noRetry(int count, Object error) => null;

  group('authUserId', () {
    Future<String?> userId() {
      final container = ProviderContainer(
        retry: noRetry,
        overrides: [authRepositoryProvider.overrideWithValue(authRepository)],
      );
      addTearDown(container.dispose);
      // An async provider does not start until something listens to it, and
      // an unlistened error would escape the test.
      container.listen(authUserIdProvider, (_, _) {}, onError: (_, _) {});
      return container.read(authUserIdProvider.future);
    }

    test('emits the restored session id before any auth event', () async {
      when(authRepository.currentUserID).thenReturn('user-1');

      expect(await userId(), 'user-1');
    });

    test('emits null when there is no session', () async {
      expect(await userId(), isNull);
    });
  });

  group('currentMember', () {
    Future<Member?> currentMember(String? signedInId) {
      final container = ProviderContainer(
        retry: noRetry,
        overrides: [
          authUserIdProvider.overrideWith((ref) => Stream.value(signedInId)),
          memberRepositoryProvider.overrideWithValue(memberRepository),
        ],
      );
      addTearDown(container.dispose);
      container.listen(currentMemberProvider, (_, _) {}, onError: (_, _) {});
      return container.read(currentMemberProvider.future);
    }

    test('is the signed-in member, group id included', () async {
      when(memberRepository.fetchMember('user-1')).thenAnswer((_) async => _ada);

      final member = await currentMember('user-1');

      expect(member, _ada);
      expect(member?.groupId, 'group-1');
      verify(memberRepository.fetchMember('user-1')).called(1);
    });

    test('is null when signed out, and does not hit the database', () async {
      expect(await currentMember(null), isNull);

      verifyZeroInteractions(memberRepository);
    });

    test('surfaces a missing member row as NotFoundException', () async {
      when(
        memberRepository.fetchMember('user-2'),
      ).thenThrow(const NotFoundException());

      await expectLater(
        currentMember('user-2'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });
}
