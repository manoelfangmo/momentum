import 'package:app/core/routing/app_routes.dart';
import 'package:app/features/auth/presentation/sign_in_page.dart';
import 'package:app/features/auth/presentation/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// There is no redirect yet, so the app opens on sign-in and stays wherever
/// you navigate. The signed-in shell and the session redirect come next.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.signIn,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('Momentum'))),
    ),
    GoRoute(
      path: AppRoutes.signIn,
      builder: (context, state) => const SignInPage(),
    ),
    GoRoute(
      path: AppRoutes.signUp,
      builder: (context, state) => const SignUpPage(),
    ),
  ],
);
