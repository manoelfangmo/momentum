import 'package:app/features/groups/data/groups_repository.dart';
import 'package:app/features/groups/domain/group.dart';
import 'package:app/features/groups/presentation/validators/group_validators.dart';
import 'package:app/features/groups/presentation/widgets/create_group_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks.dart';

const _group = Group(id: 'group-1', name: 'Morning crew', createdBy: 'user-1');

void main() {
  late MockGroupsRepository repository;

  setUp(() {
    repository = MockGroupsRepository();
    when(repository.createGroup(any)).thenAnswer((_) async => _group);
  });

  Future<void> pumpCard(WidgetTester tester) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [groupsRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: Scaffold(body: CreateGroupCard())),
      ),
    );
  }

  testWidgets('creates the group under the trimmed name', (tester) async {
    await pumpCard(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Group name'),
      '  Morning crew  ',
    );

    await tester.tap(find.text('Create group'));
    await tester.pumpAndSettle();

    verify(repository.createGroup('Morning crew')).called(1);
  });

  testWidgets('an empty name never reaches the repository', (tester) async {
    await pumpCard(tester);

    await tester.tap(find.text('Create group'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a name for the group.'), findsOneWidget);
    verifyZeroInteractions(repository);
  });

  testWidgets('a too-long name never reaches the repository', (tester) async {
    await pumpCard(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Group name'),
      'a' * (maxGroupNameLength + 1),
    );

    await tester.tap(find.text('Create group'));
    await tester.pumpAndSettle();

    expect(
      find.text('Use $maxGroupNameLength characters or fewer.'),
      findsOneWidget,
    );
    verifyZeroInteractions(repository);
  });
}
