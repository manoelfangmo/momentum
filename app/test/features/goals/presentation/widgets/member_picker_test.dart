import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/core/utils/providers.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/goals/presentation/controllers/goals_view_controller.dart';
import 'package:app/features/goals/presentation/widgets/member_picker.dart';
import 'package:app/features/groups/data/groups_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks.dart';

/// The signed-in member sorts after Grace, so "Me first" is visible in the
/// order the picker offers rather than coming along with the repository's.
const _zoe = Member(id: 'user-1', name: 'Zoe', groupId: 'group-1');
const _grace = Member(id: 'user-2', name: 'Grace', groupId: 'group-1');

void main() {
  late MockGroupsRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockGroupsRepository();
    container = ProviderContainer(
      retry: (count, error) => null,
      overrides: [
        groupsRepositoryProvider.overrideWithValue(repository),
        currentMemberProvider.overrideWith((ref) => _zoe),
        clockProvider.overrideWithValue(() => DateTime(2026, 10, 7, 8)),
      ],
    );
    addTearDown(container.dispose);
  });

  /// The container is built here rather than by `ProviderScope` so the test can
  /// read the selection the picker wrote.
  Future<void> pumpPicker(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            appBar: _TestAppBar(),
            body: SizedBox.shrink(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  String selectedId() =>
      container.read(goalsViewControllerProvider).selectedMemberId;

  testWidgets('starts on the signed-in member, named Me', (tester) async {
    when(
      repository.fetchMembers('group-1'),
    ).thenAnswer((_) async => [_grace, _zoe]);

    await pumpPicker(tester);

    expect(find.text('Me'), findsOneWidget);
    expect(find.text('Zoe'), findsNothing);
    expect(find.text('Grace'), findsNothing);
  });

  testWidgets('offers the group with Me first', (tester) async {
    when(
      repository.fetchMembers('group-1'),
    ).thenAnswer((_) async => [_grace, _zoe]);

    await pumpPicker(tester);
    await tester.tap(find.byType(MemberPicker));
    await tester.pumpAndSettle();

    final menuItems = tester.widgetList<PopupMenuItem<String>>(
      find.byType(PopupMenuItem<String>),
    );
    expect(menuItems.map((item) => item.value), ['user-1', 'user-2']);
  });

  testWidgets('picking someone else moves the selection', (tester) async {
    when(
      repository.fetchMembers('group-1'),
    ).thenAnswer((_) async => [_grace, _zoe]);

    await pumpPicker(tester);
    await tester.tap(find.byType(MemberPicker));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Grace').last);
    await tester.pumpAndSettle();

    expect(selectedId(), 'user-2');
    expect(find.text('Grace'), findsOneWidget);
  });

  testWidgets('offers a retry when the group fails to load', (tester) async {
    when(repository.fetchMembers('group-1')).thenThrow(const NetworkException());

    await pumpPicker(tester);

    expect(find.byIcon(Icons.person_off_outlined), findsOneWidget);
  });

  testWidgets('says so when the group has no members', (tester) async {
    when(repository.fetchMembers('group-1')).thenAnswer((_) async => []);

    await pumpPicker(tester);

    expect(find.byIcon(Icons.person_outline), findsOneWidget);
    expect(find.byType(PopupMenuButton<String>), findsNothing);
  });
}

/// An app bar so the picker is laid out where it actually lives.
class _TestAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _TestAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Goals'),
      actions: const [MemberPicker(groupId: 'group-1')],
    );
  }
}
