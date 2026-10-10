import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/providers.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/goals/data/goals_repository.dart';
import 'package:app/features/goals/presentation/widgets/member_picker.dart';
import 'package:app/features/history/presentation/history_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../mocks.dart';

const _ada = Member(id: 'user-1', name: 'Ada', groupId: 'group-1');

final _now = DateTime(2026, 10, 7, 9);

void main() {
  late MockGoalsRepository goals;

  setUp(() {
    goals = MockGoalsRepository();
    when(
      goals.fetchGoalsBefore(
        ownerId: anyNamed('ownerId'),
        type: anyNamed('type'),
        before: anyNamed('before'),
      ),
    ).thenAnswer((_) async => []);
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        retry: (count, error) => null,
        overrides: [
          goalsRepositoryProvider.overrideWithValue(goals),
          currentMemberProvider.overrideWith((ref) => _ada),
          clockProvider.overrideWithValue(() => _now),
        ],
        child: const MaterialApp(home: HistoryPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('has a tab per goal type and no member picker', (tester) async {
    await pumpPage(tester);

    for (final type in GoalType.values) {
      expect(find.text(type.label), findsOneWidget);
    }
    expect(find.byType(MemberPicker), findsNothing);
  });

  testWidgets('the empty Day tab names the type', (tester) async {
    await pumpPage(tester);

    expect(find.text('No past Day goals yet.'), findsOneWidget);
  });

  testWidgets('the empty Week tab names the type', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('Week'));
    await tester.pumpAndSettle();

    expect(find.text('No past Week goals yet.'), findsOneWidget);
  });
}
