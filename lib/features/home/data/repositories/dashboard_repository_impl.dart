import 'package:juyo/core/error/failure.dart';
import 'package:juyo/core/error/result.dart';
import 'package:juyo/core/models/user_model.dart';
import 'package:juyo/core/services/user_service.dart';
import 'package:juyo/features/home/data/datasources/dashboard_service.dart';
import 'package:juyo/features/home/data/models/admission_stats_model.dart';
import 'package:juyo/features/home/data/models/dashboard_stats_model.dart';
import 'package:juyo/features/home/data/models/league_leaderboard_model.dart';
import 'package:juyo/features/home/domain/entities/dashboard_data.dart';
import 'package:juyo/features/home/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl();

  @override
  Future<Result<DashboardData>> getDashboardData() async {
    try {
      final results = await Future.wait([
        UserService.fetchProfile(),
        DashboardService.fetchMotivation(),
        DashboardService.fetchStudentStats(),
        DashboardService.fetchAdmissionStats(),
        DashboardService.fetchSkillsProgress(),
      ]);

      final user = results[0] as UserModel?;
      final motivation = results[1] as String;
      final dashboardStats = results[2] as DashboardStatsModel?;
      final admissionStats = results[3] as AdmissionStatsModel?;
      final skills = results[4] as List<SkillProgressModel>;

      List<LeagueLeaderboardModel> leaderboard = [];
      if (user != null) {
        leaderboard = await DashboardService.fetchLeagueLeaderboard(user.id);
      }

      return Success<DashboardData>(
        DashboardData(
          user: user,
          motivation: motivation,
          dashboardStats: dashboardStats,
          admissionStats: admissionStats,
          leaderboard: leaderboard,
          skills: skills,
        ),
      );
    } catch (_) {
      return const Error<DashboardData>(
        NetworkFailure('Failed to load dashboard data'),
      );
    }
  }
}
