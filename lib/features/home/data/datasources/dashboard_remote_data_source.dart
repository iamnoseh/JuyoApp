import 'package:dio/dio.dart';
import 'package:juyo/core/models/user_model.dart';
import 'package:juyo/features/home/data/models/admission_stats_model.dart';
import 'package:juyo/features/home/data/models/dashboard_stats_model.dart';
import 'package:juyo/features/home/data/models/league_leaderboard_model.dart';

class DashboardRemoteDataSource {
  final Dio dio;

  const DashboardRemoteDataSource(this.dio);

  Future<UserModel?> getProfile() async {
    final response = await dio.get('/User/profile');
    final data = _extractMap(response.data);
    if (data == null) return null;
    return UserModel.fromJson(data);
  }

  Future<String> getMotivation() async {
    final response = await dio.get('/Dashboard/motivation');
    final body = response.data;
    if (body is String) {
      return body;
    }

    if (body is Map<String, dynamic>) {
      final wrapped = body['data'];
      if (wrapped is String && wrapped.trim().isNotEmpty) {
        return wrapped;
      }
    }

    return 'Знание — это единственное сокровище, которое растёт, когда им делятся.';
  }

  Future<DashboardStatsModel?> getStudentStats() async {
    final response = await dio.get('/Dashboard/student-stats');
    final data = _extractMap(response.data);
    if (data == null) return null;
    return DashboardStatsModel.fromJson(data);
  }

  Future<AdmissionStatsModel?> getAdmissionStats() async {
    try {
      final response = await dio.get('/Admission/stats');
      final data = _extractMap(response.data);
      if (data == null) return null;
      return AdmissionStatsModel.fromJson(data);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<List<SkillProgressModel>> getSkillsProgress() async {
    final response = await dio.get('/Stats/skills');
    final data = _extractList(response.data);
    return data
        .whereType<Map>()
        .map((item) => SkillProgressModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<LeagueLeaderboardModel>> getLeagueLeaderboard(String currentUserId) async {
    final response = await dio.get('/League/leaderboard');
    final data = _extractList(response.data);
    return data
        .whereType<Map>()
        .map(
          (item) => LeagueLeaderboardModel.fromJson(
            Map<String, dynamic>.from(item),
            currentUserId: currentUserId,
          ),
        )
        .toList();
  }

  Map<String, dynamic>? _extractMap(dynamic body) {
    if (body is Map<String, dynamic>) {
      final wrapped = body['data'];
      if (wrapped is Map) {
        return Map<String, dynamic>.from(wrapped);
      }
      return body;
    }
    return null;
  }

  List<dynamic> _extractList(dynamic body) {
    if (body is List) {
      return body;
    }
    if (body is Map<String, dynamic>) {
      final wrapped = body['data'] ?? body['items'];
      if (wrapped is List) {
        return wrapped;
      }
    }
    return const [];
  }
}
