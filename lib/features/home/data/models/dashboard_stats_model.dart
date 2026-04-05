class DashboardStatsModel {
  final List<DailyActivityModel> dailyActivity;
  final List<SubjectPerformanceModel> subjectPerformance;
  final int todoRedListCount;
  final List<UniversityProbabilityModel> universityProbability;
  final DailyProgressModel dailyProgress;

  DashboardStatsModel({
    required this.dailyActivity,
    required this.subjectPerformance,
    required this.todoRedListCount,
    required this.universityProbability,
    required this.dailyProgress,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      dailyActivity: (json['dailyActivity'] as List?)
              ?.map((e) => DailyActivityModel.fromJson(e))
              .toList() ??
          [],
      subjectPerformance: (json['subjectPerformance'] as List?)
              ?.map((e) => SubjectPerformanceModel.fromJson(e))
              .toList() ??
          [],
      todoRedListCount: json['todoRedListCount'] ?? 0,
      universityProbability: (json['universityProbability'] as List?)
              ?.map((e) => UniversityProbabilityModel.fromJson(e))
              .toList() ??
          [],
      dailyProgress: json['dailyProgress'] != null
          ? DailyProgressModel.fromJson(json['dailyProgress'])
          : DailyProgressModel(completed: 0, goal: 0),
    );
  }
}

class DailyProgressModel {
  final int completed;
  final int goal;

  DailyProgressModel({required this.completed, required this.goal});

  factory DailyProgressModel.fromJson(Map<String, dynamic> json) {
    return DailyProgressModel(
      completed: json['completed'] ?? 0,
      goal: json['goal'] ?? 0,
    );
  }
}

class DailyActivityModel {
  final String date;
  final int testsCount;

  DailyActivityModel({required this.date, required this.testsCount});

  factory DailyActivityModel.fromJson(Map<String, dynamic> json) {
    return DailyActivityModel(
      date: json['date'] ?? '',
      testsCount: json['testsCount'] ?? 0,
    );
  }
}

class SubjectPerformanceModel {
  final String subject;
  final int score;

  SubjectPerformanceModel({required this.subject, required this.score});

  factory SubjectPerformanceModel.fromJson(Map<String, dynamic> json) {
    return SubjectPerformanceModel(
      subject: json['subject'] ?? '',
      score: json['score'] ?? 0,
    );
  }
}

class UniversityProbabilityModel {
  final String name;
  final int percent;

  UniversityProbabilityModel({required this.name, required this.percent});

  factory UniversityProbabilityModel.fromJson(Map<String, dynamic> json) {
    return UniversityProbabilityModel(
      name: json['name'] ?? '',
      percent: json['percent'] ?? 0,
    );
  }
}
