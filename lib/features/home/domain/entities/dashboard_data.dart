import 'package:juyo/core/models/user_model.dart';
import 'package:juyo/features/home/data/models/admission_stats_model.dart';
import 'package:juyo/features/home/data/models/dashboard_stats_model.dart';
import 'package:juyo/features/home/data/models/league_leaderboard_model.dart';

class DashboardData {
  final UserModel? user;
  final String motivation;
  final DashboardStatsModel? dashboardStats;
  final AdmissionStatsModel? admissionStats;
  final List<LeagueLeaderboardModel> leaderboard;
  final List<SkillProgressModel> skills;

  const DashboardData({
    required this.user,
    required this.motivation,
    required this.dashboardStats,
    required this.admissionStats,
    required this.leaderboard,
    required this.skills,
  });
}
