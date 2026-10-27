import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Central application configuration loaded from .env or environment definitions.
class AppConfig {
  static const String _defaultBaseUrl =
      'https://replace-with-your-mockapi-id.mockapi.io/api/v1';

  /// Initialize application configuration, loading .env if available.
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // If .env is not found or fails to load, fallback to environment or defaults
    }
  }

  /// Get the configured API base URL.
  /// Priority:
  /// 1. `--dart-define=API_BASE_URL=...`
  /// 2. `.env` file `API_BASE_URL`
  /// 3. Default fallback URL
  static String get apiBaseUrl {
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    if (fromDefine.isNotEmpty) {
      return _sanitizeUrl(fromDefine);
    }

    final fromEnv = dotenv.env['API_BASE_URL'];
    if (fromEnv != null && fromEnv.trim().isNotEmpty) {
      return _sanitizeUrl(fromEnv.trim());
    }

    return _defaultBaseUrl;
  }

  /// Ensure URL has no trailing slashes
  static String _sanitizeUrl(String url) {
    var sanitized = url.trim();
    while (sanitized.endsWith('/')) {
      sanitized = sanitized.substring(0, sanitized.length - 1);
    }
    return sanitized;
  }

  /// Check if the current API base URL is a placeholder that requires user configuration.
  static bool get isPlaceholderUrl {
    final url = apiBaseUrl.toLowerCase();
    return url.contains('replace-with-your') || url.contains('660000000000000000000000');
  }
}
