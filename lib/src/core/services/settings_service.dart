import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  // Keys for shared preferences
  static const String _isConfiguredKey = 'is_configured';
  static const String _lastConfiguredAtKey = 'last_configured_at';
  // _performanceModeKey kaldırıldı
  
  // Singleton instance
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();
  
  /// Check if app is configured
  Future<bool> isConfigured() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isConfiguredKey) ?? false;
    } catch (e) {
      return false;
    }
  }
  
  /// Mark app as configured
  Future<void> setConfigured(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isConfiguredKey, value);
      if (value) {
        await prefs.setString(_lastConfiguredAtKey, DateTime.now().toIso8601String());
      }
    } catch (e) {
      throw Exception('Failed to set configuration status: $e');
    }
  }
  
  /// Get last configured date
  Future<DateTime?> getLastConfiguredDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateString = prefs.getString(_lastConfiguredAtKey);
      if (dateString != null) {
        return DateTime.parse(dateString);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Clear all settings
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      throw Exception('Failed to clear settings: $e');
    }
  }
  
  /// Reset to default settings
  Future<void> resetToDefaults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isConfiguredKey, false);
      await prefs.remove(_lastConfiguredAtKey);
      // performanceMode ile ilgili satır kaldırıldı
    } catch (e) {
      throw Exception('Failed to reset settings: $e');
    }
  }
}