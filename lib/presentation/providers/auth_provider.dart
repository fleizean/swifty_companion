import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/token_service.dart';

enum AuthState { unknown, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final TokenService _tokenService;
  final AuthRepository _authRepository;

  AuthState _state = AuthState.unknown;
  AppException? _error;
  String? _userLogin;

  AuthState get state => _state;
  AppException? get error => _error;
  String? get userLogin => _userLogin;

  AuthProvider({
    required TokenService tokenService,
    required AuthRepository authRepository,
  })  : _tokenService = tokenService,
        _authRepository = authRepository {
    _checkStoredToken();
  }

  Future<void> _checkStoredToken() async {
    // Show splash for at least 5 seconds so the user sees the design
    final splashDelay = Future.delayed(const Duration(seconds: 5));

    final token = await _tokenService.getToken();
    if (token != null && !token.isExpired) {
      // Token still valid — proceed directly
      _state = AuthState.authenticated;
      _userLogin = await _tokenService.getUserLogin();
    } else if (token != null && token.canRefresh) {
      // Token expired but refresh token available — silently refresh
      try {
        final fresh = await _authRepository.refreshToken(token.refreshToken!);
        await _tokenService.saveToken(fresh);
        _state = AuthState.authenticated;
        _userLogin = await _tokenService.getUserLogin();
      } catch (_) {
        // Refresh failed (e.g. revoked) — require re-login
        await _tokenService.clearToken();
        _state = AuthState.unauthenticated;
      }
    } else {
      _state = AuthState.unauthenticated;
    }

    // Wait for splash delay to complete before notifying
    await splashDelay;
    notifyListeners();
  }

  Future<void> login() async {
    _state = AuthState.loading;
    _error = null;
    notifyListeners();
    try {
      final token = await _authRepository.login();
      await _tokenService.saveToken(token);
      // Fetch current user's login via /v2/me
      await _fetchCurrentUser(token.accessToken);
      _state = AuthState.authenticated;
    } on AppException catch (e) {
      _error = e;
      _state = AuthState.error;
    }
    notifyListeners();
  }

  Future<void> _fetchCurrentUser(String accessToken) async {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      ));
      final response = await dio.get('/me');
      final login = response.data['login'] as String?;
      if (login != null) {
        _userLogin = login;
        await _tokenService.saveUserLogin(login);
      }
    } catch (_) {
      // Non-critical — profile tab just won't navigate
    }
  }

  Future<void> logout() async {
    await _tokenService.clearToken();
    _state = AuthState.unauthenticated;
    _userLogin = null;
    _error = null;
    notifyListeners();
  }
}
