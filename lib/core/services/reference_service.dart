import 'package:juyo/core/network/api_client.dart';

class SchoolOption {
  final int id;
  final String name;
  final String? province;

  const SchoolOption({required this.id, required this.name, this.province});

  factory SchoolOption.fromJson(Map<String, dynamic> json) {
    return SchoolOption(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      province: json['province']?.toString(),
    );
  }
}

class UniversityOption {
  final int id;
  final String name;

  const UniversityOption({required this.id, required this.name});

  factory UniversityOption.fromJson(Map<String, dynamic> json) {
    return UniversityOption(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}

class MajorOption {
  final int id;
  final String name;

  const MajorOption({required this.id, required this.name});

  factory MajorOption.fromJson(Map<String, dynamic> json) {
    return MajorOption(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}

class ReferenceService {
  static Future<List<SchoolOption>> fetchSchools({String? province}) async {
    final response = await ApiClient.dio.get(
      '/reference/schools',
      queryParameters: {
        'Skip': 0,
        'PageSize': 1000,
        if (province != null && province.isNotEmpty) 'Province': province,
      },
    );

    final dynamic body = response.data;
    final List<dynamic> data = body is List
        ? body
        : (body['items'] as List<dynamic>? ?? body['data']?['items'] as List<dynamic>? ?? []);
    return data.whereType<Map>().map((e) => SchoolOption.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  static Future<List<UniversityOption>> fetchUniversities() async {
    final response = await ApiClient.dio.get(
      '/reference/universities',
      queryParameters: {'Skip': 0, 'PageSize': 100},
    );
    final dynamic body = response.data;
    final List<dynamic> data = body is List
        ? body
        : (body['items'] as List<dynamic>? ?? body['data']?['items'] as List<dynamic>? ?? []);
    return data.whereType<Map>().map((e) => UniversityOption.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  static Future<List<MajorOption>> fetchMajors(int universityId) async {
    final response = await ApiClient.dio.get('/reference/universities/$universityId/majors');
    final dynamic body = response.data;
    final List<dynamic> data = body is List ? body : (body['data'] as List<dynamic>? ?? []);
    return data.whereType<Map>().map((e) => MajorOption.fromJson(Map<String, dynamic>.from(e))).toList();
  }
}

