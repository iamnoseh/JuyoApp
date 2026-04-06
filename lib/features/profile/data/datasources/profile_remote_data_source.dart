import 'package:dio/dio.dart';
import 'package:juyo/features/profile/data/models/profile_model.dart';
import 'package:juyo/features/profile/data/models/update_profile_request_model.dart';

class ProfileRemoteDataSource {
  final Dio dio;

  const ProfileRemoteDataSource(this.dio);

  Future<ProfileModel> getProfile() async {
    final response = await dio.get('/User/profile');
    final rawData = response.data['data'] ?? response.data;
    return ProfileModel.fromJson(Map<String, dynamic>.from(rawData as Map));
  }

  Future<void> updateProfile(UpdateProfileRequestModel request) async {
    await dio.patch(
      '/User/profile',
      data: request.toFormData(),
      options: Options(contentType: 'multipart/form-data'),
    );
  }
}
