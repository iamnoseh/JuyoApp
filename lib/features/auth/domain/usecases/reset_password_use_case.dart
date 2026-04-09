import 'package:juyo/core/error/result.dart';
import 'package:juyo/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  const ResetPasswordUseCase(this.repository);

  Future<Result<String>> call({
    required String phoneNumber,
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) {
    return repository.resetPassword(
      phoneNumber: phoneNumber,
      resetToken: resetToken,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}
