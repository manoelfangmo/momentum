import 'package:app/core/utils/app_exception.dart';
import 'package:app/features/groups/data/groups_repository.dart';
import 'package:app/features/groups/domain/group.dart';
import 'package:app/features/groups/presentation/onboarding_page.dart';
import 'package:app/features/groups/presentation/widgets/join_group_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks.dart';

const _code = '8f14e45f-ceea-467a-9d2e-1b2a3c4d5e6f';
const _group = Group(id: _code, name: 'Morning crew', createdBy: 'user-2');

void main() {
  late MockGroupsRepository repository;

  setUp(() {
    repository = MockGroupsRepository();
    when(repository.joinGroup(any)).thenAnswer((_) async => _group);
  });

  Future<void> pump(WidgetTester tester, Widget child) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [groupsRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(home: child),
      ),
    );
  }

  Future<void> submitCode(WidgetTester tester, String code) async {
    await tester.enterText(find.widgetWithText(TextField, 'Invite code'), code);
    // Both cards together are taller than the test window, so the button is
    // below the fold when the whole page is on screen.
    await tester.ensureVisible(find.text('Join group'));
    await tester.tap(find.text('Join group'));
    await tester.pumpAndSettle();
  }

  testWidgets('joins with the pasted code, whitespace and all', (tester) async {
    await pump(tester, const Scaffold(body: JoinGroupCard()));

    await submitCode(tester, '  $_code  ');

    verify(repository.joinGroup(_code)).called(1);
  });

  testWidgets('a code that is not a uuid stops at the form', (tester) async {
    await pump(tester, const Scaffold(body: JoinGroupCard()));

    await submitCode(tester, 'morning-crew');

    expect(
      find.text('That does not look like an invite code.'),
      findsOneWidget,
    );
    verifyZeroInteractions(repository);
  });

  testWidgets('a rejected join is shown to the member', (tester) async {
    when(repository.joinGroup(any))
        .thenThrow(const ValidationException('No group has that code.'));
    // Through the page, which is where the toast listener lives.
    await pump(tester, const OnboardingPage());

    await submitCode(tester, _code);

    expect(find.text('No group has that code.'), findsOneWidget);
  });

  testWidgets('being in a group already is shown to the member', (
    tester,
  ) async {
    when(repository.joinGroup(any))
        .thenThrow(const ValidationException('You are already in a group.'));
    await pump(tester, const OnboardingPage());

    await submitCode(tester, _code);

    expect(find.text('You are already in a group.'), findsOneWidget);
  });
}
