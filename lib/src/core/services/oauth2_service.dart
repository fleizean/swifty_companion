// lib/src/core/services/oauth2_service.dart - SCOPE FIX

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:app_links/app_links.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OAuth2Service {
  static const String _baseUrl = 'https://api.intra.42.fr';
  
  final AppLinks _appLinks = AppLinks();
  String? _currentState;
  
  // DotEnv'den credentials al
  String get _clientId => dotenv.env['CLIENT_ID'] ?? '';
  String get _clientSecret => dotenv.env['CLIENT_SECRET'] ?? '';
  String get _redirectUri => dotenv.env['REDIRECT_URI'] ?? 'peer42://oauth/callback';
  
  // Random state oluştur
  String _generateState() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(32, (index) => chars[random.nextInt(chars.length)]).join();
  }
  
  // OAuth2 authorization URL'ini oluştur - SCOPE EKLENDİ
  String buildAuthorizationUrl() {
    _currentState = _generateState();
    
    final params = {
      'client_id': _clientId,
      'redirect_uri': _redirectUri,
      'response_type': 'code',
      'state': _currentState!,
      'scope': 'public projects forum profile elearning', // ← SCOPE EKLENDİ!
    };
    
    final uri = Uri.parse('$_baseUrl/oauth/authorize');
    return uri.replace(queryParameters: params).toString();
  }
  
  // Deep link callback'ini dinle
  Stream<Uri> get callbackStream => _appLinks.uriLinkStream;
  
  // Authorization code ile access token al - SCOPE EKLENDİ
  Future<Map<String, dynamic>> exchangeCodeForToken({
    required String code,
    String? state,
  }) async {
    // State kontrolü
    if (state != null && _currentState != null && state != _currentState) {
      throw Exception('Invalid state parameter. Possible CSRF attack.');
    }
    
    final response = await http.post(
      Uri.parse('$_baseUrl/oauth/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'client_id': _clientId,
        'client_secret': _clientSecret,
        'code': code,
        'redirect_uri': _redirectUri,
        'scope': 'public projects forum profile elearning', // ← SCOPE EKLENDİ!
      },
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to exchange code for token: ${response.body}');
    }
    
    final tokenData = json.decode(response.body);
    
    // Token'ları güvenli şekilde sakla
    await _storeTokens(tokenData);
    
    // State'i temizle
    _currentState = null;
    
    return tokenData;
  }
  
  // Token'ları secure storage'a kaydet
  Future<void> _storeTokens(Map<String, dynamic> tokenData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', tokenData['access_token']);
    if (tokenData['refresh_token'] != null) {
      await prefs.setString('refresh_token', tokenData['refresh_token']);
    }
    
    final expiresIn = tokenData['expires_in'] as int;
    final expiryTime = DateTime.now().add(Duration(seconds: expiresIn));
    await prefs.setString('token_expiry', expiryTime.toIso8601String());
  }
  
  // Stored access token'ı al
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final expiryString = prefs.getString('token_expiry');
    
    if (token == null || expiryString == null) return null;
    
    final expiry = DateTime.parse(expiryString);
    if (DateTime.now().isAfter(expiry)) {
      // Token süresi dolmuş, refresh et
      return await refreshToken();
    }
    
    return token;
  }
  
  // Refresh token ile yeni access token al - SCOPE EKLENDİ
  Future<String?> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');
    
    if (refreshToken == null) {
      return null;
    }
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/oauth/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': _clientId,
          'client_secret': _clientSecret,
          'scope': 'public projects forum profile elearning', // ← SCOPE EKLENDİ!
        },
      );
      
      if (response.statusCode == 200) {
        final tokenData = json.decode(response.body);
        await _storeTokens(tokenData);
        return tokenData['access_token'];
      }
    } catch (e) {
      // Error handling
    }
    
    return null;
  }
  
  // Logout - token'ları temizle
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('token_expiry');
    _currentState = null;
  }
  
  // Credentials var mı kontrol et
  bool hasCredentials() {
    return _clientId.isNotEmpty && _clientSecret.isNotEmpty;
  }
  
  // Kullanıcı authenticate olmuş mu kontrol et
  Future<bool> isAuthenticated() async {
    try {
      final token = await getAccessToken();
      return token != null;
    } catch (e) {
      return false;
    }
  }
  
  // Token'ı doğrula (42 API ile)
  Future<bool> validateToken() async {
    try {
      final token = await getAccessToken();
      if (token == null) return false;
      
      final response = await http.get(
        Uri.parse('$_baseUrl/v2/me'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  // Current token'ın scope'larını kontrol et
  Future<List<String>> getCurrentScopes() async {
    try {
      final token = await getAccessToken();
      if (token == null) return [];
      
      final response = await http.get(
        Uri.parse('$_baseUrl/oauth/token/info'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final scopes = data['scope'] as String? ?? '';
        return scopes.split(' ').where((s) => s.isNotEmpty).toList();
      }
    } catch (e) {
      print('Error getting scopes: $e');
    }
    
    return [];
  }
  
  // Projects scope'u var mı kontrol et
  Future<bool> hasProjectsScope() async {
    final scopes = await getCurrentScopes();
    return scopes.contains('projects');
  }
}