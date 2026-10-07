import 'package:app/features/stats/domain/completion_stats.dart';
import 'package:app/features/stats/presentation/widgets/completion_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpBadge(WidgetTester tester, CompletionStats stats) {
    return tester.pumpWidget(
      MaterialApp(home: Scaffold(body: CompletionBadge(stats))),
    );
  }

  ColorScheme schemeOf(WidgetTester tester) =>
      Theme.of(tester.element(find.byType(CompletionBadge))).colorScheme;

  testWidgets('2 of 3 is the label, a bar, and the pending-as-missed hint', (
    tester,
  ) async {
    await pumpBadge(tester, const CompletionStats(complete: 2, total: 3));

    expect(find.text('2/3 · 67%'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(
      find.byTooltip('Pending goals count as missed until verified'),
      findsOneWidget,
    );

    final bar = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(bar.value, closeTo(2 / 3, 1e-10));
  });

  testWidgets('0 goals is an em dash, not 0% or a bar', (tester) async {
    await pumpBadge(tester, const CompletionStats(complete: 0, total: 0));

    expect(find.text('—'), findsOneWidget);
    expect(find.textContaining('%'), findsNothing);
    expect(find.textContaining('NaN'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('80% and up uses the theme primary', (tester) async {
    await pumpBadge(tester, const CompletionStats(complete: 4, total: 5));

    final bar = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(find.text('4/5 · 80%'), findsOneWidget);
    expect(bar.color, schemeOf(tester).primary);
  });

  testWidgets('50% up to 80% is amber', (tester) async {
    await pumpBadge(tester, const CompletionStats(complete: 1, total: 2));

    final bar = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(find.text('1/2 · 50%'), findsOneWidget);
    expect(bar.color, const Color(0xFFF9A825));
  });

  testWidgets('below 50% uses the theme error', (tester) async {
    await pumpBadge(tester, const CompletionStats(complete: 1, total: 3));

    final bar = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(find.text('1/3 · 33%'), findsOneWidget);
    expect(bar.color, schemeOf(tester).error);
  });
}
