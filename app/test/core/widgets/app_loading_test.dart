import 'package:app/core/widgets/app_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows a progress indicator', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppLoading())),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
