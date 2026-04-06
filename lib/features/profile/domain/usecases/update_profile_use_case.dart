import 'package:juyo/core/error/result.dart';
import 'package:juyo/features/profile/data/models/update_profile_request_model.dart';
import 'package:juyo/features/profile/domain/entities/profile.dart';
import 'package:juyo/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  const UpdateProfileUseCase(this.repository);

  Future<Result<Profile>> call(UpdateProfileRequestModel request) {
    return repository.updateProfile(request);
  }
}
