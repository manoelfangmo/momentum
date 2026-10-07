import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/groups/data/groups_repository.dart';
import 'package:app/features/groups/presentation/widgets/member_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks.dart';

const _ada = Member(id: 'user-1', name: 'Ada', groupId: 'group-1');
const _grace = Member(id: 'user-2', name: 'Grace', groupId: 'group-1');

void main() {
  late MockGroupsRepository repository;

  setUp(() => repository = MockGroupsRepository());

  Future<void> pumpList(WidgetTester tester) {
    return tester.pumpWidget(
      ProviderScope(
        retry: (count, error) => null,
        overrides: [
          groupsRepositoryProvider.overrideWithValue(repository),
          currentMemberProvider.overrideWith((ref) async => _ada),
        ],
        child: const MaterialApp(
          home: Scaffold(body: MemberList(groupId: 'group-1')),
        ),
      ),
    );
  }

  testWidgets('lists the group and marks the signed-in member', (tester) async {
    when(repository.fetchMembers('group-1'))
        .thenAnswer((_) async => [_ada, _grace]);

    await pumpList(tester);
    await tester.pumpAndSettle();

    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('Grace'), findsOneWidget);

    // The mark belongs to Ada's row, and to no other.
    final adaTile = find.ancestor(
      of: find.text('Ada'),
      matching: find.byType(ListTile),
    );
    expect(find.descendant(of: adaTile, matching: find.text('You')), findsOne);
    expect(find.text('You'), findsOne);
  });

  testWidgets('offers a retry when the members fail to load', (tester) async {
    when(repository.fetchMembers('group-1'))
        .thenThrow(const NetworkException());

    await pumpList(tester);
    await tester.pumpAndSettle();

    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('says so when the group has no members', (tester) async {
    when(repository.fetchMembers('group-1')).thenAnswer((_) async => []);

    await pumpList(tester);
    await tester.pumpAndSettle();

    expect(find.text('No members in this group yet.'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
  });
}
