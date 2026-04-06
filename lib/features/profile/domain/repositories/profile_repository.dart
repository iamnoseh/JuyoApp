import 'package:juyo/core/error/result.dart';
import 'package:juyo/features/profile/data/models/update_profile_request_model.dart';
import 'package:juyo/features/profile/domain/entities/profile.dart';

abstract class ProfileRepository {
  Future<Result<Profile>> getProfile();
  Future<Result<Profile>> updateProfile(UpdateProfileRequestModel request);
}
