import 'package:juyo/core/error/result.dart';
import 'package:juyo/features/auth/domain/repositories/auth_repository.dart';

class SendOtpUseCase {
  final AuthRepository repository;

  const SendOtpUseCase(this.repository);

  Future<Result<String>> call({
    required String username,
  }) {
    return repository.sendOtp(username: username);
  }
}
