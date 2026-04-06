import 'package:dio/dio.dart';
import 'package:juyo/core/error/failure.dart';
import 'package:juyo/core/error/result.dart';
import 'package:juyo/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:juyo/features/profile/data/models/update_profile_request_model.dart';
import 'package:juyo/features/profile/domain/entities/profile.dart';
import 'package:juyo/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  const ProfileRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Result<Profile>> getProfile() async {
    try {
      final profile = await remoteDataSource.getProfile();
      return Success<Profile>(profile);
    } on DioException catch (error) {
      final response = error.response?.data;
      final message = response is Map<String, dynamic> && response['message'] is String
          ? response['message'] as String
          : 'Failed to load profile';

      if (error.response?.statusCode == 401) {
        return Error<Profile>(UnauthorizedFailure(message));
      }

      return Error<Profile>(NetworkFailure(message));
    } catch (_) {
      return const Error<Profile>(NetworkFailure('Failed to load profile'));
    }
  }

  @override
  Future<Result<Profile>> updateProfile(UpdateProfileRequestModel request) async {
    try {
      await remoteDataSource.updateProfile(request);
      final profile = await remoteDataSource.getProfile();
      return Success<Profile>(profile);
    } on DioException catch (error) {
      final response = error.response?.data;
      final message = response is Map<String, dynamic> && response['message'] is String
          ? response['message'] as String
          : 'Failed to update profile';

      if (error.response?.statusCode == 401) {
        return Error<Profile>(UnauthorizedFailure(message));
      }

      if (error.response?.statusCode == 400 || error.response?.statusCode == 422) {
        return Error<Profile>(ValidationFailure(message));
      }

      return Error<Profile>(NetworkFailure(message));
    } catch (_) {
      return const Error<Profile>(NetworkFailure('Failed to update profile'));
    }
  }
}
