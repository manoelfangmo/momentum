import 'dart:async';

import 'package:app/core/utils/app_exception.dart';
import 'package:app/features/auth/data/auth_repository.dart';
import 'package:app/features/auth/presentation/widgets/sign_in_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks.dart';

void main() {
  late MockAuthRepository repository;

  setUp(() => repository = MockAuthRepository());

  Future<void> pumpForm(WidgetTester tester) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: Scaffold(body: SignInForm())),
      ),
    );
  }

  Future<void> fillIn(
    WidgetTester tester, {
    required String email,
    required String password,
  }) async {
    await tester.enterText(find.widgetWithText(TextField, 'Email'), email);
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      password,
    );
  }

  testWidgets('a bad email stops the submit before the repository', (
    tester,
  ) async {
    await pumpForm(tester);
    await fillIn(tester, email: 'not-an-email', password: 'hunter2');

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
    verifyZeroInteractions(repository);
  });

  testWidgets('the button spins while the call is in flight', (tester) async {
    final inFlight = Completer<void>();
    when(
      repository.signIn(
        email: anyNamed('email'),
        password: anyNamed('password'),
      ),
    ).thenAnswer((_) => inFlight.future);

    await pumpForm(tester);
    await fillIn(tester, email: 'ada@example.com', password: 'hunter2');
    await tester.tap(find.text('Sign in'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Sign in'), findsNothing);

    inFlight.complete();
    await tester.pumpAndSettle();

    verify(
      repository.signIn(email: 'ada@example.com', password: 'hunter2'),
    ).called(1);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('a rejected sign-in shows the message in a toast', (
    tester,
  ) async {
    when(
      repository.signIn(
        email: anyNamed('email'),
        password: anyNamed('password'),
      ),
    ).thenThrow(const AuthException('Invalid login credentials'));

    await pumpForm(tester);
    await fillIn(tester, email: 'ada@example.com', password: 'wrong guess');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(SnackBar, 'Invalid login credentials'),
      findsOneWidget,
    );
  });
}
