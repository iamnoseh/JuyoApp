import 'package:dio/dio.dart';
import 'package:juyo/core/network/api_client.dart';
import 'package:juyo/core/models/user_model.dart';

class UserService {
  static Future<UserModel?> fetchProfile() async {
    try {
      final response = await ApiClient.dio.get('/User/profile');
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] ?? response.data;
        return UserModel.fromJson(data);
      }
      return null;
    } catch (e) {
      if (e is DioException) {
         print('Profile fetch error: \${e.response?.data}');
      }
      return null;
    }
  }
}
