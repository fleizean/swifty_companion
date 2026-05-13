class AppConstants {
  static const String apiBaseUrl = 'https://api.intra.42.fr/v2';
  static const String oauthTokenUrl = 'https://api.intra.42.fr/oauth/token';

  static const Duration requestTimeout = Duration(seconds: 15);
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration requestDelay = Duration(milliseconds: 600);

  static const int searchPageSize = 5;
}
