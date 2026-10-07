/// What repositories throw. Supabase and Postgrest types stop at the data
/// layer; widgets only ever see one of these.
sealed class AppException implements Exception {
  const AppException();

  @override
  String toString() => runtimeType.toString();
}

final class NetworkException extends AppException {
  const NetworkException();
}

/// Sign-up, sign-in, or session failure. [message] is the text Supabase Auth
/// returned, which is written for end users.
final class AuthException extends AppException {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => 'AuthException: $message';
}

final class NotFoundException extends AppException {
  const NotFoundException();
}

final class PermissionException extends AppException {
  const PermissionException();
}

final class ValidationException extends AppException {
  const ValidationException(this.message);

  final String message;

  @override
  String toString() => 'ValidationException: $message';
}

/// A database failure with no more specific case above. [message] is for logs,
/// not for the user.
final class DatabaseException extends AppException {
  const DatabaseException(this.message);

  final String message;

  @override
  String toString() => 'DatabaseException: $message';
}
