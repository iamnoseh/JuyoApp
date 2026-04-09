import 'package:dio/dio.dart';
import 'package:juyo/features/auth/data/models/auth_response_model.dart';
import 'package:juyo/features/auth/data/models/password_reset_ticket_model.dart';

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

  Future<AuthResponseModel> register({
    required String phoneNumber,
    required String firstName,
    required String lastName,
    required String password,
    required String confirmPassword,
    String? referralCode,
  }) async {
    final response = await dio.post(
      '/Auth/register',
      data: {
        'phoneNumber': phoneNumber,
        'firstName': firstName,
        'lastName': lastName,
        'password': password,
        'confirmPassword': confirmPassword,
        if (referralCode != null && referralCode.trim().isNotEmpty)
          'referralCode': referralCode.trim(),
      },
    );

    return AuthResponseModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<String> sendOtp({
    required String username,
  }) async {
    final response = await dio.post(
      '/Auth/send-otp',
      data: {
        'username': username,
      },
    );

    final body = Map<String, dynamic>.from(response.data);
    return body['message']?.toString() ?? '';
  }

  Future<PasswordResetTicketModel> verifyOtp({
    required String username,
    required String otpCode,
  }) async {
    final response = await dio.post(
      '/Auth/verify-otp',
      data: {
        'username': username,
        'otpCode': otpCode,
      },
    );

    return PasswordResetTicketModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<String> resetPassword({
    required String phoneNumber,
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await dio.post(
      '/Auth/reset-password',
      data: {
        'phoneNumber': phoneNumber,
        'resetToken': resetToken,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );

    final body = Map<String, dynamic>.from(response.data);
    return body['message']?.toString() ?? '';
  }
}
