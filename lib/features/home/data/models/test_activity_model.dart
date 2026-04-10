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
      totalTests: _asInt(json['totalTests'] ?? json['TotalTests']),
      totalDuels: _asInt(json['totalDuels'] ?? json['TotalDuels']),
      totalDuelWins: _asInt(json['totalDuelWins'] ?? json['TotalDuelWins']),
      overallCorrectPercentage:
          _asInt(json['overallCorrectPercentage'] ?? json['OverallCorrectPercentage']),
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
      totalAnswers: _asInt(json['totalAnswers'] ?? json['TotalAnswers']),
      correctAnswers: _asInt(json['correctAnswers'] ?? json['CorrectAnswers']),
      incorrectAnswers: _asInt(json['incorrectAnswers'] ?? json['IncorrectAnswers']),
    );
  }
}

int _asInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value.toString()) ?? 0;
}
