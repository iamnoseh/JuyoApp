import 'package:dio/dio.dart';
import 'package:juyo/core/models/user_model.dart';
import 'package:juyo/core/network/api_client.dart';
import 'package:juyo/features/home/data/models/admission_stats_model.dart';
import 'package:juyo/features/home/data/models/dashboard_stats_model.dart';
import 'package:juyo/features/home/data/models/league_leaderboard_model.dart';

class DashboardService {
  static Future<List<LeagueLeaderboardModel>> fetchLeagueLeaderboard(
    String currentUserId,
  ) async {
    try {
      final response = await ApiClient.dio.get('/League/leaderboard');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data
            .map(
              (item) => LeagueLeaderboardModel.fromJson(
                item,
                currentUserId: currentUserId,
              ),
            )
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<String> fetchMotivation() async {
    try {
      final response = await ApiClient.dio.get('/Dashboard/motivation');

      if (response.data is String) {
        return response.data as String;
      }
      if (response.data != null && response.data['data'] != null) {
        return response.data['data'].toString();
      }
      return 'Знание растет, когда ты учишься каждый день.';
    } catch (_) {
      return 'Знание растет, когда ты учишься каждый день.';
    }
  }

  static Future<DashboardStatsModel?> fetchStudentStats() async {
    try {
      final response = await ApiClient.dio.get('/Dashboard/student-stats');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] ?? response.data;
        return DashboardStatsModel.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<AdmissionStatsModel?> fetchAdmissionStats() async {
    try {
      final response = await ApiClient.dio.get('/Admission/stats');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] ?? response.data;
        return AdmissionStatsModel.fromJson(data);
      }
      return null;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return null;
      }
      return null;
    }
  }

  static Future<List<SkillProgressModel>> fetchSkillsProgress() async {
    try {
      final response = await ApiClient.dio.get('/Stats/skills');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((item) => SkillProgressModel.fromJson(item)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
