import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:juyo/core/network/api_client.dart';
import 'package:juyo/core/models/user_model.dart';

class UserService {
  static Future<UserModel?> fetchProfile() async {
    try {
      final response = await ApiClient.dio.get('/User/profile');
      
      if (response.statusCode == 200 && response.data != null) {
        final dynamic rawData = response.data['data'] ?? response.data;
        if (rawData is! Map) {
          return null;
        }
        final data = Map<String, dynamic>.from(rawData);
        return UserModel.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    int? gender,
    String? province,
    int? schoolId,
    int? grade,
    int? clusterId,
    String? targetUniversity,
    int? targetUniversityId,
    int? targetMajorId,
    DateTime? dateOfBirth,
    MultipartFile? avatar,
  }) async {
    try {
      final formData = FormData.fromMap({
        if (firstName != null) 'FirstName': firstName,
        if (lastName != null) 'LastName': lastName,
        if (gender != null) 'Gender': gender,
        if (province != null) 'Province': province,
        if (schoolId != null) 'SchoolId': schoolId,
        if (grade != null) 'Grade': grade,
        if (clusterId != null) 'ClusterId': clusterId,
        if (targetUniversity != null) 'TargetUniversity': targetUniversity,
        if (targetUniversityId != null) 'TargetUniversityId': targetUniversityId,
        if (targetMajorId != null) 'TargetMajorId': targetMajorId,
        if (dateOfBirth != null) 'DateOfBirth': dateOfBirth.toIso8601String(),
        if (avatar != null) 'Avatar': avatar,
      });

      final response = await ApiClient.dio.patch(
        '/User/profile',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<MultipartFile> buildAvatarPart(String filePath, String fileName) async {
    final lower = fileName.toLowerCase();
    String subtype = 'jpeg';
    if (lower.endsWith('.png')) subtype = 'png';
    if (lower.endsWith('.webp')) subtype = 'webp';
    return MultipartFile.fromFile(
      filePath,
      filename: fileName,
      contentType: MediaType('image', subtype),
    );
  }
}
