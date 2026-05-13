sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);
}

final class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

final class NotFoundException extends AppException {
  const NotFoundException([super.message = 'User not found']);
}

final class AuthException extends AppException {
  const AuthException([super.message = 'Authentication failed']);
}

final class ServerException extends AppException {
  const ServerException([super.message = 'Server error, please try again']);
}

final class RateLimitException extends AppException {
  const RateLimitException([super.message = 'Too many requests, please wait']);
}
