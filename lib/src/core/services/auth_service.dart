import 'package:shared_preferences/shared_preferences.dart';
import 'oauth2_service.dart';
import 'api_service.dart';
import '../models/user_model.dart';

class AuthService {
  final OAuth2Service _oauth2Service = OAuth2Service();
  final ApiService _apiService = ApiService();
  
  // Singleton instance
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();
  
  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _oauth2Service.isAuthenticated();
  }
  
  /// Get current authenticated user
  Future<UserModel?> getCurrentUser() async {
    try {
      if (await isAuthenticated()) {
        return await _apiService.getCurrentUser();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Validate credentials (for backward compatibility)
  Future<bool> validateCredentials(String clientId, String clientSecret) async {
    // Bu metod artık kullanılmıyor çünkü credentials hard-coded
    // Ancak eski kod uyumluluğu için bırakıyoruz
    return clientId.isNotEmpty && clientSecret.isNotEmpty;
  }
  
  /// Clear authentication data
  Future<void> clearAuth() async {
    await _oauth2Service.logout();
  }
  
  /// Logout user
  Future<void> logout() async {
    await _oauth2Service.logout();
  }
  
  /// Check if token is valid
  Future<bool> validateToken() async {
    return await _oauth2Service.validateToken();
  }
  
  /// Refresh authentication if needed
  Future<bool> refreshAuthIfNeeded() async {
    try {
      final token = await _oauth2Service.getAccessToken();
      return token != null;
    } catch (e) {
      return false;
    }
  }
  
  /// Get access token
  Future<String?> getAccessToken() async {
    return await _oauth2Service.getAccessToken();
  }
}