import 'package:dio/dio.dart';
import '../../../core/errors/app_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.connectionError =>
        const NetworkException(),
      DioExceptionType.badResponse => _fromStatusCode(err.response?.statusCode),
      _ => const NetworkException(),
    };
    handler.reject(err.copyWith(error: exception));
  }

  AppException _fromStatusCode(int? code) => switch (code) {
        404 => const NotFoundException(),
        401 => const AuthException(),
        429 => const RateLimitException(),
        _ => const ServerException(),
      };
}
