import 'package:juyo/core/error/result.dart';
import 'package:juyo/features/auth/domain/entities/auth_session.dart';
import 'package:juyo/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  Future<Result<AuthSession>> call({
    required String username,
    required String password,
  }) {
    return repository.login(username: username, password: password);
  }
}
