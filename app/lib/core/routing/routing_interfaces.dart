/// Base classes for routes that are not a navigation bar destination.
///
/// A page reached with arguments gets a class in its feature's
/// `presentation/routes.dart` rather than an inline `GoRoute`, so the path
/// template and the code that fills it in cannot drift apart.
library;

/// A route with nothing to fill in.
abstract class SimpleAppRoute {
  const SimpleAppRoute();

  /// The template registered with go_router.
  String get path;

  /// Where to send `context.go`.
  String location() => path;
}

/// A route with path parameters, for example `/goals/:goalId`.
///
/// [A] is whatever the caller has to supply: one id, or a record for several.
abstract class ParamAppRoute<A> {
  const ParamAppRoute();

  /// The template registered with go_router, parameters included.
  String get path;

  /// [path] with [args] substituted. Where to send `context.go`.
  String location(A args);
}
