import 'package:juyo/core/models/user_model.dart';
import 'package:juyo/features/home/data/models/admission_stats_model.dart';
import 'package:juyo/features/home/data/models/dashboard_stats_model.dart';
import 'package:juyo/features/home/data/models/league_leaderboard_model.dart';
import 'package:juyo/features/home/data/models/test_activity_model.dart';

class DashboardMotivation {
  final String content;
  final String author;

  const DashboardMotivation({
    required this.content,
    required this.author,
  });
}

class DashboardData {
  final UserModel? user;
  final DashboardMotivation motivation;
  final DashboardStatsModel? dashboardStats;
  final TestActivityModel? testActivity;
  final AdmissionStatsModel? admissionStats;
  final List<LeagueLeaderboardModel> leaderboard;
  final List<SkillProgressModel> skills;

  const DashboardData({
    required this.user,
    required this.motivation,
    required this.dashboardStats,
    required this.testActivity,
    required this.admissionStats,
    required this.leaderboard,
    required this.skills,
  });
}
