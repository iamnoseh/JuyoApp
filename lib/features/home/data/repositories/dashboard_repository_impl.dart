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
    final user = await _safeCall<UserModel?>(() => remoteDataSource.getProfile());
    final motivation = await _safeCall<String>(
      () => remoteDataSource.getMotivation(),
      fallback: 'Знание - это единственное сокровище, которое растет, когда им делятся.',
    );
    final dashboardStats = await _safeCall<DashboardStatsModel?>(() => remoteDataSource.getStudentStats());
    final admissionStats = await _safeCall<AdmissionStatsModel?>(() => remoteDataSource.getAdmissionStats());
    final skills = await _safeCall<List<SkillProgressModel>>(
      () => remoteDataSource.getSkillsProgress(),
      fallback: const <SkillProgressModel>[],
    );

    var leaderboard = <LeagueLeaderboardModel>[];
    if (user != null) {
      leaderboard = await _safeCall<List<LeagueLeaderboardModel>>(
        () => remoteDataSource.getLeagueLeaderboard(user.id),
        fallback: const <LeagueLeaderboardModel>[],
      );
    }

    if (user == null &&
        dashboardStats == null &&
        admissionStats == null &&
        skills.isEmpty &&
        leaderboard.isEmpty) {
      return const Error<DashboardData>(
        NetworkFailure('Failed to load dashboard data'),
      );
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
  }

  Future<T> _safeCall<T>(Future<T> Function() request, {T? fallback}) async {
    try {
      return await request();
    } catch (_) {
      if (fallback != null) {
        return fallback;
      }
      rethrow;
    }
  }
}
