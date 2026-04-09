import 'package:juyo/core/error/result.dart';
import 'package:juyo/features/auth/domain/entities/password_reset_ticket.dart';
import 'package:juyo/features/auth/domain/repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;

  const VerifyOtpUseCase(this.repository);

  Future<Result<PasswordResetTicket>> call({
    required String username,
    required String otpCode,
  }) {
    return repository.verifyOtp(
      username: username,
      otpCode: otpCode,
    );
  }
}
