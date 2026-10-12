import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/go_router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // `goRouterProvider` is kept alive and never emits a second router, so
    // watching it here reads the same instance for the life of the app.
    return MaterialApp.router(
      title: 'Momentum',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F6B4A)),
      ),
      routerConfig: ref.watch(goRouterProvider),
    );
  }
}
