import 'package:juyo/core/error/result.dart';
import 'package:juyo/features/auth/domain/entities/auth_session.dart';
import 'package:juyo/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  const RegisterUseCase(this.repository);

  Future<Result<AuthSession>> call({
    required String phoneNumber,
    required String firstName,
    required String lastName,
    required String password,
    required String confirmPassword,
    String? referralCode,
  }) {
    return repository.register(
      phoneNumber: phoneNumber,
      firstName: firstName,
      lastName: lastName,
      password: password,
      confirmPassword: confirmPassword,
      referralCode: referralCode,
    );
  }
}
