import 'package:juyo/core/error/result.dart';
import 'package:juyo/features/profile/domain/entities/profile.dart';
import 'package:juyo/features/profile/domain/repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  const GetProfileUseCase(this.repository);

  Future<Result<Profile>> call() {
    return repository.getProfile();
  }
}
