import 'package:dio/dio.dart';
import 'package:juyo/core/models/user_model.dart';
import 'package:juyo/features/home/data/models/admission_stats_model.dart';
import 'package:juyo/features/home/data/models/dashboard_stats_model.dart';
import 'package:juyo/features/home/data/models/league_leaderboard_model.dart';
import 'package:juyo/features/home/data/models/test_activity_model.dart';
import 'package:juyo/features/home/domain/entities/dashboard_data.dart';

class DashboardRemoteDataSource {
  final Dio dio;

  const DashboardRemoteDataSource(this.dio);

  Future<UserModel?> getProfile() async {
    final response = await dio.get('/User/profile');
    final data = _extractMap(response.data);
    if (data == null) return null;
    return UserModel.fromJson(data);
  }

  Future<DashboardMotivation> getMotivation() async {
    try {
      final quoteResponse = await dio.get('/Motivation/random');
      final quoteBody = quoteResponse.data;
      if (quoteBody is Map) {
        final source = Map<String, dynamic>.from(quoteBody);
        final content =
            (source['content'] ?? source['Content'] ?? '').toString().trim();
        final author =
            (source['author'] ?? source['Author'] ?? '').toString().trim();

        if (content.isNotEmpty) {
          return DashboardMotivation(
            content: content,
            author: author,
          );
        }
      }
    } catch (_) {}

    final response = await dio.get('/Dashboard/motivation');
    final body = response.data;
    if (body is String) {
      return DashboardMotivation(content: body.trim(), author: '');
    }

    if (body is Map) {
      final source = Map<String, dynamic>.from(body);
      final wrapped = source['data'];
      if (wrapped is String && wrapped.trim().isNotEmpty) {
        return DashboardMotivation(content: wrapped.trim(), author: '');
      }
    }

    return const DashboardMotivation(
      content: 'Знание растет, когда ты учишься каждый день.',
      author: '',
    );
  }

  Future<DashboardStatsModel?> getStudentStats() async {
    final response = await dio.get('/Dashboard/student-stats');
    final data = _extractMap(response.data);
    if (data == null) return null;
    return DashboardStatsModel.fromJson(data);
  }

  Future<TestActivityModel?> getTestActivity({int days = 30}) async {
    try {
      final response = await dio.get('/User/test-activity?days=$days');
      final data = _extractMap(response.data);
      if (data == null) return null;
      return TestActivityModel.fromJson(data);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
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
        .map(
          (item) =>
              SkillProgressModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<List<LeagueLeaderboardModel>> getLeagueStandings(
    int leagueId,
    String currentUserId,
  ) async {
    final response = await dio.get('/League/$leagueId/standings');
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
    if (body is Map) {
      final source = Map<String, dynamic>.from(body);
      final wrapped = source['data'];
      if (wrapped is Map) {
        return Map<String, dynamic>.from(wrapped);
      }
      return source;
    }
    return null;
  }

  List<dynamic> _extractList(dynamic body) {
    if (body is List) {
      return body;
    }
    if (body is Map) {
      final source = Map<String, dynamic>.from(body);
      final wrapped = source['data'] ?? source['items'];
      if (wrapped is List) {
        return wrapped;
      }
    }
    return const [];
  }
}
