/// Every path in the app. Routes and `context.go` call sites read these
/// instead of repeating literals.
abstract final class AppRoutes {
  static const home = '/';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';

  /// Pages that work without a session. The router's redirect leaves these
  /// alone for signed-out visitors.
  static const publicRoutes = <String>{signIn, signUp};
}
