sealed class AppException implements Exception {
  const AppException();

  @override
  String toString() => runtimeType.toString();
}

final class NetworkException extends AppException {
  const NetworkException();
}

final class AuthException extends AppException {
  const AuthException();
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
