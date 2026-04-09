import 'package:juyo/core/utils/token_utils.dart';
import 'package:juyo/features/auth/data/models/auth_response_model.dart';
import 'package:juyo/features/auth/domain/entities/auth_session.dart';

class SessionModel extends AuthSession {
  const SessionModel({
    required super.token,
    required super.userId,
    required super.role,
    required super.isAuthenticated,
    super.expiresAt,
  });

  factory SessionModel.fromToken(String token) {
    final payload = TokenUtils.decodePayload(token);
    return SessionModel(
      token: token,
      userId: _extractUserId(payload),
      role: _extractRole(payload),
      isAuthenticated: token.isNotEmpty,
      expiresAt: _extractExpiresAt(payload),
    );
  }

  factory SessionModel.fromAuthResponse(AuthResponseModel response) {
    final payload = TokenUtils.decodePayload(response.token);
    return SessionModel(
      token: response.token,
      userId: _extractUserId(payload) ?? response.userId,
      role: _extractRole(payload) ?? response.role,
      isAuthenticated: response.token.isNotEmpty,
      expiresAt: _extractExpiresAt(payload) ?? response.expiresAt,
    );
  }

  static String? _extractRole(Map<String, dynamic>? payload) {
    if (payload == null) return null;

    final roleKeys = <String>[
      'Role',
      'role',
      'roles',
      'Roles',
      'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/role',
    ];

    for (final key in roleKeys) {
      final values = _toStringList(payload[key]);
      if (values.isNotEmpty) {
        return values.join(' ');
      }
    }

    return null;
  }

  static String? _extractUserId(Map<String, dynamic>? payload) {
    if (payload == null) return null;

    final userIdKeys = <String>[
      'UserId',
      'userId',
      'Id',
      'id',
      'sub',
      'nameid',
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier',
    ];

    for (final key in userIdKeys) {
      final value = payload[key]?.toString();
      if (value != null && value.trim().isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  static DateTime? _extractExpiresAt(Map<String, dynamic>? payload) {
    if (payload == null) return null;

    final rawExp = payload['exp'] ?? payload['Exp'] ?? payload['expiresAt'] ?? payload['ExpiresAt'];
    if (rawExp is num) {
      return DateTime.fromMillisecondsSinceEpoch(rawExp.toInt() * 1000, isUtc: true);
    }

    if (rawExp is String) {
      final parsedNumber = int.tryParse(rawExp);
      if (parsedNumber != null) {
        return DateTime.fromMillisecondsSinceEpoch(parsedNumber * 1000, isUtc: true);
      }

      return DateTime.tryParse(rawExp)?.toUtc();
    }

    return null;
  }

  static List<String> _toStringList(dynamic value) {
    if (value == null) {
      return const [];
    }

    if (value is String) {
      final normalized = value
          .replaceAll('[', ' ')
          .replaceAll(']', ' ')
          .replaceAll('"', ' ')
          .trim();
      return normalized
          .split(RegExp(r'[\s,]+'))
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }

    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }

    final asString = value.toString().trim();
    return asString.isEmpty ? const [] : [asString];
  }
}
