import 'package:dio/dio.dart';
import '../../models/token_model.dart';
import '../../repositories/auth_repository.dart';
import '../token_service.dart';
import '../../../core/errors/app_exception.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final TokenService _tokenService;
  final AuthRepository _authRepository;

  bool _isRefreshing = false;
  final _pendingRequests =
      <({RequestOptions options, ErrorInterceptorHandler handler})>[];

  AuthInterceptor({
    required Dio dio,
    required TokenService tokenService,
    required AuthRepository authRepository,
  })  : _dio = dio,
        _tokenService = tokenService,
        _authRepository = authRepository;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _getValidToken();
    options.headers['Authorization'] = 'Bearer ${token.accessToken}';
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      _pendingRequests.add((options: err.requestOptions, handler: handler));
      if (!_isRefreshing) await _refreshAndRetry();
      return;
    }
    handler.next(err);
  }

  Future<TokenModel> _getValidToken() async {
    final stored = await _tokenService.getToken();
    if (stored != null && !stored.isExpired) return stored;
    if (stored?.canRefresh != true) throw const AuthException();

    final fresh = await _authRepository.refreshToken(stored!.refreshToken!);
    await _tokenService.saveToken(fresh);
    return fresh;
  }

  Future<void> _refreshAndRetry() async {
    _isRefreshing = true;
    try {
      final stored = await _tokenService.getToken();
      if (stored?.canRefresh != true) throw const AuthException();

      final token = await _authRepository.refreshToken(stored!.refreshToken!);
      await _tokenService.saveToken(token);
      for (final req in _pendingRequests) {
        req.options.headers['Authorization'] = 'Bearer ${token.accessToken}';
        req.handler.resolve(await _dio.fetch(req.options));
      }
    } catch (_) {
      for (final req in _pendingRequests) {
        req.handler.reject(
          DioException(
            requestOptions: req.options,
            error: const AuthException(),
          ),
        );
      }
    } finally {
      _pendingRequests.clear();
      _isRefreshing = false;
    }
  }
}
