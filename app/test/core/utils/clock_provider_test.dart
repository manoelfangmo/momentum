import 'package:app/core/utils/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('clockProvider can be overridden to freeze now', () {
    final frozen = DateTime(2026, 10, 6, 9, 30);
    final container = ProviderContainer(
      overrides: [clockProvider.overrideWithValue(() => frozen)],
    );
    addTearDown(container.dispose);

    expect(container.read(clockProvider)(), frozen);
    expect(container.read(clockProvider)(), same(frozen));
  });

  test('the default clock returns the current local time', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final now = container.read(clockProvider)();
    expect(now.difference(DateTime.now()).inSeconds.abs(), lessThan(2));
    expect(now.isUtc, isFalse);
  });
}
