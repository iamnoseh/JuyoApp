import 'package:dio/dio.dart';
import 'package:juyo/features/auth/data/models/auth_response_model.dart';

class AuthRemoteDataSource {
  final Dio dio;

  const AuthRemoteDataSource(this.dio);

  Future<AuthResponseModel> login({
    required String username,
    required String password,
  }) async {
    final response = await dio.post(
      '/Auth/login',
      data: {
        'username': username,
        'password': password,
      },
    );

    return AuthResponseModel.fromJson(Map<String, dynamic>.from(response.data));
  }
}
