import 'package:dio/dio.dart';
import 'package:juyo/features/reference/data/models/reference_models.dart';

class ReferenceRemoteDataSource {
  final Dio dio;

  const ReferenceRemoteDataSource(this.dio);

  Future<List<SchoolModel>> getSchools({String? province}) async {
    final response = await dio.get(
      '/reference/schools',
      queryParameters: {
        'Skip': 0,
        'PageSize': 1000,
        if (province != null && province.isNotEmpty) 'Province': province,
      },
    );

    final body = response.data;
    final data = body is List
        ? body
        : (body['items'] as List<dynamic>? ?? body['data']?['items'] as List<dynamic>? ?? []);

    return data
        .whereType<Map>()
        .map((item) => SchoolModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<UniversityModel>> getUniversities() async {
    final response = await dio.get(
      '/reference/universities',
      queryParameters: {
        'Skip': 0,
        'PageSize': 100,
      },
    );

    final body = response.data;
    final data = body is List
        ? body
        : (body['items'] as List<dynamic>? ?? body['data']?['items'] as List<dynamic>? ?? []);

    return data
        .whereType<Map>()
        .map((item) => UniversityModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<MajorModel>> getMajors(int universityId) async {
    final response = await dio.get('/reference/universities/$universityId/majors');
    final body = response.data;
    final data = body is List ? body : (body['data'] as List<dynamic>? ?? []);

    return data
        .whereType<Map>()
        .map((item) => MajorModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
