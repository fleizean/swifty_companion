import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvService {
  static String get clientId => dotenv.env['CLIENT_ID'] ?? '';
  static String get clientSecret => dotenv.env['CLIENT_SECRET'] ?? '';
  static String get redirectUri => dotenv.env['REDIRECT_URI'] ?? 'peer42://oauth/callback';

  static bool get isConfigured => clientId.isNotEmpty && clientSecret.isNotEmpty;
}
