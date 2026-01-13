import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get environment => _getRequired('ENVIRONMENT');

  static String get baseUrl => _getRequired('API_BASE_URL');

  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';

  static int get maxLoginAttempts =>
      int.parse(_getRequired('MAX_LOGIN_ATTEMPTS'));
  static Duration get sessionTimeout =>
      Duration(hours: int.parse(_getRequired('SESSION_TIMEOUT_HOURS')));

  static bool get enableDebugLogging =>
      _getRequired('ENABLE_DEBUG_LOGGING').toLowerCase() == 'true';
  static bool get enableOfflineMode =>
      _getRequired('ENABLE_OFFLINE_MODE').toLowerCase() == 'true';

  static int get syncDebounceSeconds =>
      int.parse(_getRequired('SYNC_DEBOUNCE_SECONDS'));

  static String _getRequired(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw Exception('Missing required environment variable: $key');
    }
    return value;
  }
}
