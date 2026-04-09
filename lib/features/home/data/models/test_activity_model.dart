class TestActivityModel {
  final int totalTests;
  final int totalDuels;
  final int totalDuelWins;
  final int overallCorrectPercentage;
  final List<TestActivityDayModel> dailyStats;

  const TestActivityModel({
    required this.totalTests,
    required this.totalDuels,
    required this.totalDuelWins,
    required this.overallCorrectPercentage,
    required this.dailyStats,
  });

  factory TestActivityModel.fromJson(Map<String, dynamic> json) {
    final rawDailyStats = json['dailyStats'] ?? json['DailyStats'];

    return TestActivityModel(
      totalTests: json['totalTests'] ?? json['TotalTests'] ?? 0,
      totalDuels: json['totalDuels'] ?? json['TotalDuels'] ?? 0,
      totalDuelWins: json['totalDuelWins'] ?? json['TotalDuelWins'] ?? 0,
      overallCorrectPercentage:
          json['overallCorrectPercentage'] ??
          json['OverallCorrectPercentage'] ??
          0,
      dailyStats: (rawDailyStats as List?)
              ?.whereType<Map>()
              .map(
                (item) => TestActivityDayModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList() ??
          const [],
    );
  }
}

class TestActivityDayModel {
  final String date;
  final int totalAnswers;
  final int correctAnswers;
  final int incorrectAnswers;

  const TestActivityDayModel({
    required this.date,
    required this.totalAnswers,
    required this.correctAnswers,
    required this.incorrectAnswers,
  });

  factory TestActivityDayModel.fromJson(Map<String, dynamic> json) {
    return TestActivityDayModel(
      date: (json['date'] ?? json['Date'] ?? '').toString(),
      totalAnswers: json['totalAnswers'] ?? json['TotalAnswers'] ?? 0,
      correctAnswers: json['correctAnswers'] ?? json['CorrectAnswers'] ?? 0,
      incorrectAnswers: json['incorrectAnswers'] ?? json['IncorrectAnswers'] ?? 0,
    );
  }
}
