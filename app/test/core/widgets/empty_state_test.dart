import 'package:app/core/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the message and optional detail', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyState(
            icon: Icons.flag_outlined,
            message: 'Nothing here.',
            detail: 'Pull down to refresh.',
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
    expect(find.text('Nothing here.'), findsOneWidget);
    expect(find.text('Pull down to refresh.'), findsOneWidget);
  });
}
