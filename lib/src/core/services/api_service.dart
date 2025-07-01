import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:peer42/src/core/models/coalition_user_model.dart';
import '../models/user_model.dart';
import '../models/coalition_model.dart';
import '../models/project_model.dart';
import 'oauth2_service.dart';

class ApiService {
  static const String _baseUrl = 'https://api.intra.42.fr/v2';
  final OAuth2Service _oauth2Service = OAuth2Service();
  
  // Singleton instance
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  
  /// Get authenticated headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _oauth2Service.getAccessToken();
    if (token == null) {
      throw Exception('No access token available');
    }
    
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<dynamic> _get(String endpoint) async {
    var token = await _oauth2Service.getAccessToken();
    
    var response = await http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    // If unauthorized, refresh token and retry
    if (response.statusCode == 401) {
      await _oauth2Service.logout();
        throw Exception('Authentication expired. Please login again.');
    }
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  /// Get user achievements
  Future<List<Map<String, dynamic>>> getUserAchievements(String login) async {
  try {
    // Get user data which includes achievements
    final userData = await _get('/users/$login');
    
    final achievements = userData['achievements'] as List? ?? [];
    
    // Eğer achievements boşsa diğer field'ları kontrol et
    if (achievements.isEmpty) {

      
      // Titles_users kontrol et  
      if (userData['titles_users'] != null) {
        final titlesUsers = userData['titles_users'] as List? ?? [];
        
        // Titles_users'ı achievements olarak kullan
        if (titlesUsers.isNotEmpty) {
          return titlesUsers.map((title) => {
            'name': title['title']?['name'] ?? title['name'] ?? 'Unknown Achievement',
            'description': title['title']?['description'] ?? 'Achievement unlocked',
            'kind': 'title',
            'tier': 'normal',
            'image': title['title']?['image'] ?? '',
          }).toList();
        }
      }
    }
    
    return achievements.map((achievement) => {
      'name': achievement['name'] ?? '',
      'description': achievement['description'] ?? '',
      'kind': achievement['kind'] ?? '',
      'tier': achievement['tier'] ?? '',
      'image': achievement['image'] ?? '',
    }).toList();
  } catch (e) {
    throw Exception('Failed to get user achievements: $e');
  }
}
  
  /// Search users by login or name
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final headers = await _getHeaders();
      final encodedQuery = Uri.encodeComponent(query);
      
      final response = await http.get(
        Uri.parse('$_baseUrl/users?search[login]=$encodedQuery&per_page=20'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => UserModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        // Token expired, try to refresh
        await _oauth2Service.logout();
        throw Exception('Authentication expired. Please login again.');
      } else {
        throw Exception('Failed to search users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }
  
  /// Get current user information
  Future<UserModel> getCurrentUser() async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/me'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return UserModel.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        await _oauth2Service.logout();
        throw Exception('Authentication expired. Please login again.');
      } else {
        throw Exception('Failed to get user info: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }
  
  /// Get user by ID
  Future<UserModel> getUser(int userId) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return UserModel.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        await _oauth2Service.logout();
        throw Exception('Authentication expired. Please login again.');
      } else {
        throw Exception('Failed to get user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Future<UserModel> getUserDetails(String login) async {
    try {
      print('🔍 DEBUG: Getting user details for: $login');
      // Direkt API çağrısı yap, searchUsers kullanma
      final data = await _get('/users/$login');
      print('🔍 DEBUG: getUserDetails - Raw data type: ${data.runtimeType}');
      
      if (data is Map<String, dynamic>) {
        return UserModel.fromJson(data);
      } else {
        throw Exception('Unexpected data type: ${data.runtimeType}');
      }
    } catch (e) {
      print('🔍 DEBUG: Error in getUserDetails: $e');
      throw Exception('Failed to get user details: $e');
    }
  }

  
  /// Get user's coalition information
  Future<CoalitionModel?> getUserCoalition(String userId) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId/coalitions'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        if (jsonData.isNotEmpty) {
          return CoalitionModel.fromJson(jsonData.first);
        }
        return null;
      } else if (response.statusCode == 401) {
        await _oauth2Service.logout();
        throw Exception('Authentication expired. Please login again.');
      } else {
        throw Exception('Failed to get coalition: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get coalition: $e');
    }
  }

   /// Get user's coalition user data (score and rank)
  Future<CoalitionUserModel?> getUserCoalitionUser(String login) async {
    try {
      final data = await _get('/users/$login/coalitions_users');
      if (data is List && data.isNotEmpty) {
        // Find the coalition user data that matches the active coalition
        // Typically this is the one with the highest score or most recent
        final sortedData = List<Map<String, dynamic>>.from(data)
          ..sort((a, b) {
            final scoreA = (a['score'] as num?)?.toInt() ?? 0;
            final scoreB = (b['score'] as num?)?.toInt() ?? 0;
            return scoreB.compareTo(scoreA);
          });
        
        return CoalitionUserModel.fromJson(sortedData.first);
      } else if (data is Map<String, dynamic>) {
        // In case the API returns a single object
        return CoalitionUserModel.fromJson(data);
      }
      return null;
    } catch (e) {
      //print('Error getting coalition user data: $e');
      return null;
    }
  }
  
  /// Get user's projects
  Future<List<ProjectModel>> getUserProjects(String userId) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId/projects_users'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => ProjectModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        await _oauth2Service.logout();
        throw Exception('Authentication expired. Please login again.');
      } else {
        throw Exception('Failed to get projects: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get projects: $e');
    }
  }
  
  /// Get user's skills
  Future<Map<String, dynamic>> getUserSkills(String userId) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId/skills'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return {'skills': jsonData};
      } else if (response.statusCode == 401) {
        await _oauth2Service.logout();
        throw Exception('Authentication expired. Please login again.');
      } else {
        throw Exception('Failed to get skills: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get skills: $e');
    }
  }
  
  /// Validate API connection
  Future<bool> validateConnection() async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/me'),
        headers: headers,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<CoalitionUserModel?>> getAllCoalitions() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/coalitions'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => CoalitionUserModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        await _oauth2Service.logout();
        throw Exception('Authentication expired. Please login again.');
      } else {
        throw Exception('Failed to get coalitions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get coalitions: $e');
    }
  }
}