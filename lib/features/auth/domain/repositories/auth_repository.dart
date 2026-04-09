import 'package:juyo/core/error/result.dart';
import 'package:juyo/features/auth/domain/entities/auth_session.dart';
import 'package:juyo/features/auth/domain/entities/password_reset_ticket.dart';

abstract class AuthRepository {
  Future<Result<AuthSession>> restoreSession();
  Future<Result<AuthSession>> login({
    required String username,
    required String password,
  });
  Future<Result<AuthSession>> register({
    required String phoneNumber,
    required String firstName,
    required String lastName,
    required String password,
    required String confirmPassword,
    String? referralCode,
  });
  Future<Result<String>> sendOtp({
    required String username,
  });
  Future<Result<PasswordResetTicket>> verifyOtp({
    required String username,
    required String otpCode,
  });
  Future<Result<String>> resetPassword({
    required String phoneNumber,
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  });
  Future<void> logout();
}
