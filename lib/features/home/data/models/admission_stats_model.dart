class AdmissionStatsModel {
  final String universityName;
  final String? facultyName;
  final String specialtyName;
  final String? targetUniversity;
  final String? targetFaculty;
  final String? targetMajorName;
  final num targetPassingScore;
  final num? targetPassingScore2024;
  final num? targetPassingScore2025;
  final num averageScore;
  final num scoreGap;
  final num admissionProbability;
  final String status;
  final int relevantTestsCount;
  final bool hasTarget;

  AdmissionStatsModel({
    required this.universityName,
    this.facultyName,
    required this.specialtyName,
    this.targetUniversity,
    this.targetFaculty,
    this.targetMajorName,
    required this.targetPassingScore,
    this.targetPassingScore2024,
    this.targetPassingScore2025,
    required this.averageScore,
    required this.scoreGap,
    required this.admissionProbability,
    required this.status,
    required this.relevantTestsCount,
    required this.hasTarget,
  });

  factory AdmissionStatsModel.fromJson(Map<String, dynamic> json) {
    return AdmissionStatsModel(
      universityName: json['universityName'] ?? json['UniversityName'] ?? '',
      facultyName: json['facultyName'] ?? json['FacultyName'],
      specialtyName: json['specialtyName'] ?? json['SpecialtyName'] ?? '',
      targetUniversity: json['targetUniversity'] ?? json['TargetUniversity'],
      targetFaculty: json['targetFaculty'] ?? json['TargetFaculty'],
      targetMajorName: json['targetMajorName'] ?? json['TargetMajorName'],
      targetPassingScore: json['targetPassingScore'] ?? json['TargetPassingScore'] ?? 0,
      targetPassingScore2024: json['targetPassingScore2024'] ?? json['TargetPassingScore2024'],
      targetPassingScore2025: json['targetPassingScore2025'] ?? json['TargetPassingScore2025'],
      averageScore: json['averageScore'] ?? json['AverageScore'] ?? 0,
      scoreGap: json['scoreGap'] ?? json['ScoreGap'] ?? 0,
      admissionProbability: json['admissionProbability'] ?? json['AdmissionProbability'] ?? 0,
      status: json['status'] ?? json['Status'] ?? 'Safe',
      relevantTestsCount: json['relevantTestsCount'] ?? json['RelevantTestsCount'] ?? 0,
      hasTarget: json['hasTarget'] ?? json['HasTarget'] ?? false,
    );
  }
}
