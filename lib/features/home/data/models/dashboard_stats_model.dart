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
    final dailyActivityRaw = json['dailyActivity'] ?? json['DailyActivity'];
    final subjectPerformanceRaw =
        json['subjectPerformance'] ?? json['SubjectPerformance'];
    final universityProbabilityRaw =
        json['universityProbability'] ?? json['UniversityProbability'];
    final dailyProgressRaw = json['dailyProgress'] ?? json['DailyProgress'];

    return DashboardStatsModel(
      dailyActivity: (dailyActivityRaw as List?)
              ?.map((e) => DailyActivityModel.fromJson(e))
              .toList() ??
          [],
      subjectPerformance: (subjectPerformanceRaw as List?)
              ?.map((e) => SubjectPerformanceModel.fromJson(e))
              .toList() ??
          [],
      todoRedListCount: json['todoRedListCount'] ?? json['TodoRedListCount'] ?? 0,
      universityProbability: (universityProbabilityRaw as List?)
              ?.map((e) => UniversityProbabilityModel.fromJson(e))
              .toList() ??
          [],
      dailyProgress: dailyProgressRaw != null
          ? DailyProgressModel.fromJson(Map<String, dynamic>.from(dailyProgressRaw as Map))
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
      completed: json['completed'] ?? json['Completed'] ?? 0,
      goal: json['goal'] ?? json['Goal'] ?? 0,
    );
  }
}

class DailyActivityModel {
  final String date;
  final int testsCount;

  DailyActivityModel({required this.date, required this.testsCount});

  factory DailyActivityModel.fromJson(Map<String, dynamic> json) {
    return DailyActivityModel(
      date: json['date'] ?? json['Date'] ?? '',
      testsCount: json['testsCount'] ?? json['TestsCount'] ?? 0,
    );
  }
}

class SubjectPerformanceModel {
  final String subject;
  final int score;

  SubjectPerformanceModel({required this.subject, required this.score});

  factory SubjectPerformanceModel.fromJson(Map<String, dynamic> json) {
    return SubjectPerformanceModel(
      subject: json['subject'] ?? json['Subject'] ?? '',
      score: json['score'] ?? json['Score'] ?? 0,
    );
  }
}

class UniversityProbabilityModel {
  final String name;
  final int percent;

  UniversityProbabilityModel({required this.name, required this.percent});

  factory UniversityProbabilityModel.fromJson(Map<String, dynamic> json) {
    return UniversityProbabilityModel(
      name: json['name'] ?? json['Name'] ?? '',
      percent: json['percent'] ?? json['Percent'] ?? 0,
    );
  }
}
