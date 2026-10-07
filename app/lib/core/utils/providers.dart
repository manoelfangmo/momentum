import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

/// Time source for period math.
///
/// Features call `ref.watch(clockProvider)()` instead of [DateTime.now]
/// so tests can freeze the clock.
@Riverpod(keepAlive: true)
DateTime Function() clock(Ref ref) => DateTime.now;
