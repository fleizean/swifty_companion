import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/token_model.dart';

class TokenService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _keyPrefix = 'peer42_token_';
  static const _userLoginKey = 'peer42_user_login';

  Future<TokenModel?> getToken() async {
    final accessToken = await _storage.read(key: '${_keyPrefix}access_token');
    if (accessToken == null) return null;

    final expiresIn = await _storage.read(key: '${_keyPrefix}expires_in');
    final createdAt = await _storage.read(key: '${_keyPrefix}created_at');
    if (expiresIn == null || createdAt == null) return null;

    final refreshToken = await _storage.read(key: '${_keyPrefix}refresh_token');

    return TokenModel.fromStorage({
      'access_token': accessToken,
      'refresh_token': ?refreshToken,
      'expires_in': expiresIn,
      'created_at': createdAt,
    });
  }

  Future<void> saveToken(TokenModel token) async {
    final entries = token.toStorage();
    for (final entry in entries.entries) {
      await _storage.write(key: '$_keyPrefix${entry.key}', value: entry.value);
    }
  }

  Future<void> saveUserLogin(String login) async {
    await _storage.write(key: _userLoginKey, value: login);
  }

  Future<String?> getUserLogin() async {
    return _storage.read(key: _userLoginKey);
  }

  Future<void> clearToken() async {
    await _storage.deleteAll();
  }
}
