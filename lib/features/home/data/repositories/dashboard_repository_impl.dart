import 'package:juyo/core/error/failure.dart';
import 'package:juyo/core/error/result.dart';
import 'package:juyo/core/models/user_model.dart';
import 'package:juyo/features/home/data/datasources/dashboard_remote_data_source.dart';
import 'package:juyo/features/home/data/models/admission_stats_model.dart';
import 'package:juyo/features/home/data/models/dashboard_stats_model.dart';
import 'package:juyo/features/home/data/models/league_leaderboard_model.dart';
import 'package:juyo/features/home/domain/entities/dashboard_data.dart';
import 'package:juyo/features/home/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  const DashboardRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Result<DashboardData>> getDashboardData() async {
    try {
      final results = await Future.wait([
        remoteDataSource.getProfile(),
        remoteDataSource.getMotivation(),
        remoteDataSource.getStudentStats(),
        remoteDataSource.getAdmissionStats(),
        remoteDataSource.getSkillsProgress(),
      ]);

      final user = results[0] as UserModel?;
      final motivation = results[1] as String;
      final dashboardStats = results[2] as DashboardStatsModel?;
      final admissionStats = results[3] as AdmissionStatsModel?;
      final skills = results[4] as List<SkillProgressModel>;

      var leaderboard = <LeagueLeaderboardModel>[];
      if (user != null) {
        leaderboard = await remoteDataSource.getLeagueLeaderboard(user.id);
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
