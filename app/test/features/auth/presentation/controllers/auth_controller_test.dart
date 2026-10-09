import 'dart:async';

import 'package:app/core/utils/app_exception.dart';
import 'package:app/features/auth/data/auth_repository.dart';
import 'package:app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks.dart';

void main() {
  late MockAuthRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockAuthRepository();
    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    // Subscribe so the notifier survives between reads instead of rebuilding.
    container.listen(authControllerProvider, (_, _) {});
  });

  AuthController controller() =>
      container.read(authControllerProvider.notifier);

  AsyncValue<void> state() => container.read(authControllerProvider);

  test('starts idle, not loading', () {
    expect(state(), const AsyncData<void>(null));
    verifyZeroInteractions(repository);
  });

  test('signUp forwards name, email, and password', () async {
    await controller().signUp(
      name: 'Ada',
      email: 'ada@example.com',
      password: 'hunter2',
    );

    verify(
      repository.signUp(
        name: 'Ada',
        email: 'ada@example.com',
        password: 'hunter2',
      ),
    ).called(1);
    expect(state().hasError, isFalse);
  });

  test('signIn forwards email and password', () async {
    await controller().signIn(email: 'ada@example.com', password: 'hunter2');

    verify(
      repository.signIn(email: 'ada@example.com', password: 'hunter2'),
    ).called(1);
    expect(state().hasError, isFalse);
  });

  test('signOut calls the repository', () async {
    await controller().signOut();

    verify(repository.signOut()).called(1);
    expect(state().hasError, isFalse);
  });

  test('is loading while the call is in flight', () async {
    final inFlight = Completer<void>();
    when(
      repository.signIn(
        email: anyNamed('email'),
        password: anyNamed('password'),
      ),
    ).thenAnswer((_) => inFlight.future);

    final submitted = controller().signIn(
      email: 'ada@example.com',
      password: 'hunter2',
    );
    expect(state().isLoading, isTrue);

    inFlight.complete();
    await submitted;
    expect(state().isLoading, isFalse);
  });

  test('a repository failure lands in the state instead of being thrown', () async {
    when(
      repository.signIn(
        email: anyNamed('email'),
        password: anyNamed('password'),
      ),
    ).thenThrow(const AuthException('Invalid login credentials'));

    await controller().signIn(email: 'ada@example.com', password: 'wrong');

    expect(
      state().error,
      isA<AuthException>().having(
        (e) => e.message,
        'message',
        'Invalid login credentials',
      ),
    );
  });

  test('a retry clears the previous error', () async {
    when(
      repository.signIn(
        email: anyNamed('email'),
        password: anyNamed('password'),
      ),
    ).thenThrow(const NetworkException());

    await controller().signIn(email: 'ada@example.com', password: 'hunter2');
    expect(state().hasError, isTrue);

    when(
      repository.signIn(
        email: anyNamed('email'),
        password: anyNamed('password'),
      ),
    ).thenAnswer((_) async {});

    await controller().signIn(email: 'ada@example.com', password: 'hunter2');
    expect(state().hasError, isFalse);
  });
}
