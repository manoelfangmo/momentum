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

  /// The branches of the signed-in shell, in the order the shell holds them.
  /// The navigation bar orders them for itself, and only the group admin is
  /// offered [admin].
  static const goals = '/goals';
  static const history = '/history';
  static const group = '/group';
  static const admin = '/admin';

  /// Pages that work without a session. The router's redirect leaves these
  /// alone for signed-out visitors.
  static const publicRoutes = <String>{signIn, signUp};
}
