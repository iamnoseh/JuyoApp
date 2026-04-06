import 'package:juyo/core/error/result.dart';
import 'package:juyo/features/auth/domain/entities/auth_session.dart';

abstract class AuthRepository {
  Future<Result<AuthSession>> restoreSession();
  Future<Result<AuthSession>> login({
    required String username,
    required String password,
  });
  Future<void> logout();
}
