import 'package:app/app.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a signed-out start-up opens on the sign-in page', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        // The real provider would reach for a Supabase client this test has
        // not initialized. Where the router goes from here is its own test.
        overrides: [currentMemberProvider.overrideWith((ref) => null)],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
  });
}
