import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../repositories/auth_repository.dart';
import 'token_service.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';

class ApiService {
  late final Dio dio;

  ApiService({
    required TokenService tokenService,
    required AuthRepository authRepository,
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: AppConstants.requestTimeout,
        receiveTimeout: AppConstants.requestTimeout,
        headers: {'Accept': 'application/json'},
      ),
    );
    dio.interceptors.addAll([
      AuthInterceptor(
        dio: dio,
        tokenService: tokenService,
        authRepository: authRepository,
      ),
      ErrorInterceptor(),
    ]);
  }
}
