import 'dart:convert';

class TokenUtils {
  static Map<String, dynamic>? decodePayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final normalized = base64.normalize(parts[1]);
      final decoded = utf8.decode(base64.decode(normalized));
      final json = jsonDecode(decoded);

      return json is Map<String, dynamic> ? json : null;
    } catch (_) {
      return null;
    }
  }
}
