import 'package:equatable/equatable.dart';

class AuthSession extends Equatable {
  final String token;
  final String? userId;
  final String? role;
  final bool isAuthenticated;
  final DateTime? expiresAt;

  const AuthSession({
    required this.token,
    required this.userId,
    required this.role,
    required this.isAuthenticated,
    this.expiresAt,
  });

  bool get isStudent {
    final raw = role;
    if (raw == null || raw.trim().isEmpty) {
      return false;
    }

    final normalized = raw
        .toLowerCase()
        .replaceAll('[', ' ')
        .replaceAll(']', ' ')
        .replaceAll('"', ' ')
        .replaceAll(',', ' ')
        .trim();

    final tokens = normalized.split(RegExp(r'\s+')).where((item) => item.isNotEmpty);
    return tokens.contains('student');
  }

  bool get isExpired {
    final expiry = expiresAt;
    if (expiry == null) {
      return false;
    }

    return DateTime.now().toUtc().isAfter(expiry.toUtc());
  }

  @override
  List<Object?> get props => [token, userId, role, isAuthenticated, expiresAt];
}
