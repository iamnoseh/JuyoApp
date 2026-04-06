import 'package:equatable/equatable.dart';

class AuthSession extends Equatable {
  final String token;
  final String? userId;
  final String? role;
  final bool isAuthenticated;

  const AuthSession({
    required this.token,
    required this.userId,
    required this.role,
    required this.isAuthenticated,
  });

  bool get isStudent => role?.toLowerCase() == 'student';

  @override
  List<Object?> get props => [token, userId, role, isAuthenticated];
}
