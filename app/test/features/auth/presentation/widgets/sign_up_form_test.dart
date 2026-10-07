import 'package:app/features/auth/data/auth_repository.dart';
import 'package:app/features/auth/presentation/widgets/sign_up_form.dart';
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
        child: const MaterialApp(home: Scaffold(body: SignUpForm())),
      ),
    );
  }

  testWidgets('submits the trimmed name alongside the credentials', (
    tester,
  ) async {
    await pumpForm(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Name'),
      '  Ada Lovelace  ',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Email'),
      'ada@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'hunter2',
    );

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    verify(
      repository.signUp(
        name: 'Ada Lovelace',
        email: 'ada@example.com',
        password: 'hunter2',
      ),
    ).called(1);
  });

  testWidgets('a short password never reaches the repository', (tester) async {
    await pumpForm(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Ada');
    await tester.enterText(
      find.widgetWithText(TextField, 'Email'),
      'ada@example.com',
    );
    await tester.enterText(find.widgetWithText(TextField, 'Password'), '12345');

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Use at least 6 characters.'), findsOneWidget);
    verifyZeroInteractions(repository);
  });
}
