import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:juyo/core/network/api_client.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String? get token => _prefs?.getString(_tokenKey);

  static bool get isAuthenticated => token != null && token!.isNotEmpty;

  static Future<bool> login(String username, String password) async {
    try {
      final response = await ApiClient.dio.post('/Auth/login', data: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200 && response.data['data'] != null) {
        final tokenStr = response.data['data']['token'];
        if (tokenStr != null) {
          await _prefs?.setString(_tokenKey, tokenStr);
          return true;
        }
      }
      return false;
    } on DioException {
      rethrow;
    }
  }

  static Future<void> logout() async {
    await _prefs?.remove(_tokenKey);
  }

  static Map<String, dynamic>? decodeTokenPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      String normalized = base64.normalize(payload);
      final String decoded = utf8.decode(base64.decode(normalized));
      return json.decode(decoded);
    } catch (e) {
      return null;
    }
  }
}
