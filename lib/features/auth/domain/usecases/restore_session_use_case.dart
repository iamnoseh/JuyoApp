import 'package:juyo/core/error/result.dart';
import 'package:juyo/features/auth/domain/entities/auth_session.dart';
import 'package:juyo/features/auth/domain/repositories/auth_repository.dart';

class RestoreSessionUseCase {
  final AuthRepository repository;

  const RestoreSessionUseCase(this.repository);

  Future<Result<AuthSession>> call() {
    return repository.restoreSession();
  }
}
