import 'package:juyo/core/utils/token_utils.dart';
import 'package:juyo/features/auth/domain/entities/auth_session.dart';

class SessionModel extends AuthSession {
  const SessionModel({
    required super.token,
    required super.userId,
    required super.role,
    required super.isAuthenticated,
  });

  factory SessionModel.fromToken(String token) {
    final payload = TokenUtils.decodePayload(token);
    final role =
        payload?['Role']?.toString() ??
        payload?['role']?.toString() ??
        payload?['http://schemas.microsoft.com/ws/2008/06/identity/claims/role']
            ?.toString();

    final userId = payload?['UserId']?.toString() ?? payload?['Id']?.toString();

    return SessionModel(
      token: token,
      userId: userId,
      role: role,
      isAuthenticated: token.isNotEmpty,
    );
  }
}
