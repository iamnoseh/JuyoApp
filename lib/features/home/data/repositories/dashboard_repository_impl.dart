import 'package:juyo/core/error/failure.dart';
import 'package:juyo/core/error/result.dart';
import 'package:juyo/core/models/user_model.dart';
import 'package:juyo/features/home/data/datasources/dashboard_remote_data_source.dart';
import 'package:juyo/features/home/data/models/admission_stats_model.dart';
import 'package:juyo/features/home/data/models/dashboard_stats_model.dart';
import 'package:juyo/features/home/data/models/league_leaderboard_model.dart';
import 'package:juyo/features/home/data/models/test_activity_model.dart';
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
    final motivation = await _safeCall<DashboardMotivation>(
      () => remoteDataSource.getMotivation(),
      fallback: const DashboardMotivation(
        content: 'Знание растет, когда ты учишься каждый день.',
        author: '',
      ),
    );
    final dashboardStats =
        await _safeCall<DashboardStatsModel?>(() => remoteDataSource.getStudentStats());
    final testActivity = await _safeCall<TestActivityModel?>(
      () => remoteDataSource.getTestActivity(),
    );
    final admissionStats =
        await _safeCall<AdmissionStatsModel?>(() => remoteDataSource.getAdmissionStats());
    final skills = await _safeCall<List<SkillProgressModel>>(
      () => remoteDataSource.getSkillsProgress(),
      fallback: const <SkillProgressModel>[],
    );

    var leaderboard = <LeagueLeaderboardModel>[];
    if (user != null && user.currentLeagueId != null) {
      leaderboard = await _safeCall<List<LeagueLeaderboardModel>>(
        () => remoteDataSource.getLeagueStandings(user.currentLeagueId!, user.id),
        fallback: const <LeagueLeaderboardModel>[],
      );
      leaderboard = _neighborsForCurrentUser(leaderboard);
    }

    if (user == null &&
        dashboardStats == null &&
        testActivity == null &&
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
        testActivity: testActivity,
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

  List<LeagueLeaderboardModel> _neighborsForCurrentUser(
    List<LeagueLeaderboardModel> standings,
  ) {
    if (standings.isEmpty) {
      return standings;
    }

    final currentIndex = standings.indexWhere((item) => item.isMe);
    if (currentIndex == -1) {
      return standings.take(3).toList();
    }

    var start = currentIndex - 1;
    var end = currentIndex + 2;

    if (start < 0) {
      end += -start;
      start = 0;
    }

    if (end > standings.length) {
      start = (start - (end - standings.length))
          .clamp(0, standings.length)
          .toInt();
      end = standings.length;
    }

    return standings.sublist(start, end);
  }
}
