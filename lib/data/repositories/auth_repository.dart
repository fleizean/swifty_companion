import 'dart:async';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import '../../core/constants/app_constants.dart';
import '../../core/env/env_service.dart';
import '../../core/errors/app_exception.dart';
import '../models/token_model.dart';

class AuthRepository {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: AppConstants.requestTimeout,
      receiveTimeout: AppConstants.requestTimeout,
    ),
  );

  Uri get _authorizationUrl => Uri.parse(
        'https://api.intra.42.fr/oauth/authorize',
      ).replace(
        queryParameters: {
          'client_id': EnvService.clientId,
          'redirect_uri': EnvService.redirectUri,
          'response_type': 'code',
          'scope': 'public',
        },
      );

  Future<TokenModel> login() async {
    await launchUrl(_authorizationUrl, mode: LaunchMode.externalApplication);
    final code = await _waitForAuthCode();
    return _exchangeCode(code);
  }

  Future<TokenModel> refreshToken(String token) async {
    try {
      final response = await _dio.post(
        AppConstants.oauthTokenUrl,
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': token,
          'client_id': EnvService.clientId,
          'client_secret': EnvService.clientSecret,
          'redirect_uri': EnvService.redirectUri,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return TokenModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      throw const AuthException();
    }
  }

  Future<TokenModel> _exchangeCode(String code) async {
    try {
      final response = await _dio.post(
        AppConstants.oauthTokenUrl,
        data: {
          'grant_type': 'authorization_code',
          'code': code,
          'client_id': EnvService.clientId,
          'client_secret': EnvService.clientSecret,
          'redirect_uri': EnvService.redirectUri,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return TokenModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      throw const AuthException();
    }
  }

  Future<String> _waitForAuthCode() async {
    final completer = Completer<String>();
    final subscription = AppLinks().uriLinkStream.listen((uri) {
      if (uri.scheme == 'peer42' && uri.host == 'oauth') {
        final code = uri.queryParameters['code'];
        if (code != null && !completer.isCompleted) completer.complete(code);
      }
    });
    try {
      return await completer.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () => throw const AuthException('Login timed out'),
      );
    } finally {
      await subscription.cancel();
    }
  }
}
