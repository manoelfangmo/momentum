/// Every path in the app. Routes and `context.go` call sites read these
/// instead of repeating literals.
abstract final class AppRoutes {
  /// Shown while the restored session is still being read. The redirect sends
  /// visitors off it as soon as the current member is known.
  static const splash = '/splash';

  static const signIn = '/sign-in';
  static const signUp = '/sign-up';

  /// Create or join a group. The only screen a member without a group sees.
  static const onboarding = '/onboarding';

  /// The three branches of the signed-in shell, in navigation bar order.
  static const goals = '/goals';
  static const history = '/history';
  static const group = '/group';

  /// Pages that work without a session. The router's redirect leaves these
  /// alone for signed-out visitors.
  static const publicRoutes = <String>{signIn, signUp};
}
