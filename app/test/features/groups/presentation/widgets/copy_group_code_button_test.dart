import 'package:app/features/groups/presentation/widgets/copy_group_code_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _code = '8f14e45f-ceea-467a-9d2e-1b2a3c4d5e6f';

void main() {
  testWidgets('puts the code on the clipboard and says so', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: CopyGroupCodeButton(code: _code)),
      ),
    );
    await tester.tap(find.text('Copy invite code'));
    await tester.pumpAndSettle();

    expect(copied, _code);
    expect(find.text('Invite code copied.'), findsOneWidget);
  });
}
