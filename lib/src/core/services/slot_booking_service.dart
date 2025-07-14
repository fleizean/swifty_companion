// lib/src/core/services/evaluation_slot_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:peer42/src/core/services/api_service.dart';
import 'oauth2_service.dart';

class EvaluationSlotService {
  static const String _baseUrl = 'https://api.intra.42.fr/v2';
  final ApiService apiService = ApiService();
  final OAuth2Service _oauth2Service = OAuth2Service();

  // Singleton instance
  static final EvaluationSlotService _instance =
      EvaluationSlotService._internal();
  factory EvaluationSlotService() => _instance;
  EvaluationSlotService._internal();

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
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
    );

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

  Future<int> getCurrentUserId() async {
    try {
      // ApiService'den mevcut kullanıcıyı al
      final currentUser = await apiService.getCurrentUser();
      
      // Kullanıcı ID'sini döndür
      return currentUser.id;
    } catch (e) {
      throw Exception('Failed to get current user ID: $e');
    }
  }

  Future<dynamic> _post(String endpoint, {Map<String, dynamic>? data}) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
      body: data != null ? json.encode(data) : null,
    );

    if (response.statusCode == 401) {
      await _oauth2Service.logout();
      throw Exception('Authentication expired. Please login again.');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to create slot: ${response.statusCode} - ${response.body}');
    }
  }

// Query parametreli POST için özel metod
  Future<dynamic> _postWithQuery(String endpoint) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
    );

    if (response.statusCode == 401) {
      await _oauth2Service.logout();
      throw Exception('Authentication expired. Please login again.');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to create slot: ${response.statusCode} - ${response.body}');
    }
  }

  Future<dynamic> _delete(String endpoint) async {
    final headers = await _getHeaders();

    final response = await http.delete(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
    );

    if (response.statusCode == 401) {
      await _oauth2Service.logout();
      throw Exception('Authentication expired. Please login again.');
    }

    if (response.statusCode == 204 || response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete slot: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> createEvaluationSlot({
  required DateTime beginAt,
  required DateTime endAt,
  int? scaleTeamId, // Optional - defense linked to this slot
}) async {
  try {
    // Validate minimum duration (30 minutes)
    final duration = endAt.difference(beginAt);
    if (duration.inSeconds < 1800) {
      throw Exception('Slot duration must be at least 30 minutes');
    }

    // Validate that slot is not in the past
    final now = DateTime.now();
    if (beginAt.isBefore(now.add(Duration(minutes: 30)))) {
      throw Exception('Slot must be at least 30 minutes in the future');
    }

    // Validate that slot is not more than 2 weeks in advance
    if (beginAt.isAfter(now.add(Duration(days: 14)))) {
      throw Exception('Slot cannot be more than 2 weeks in advance');
    }

    // MUTLAKA kullanıcı ID'sini al
    final userId = await getCurrentUserId();

    // JSON body ile slot hash parametresi kullan - dokümantasyona uygun
    final data = {
      'slot': {
        'user_id': userId, // REQUIRED - await ile al
        'begin_at': beginAt.toUtc().toIso8601String(),
        'end_at': endAt.toUtc().toIso8601String(),
      }
    };
    
    // Scale team ID varsa ekle
    if (scaleTeamId != null) {
      (data['slot'] as Map<String, dynamic>)['scale_team_id'] = scaleTeamId;
    }

    print('Creating evaluation slot with data: $data');
    print('Url: $_baseUrl/slots');
    
    // POST request with JSON body
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/slots'),
      headers: headers,
      body: json.encode(data),
    );
    
    if (response.statusCode == 401) {
      await _oauth2Service.logout();
      throw Exception('Authentication expired. Please login again.');
    }
    
    if (response.statusCode == 403) {
      throw Exception('Access denied. This operation requires Advanced tutor role or appropriate project scope.');
    }
    
    if (response.statusCode == 404) {
      throw Exception('Endpoint not found. Check if your app has the required permissions or resource owner scope.');
    }
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = json.decode(response.body);
      
      // API response format'ına göre düzenle
      if (responseData is List && responseData.isNotEmpty) {
        return Map<String, dynamic>.from(responseData.first);
      } else if (responseData is Map) {
        return Map<String, dynamic>.from(responseData);
      }
      
      return responseData;
    } else {
      throw Exception('Failed to create slot: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    throw Exception('Failed to create evaluation slot: $e');
  }
}


  /// Get user's own slots
  Future<List<Map<String, dynamic>>> getUserSlots() async {
    try {
      final response = await _get('/me/slots');

      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get user slots: $e');
    }
  }

  /// Get all available slots for the current user to view
  Future<List<Map<String, dynamic>>> getAvailableSlots({
    String? startDate,
    String? endDate,
    int? page,
    int? pageSize,
  }) async {
    try {
      String endpoint = '/slots';

      // Add query parameters
      List<String> queryParams = [];
      if (startDate != null) queryParams.add('filter[begin_at]=$startDate');
      if (endDate != null) queryParams.add('filter[end_at]=$endDate');
      if (page != null) queryParams.add('page[number]=$page');
      if (pageSize != null) queryParams.add('page[size]=$pageSize');

      if (queryParams.isNotEmpty) {
        endpoint += '?${queryParams.join('&')}';
      }

      final response = await _get(endpoint);

      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get available slots: $e');
    }
  }

  /// Get slots for a specific project
  Future<List<Map<String, dynamic>>> getProjectSlots(int projectId) async {
    try {
      final response = await _get('/projects/$projectId/slots');

      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get project slots: $e');
    }
  }

  /// Delete a slot
  Future<bool> deleteSlot(int slotId) async {
    try {
      await _delete('/slots/$slotId');
      return true;
    } catch (e) {
      throw Exception('Failed to delete slot: $e');
    }
  }

  /// Get current user's scale teams (evaluations)
  Future<List<Map<String, dynamic>>> getUserEvaluations() async {
    try {
      final response = await _get('/me/scale_teams');

      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get user evaluations: $e');
    }
  }

  /// Helper method to round time to nearest 15 minutes
  DateTime roundToNearest15Minutes(DateTime dateTime) {
    final minutes = dateTime.minute;
    final roundedMinutes = ((minutes / 15).round() * 15) % 60;
    final hourAdjustment = minutes >= 45 && roundedMinutes == 0 ? 1 : 0;

    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour + hourAdjustment,
      roundedMinutes,
      0,
      0,
    );
  }

  /// Helper method to format datetime for API
  String formatDateTimeForApi(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String();
  }

  /// Validate slot duration and timing
  String? validateSlotTiming(DateTime beginAt, DateTime endAt) {
    final now = DateTime.now();
    final duration = endAt.difference(beginAt);

    // Check minimum duration (30 minutes)
    if (duration.inSeconds < 1800) {
      return 'Slot must be at least 30 minutes long';
    }

    // Check that slot is in the future
    if (beginAt.isBefore(now.add(Duration(minutes: 30)))) {
      return 'Slot must be at least 30 minutes in the future';
    }

    // Check maximum advance booking (2 weeks)
    if (beginAt.isAfter(now.add(Duration(days: 14)))) {
      return 'Slot cannot be more than 2 weeks in advance';
    }

    // Check that end time is after begin time
    if (endAt.isBefore(beginAt)) {
      return 'End time must be after begin time';
    }

    return null; // No validation errors
  }
}
