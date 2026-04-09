class UserModel {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String? profilePictureUrl;
  final String role;
  final int xp;
  final int eloRating;
  final int streak;
  final int points;
  final int? currentLeagueId;
  final String? currentLeagueName;
  final bool isPremium;

  final String? province;
  final int? gender;
  final int? schoolId;
  final String? schoolName;
  final int? grade;
  final String? clusterName;
  final int? clusterId;
  final String? targetUniversity;
  final int? targetUniversityId;
  final String? targetMajorName;
  final int? targetMajorId;
  final int? targetPassingScore;
  final int? targetPassingScore2024;
  final int? targetPassingScore2025;
  final String? dateOfBirth;
  final int globalRank;
  final String? registrationDate;
  final int age;
  final String? premiumExpiresAt;
  final List<TestResultModel> lastTestResults;

  UserModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.profilePictureUrl,
    required this.role,
    this.xp = 0,
    this.eloRating = 1000,
    this.streak = 0,
    this.points = 0,
    this.currentLeagueId,
    this.currentLeagueName,
    this.isPremium = false,
    this.province,
    this.gender,
    this.schoolId,
    this.schoolName,
    this.grade,
    this.clusterName,
    this.clusterId,
    this.targetUniversity,
    this.targetUniversityId,
    this.targetMajorName,
    this.targetMajorId,
    this.targetPassingScore,
    this.targetPassingScore2024,
    this.targetPassingScore2025,
    this.dateOfBirth,
    this.globalRank = 0,
    this.registrationDate,
    this.age = 0,
    this.premiumExpiresAt,
    this.lastTestResults = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final firstName = _asString(json['firstName'] ?? json['FirstName']);
    final lastName = _asString(json['lastName'] ?? json['LastName']);
    String computedName = '$firstName $lastName'.trim();

    if (computedName.isEmpty) {
      computedName =
          _asString(json['userName'] ?? json['username'] ?? json['email']);
    }

    final dynamic rawRole = json['role'] ?? json['Role'];
    String roleString = 'Student';
    if (rawRole is int) {
      roleString = rawRole == 1 ? 'Admin' : 'Student';
    } else if (rawRole is String) {
      roleString = rawRole;
    }

    final dynamic rawPremium = json['isPremium'] ?? json['IsPremium'] ?? false;
    bool isPremium = false;
    if (rawPremium is bool) {
      isPremium = rawPremium;
    } else if (rawPremium is int) {
      isPremium = rawPremium == 1;
    }

    final List<dynamic>? testResultsJson =
        (json['lastTestResults'] ?? json['LastTestResults']) as List<dynamic>?;
    final List<TestResultModel> testResults = testResultsJson != null
        ? testResultsJson
            .whereType<Map>()
            .map((t) => TestResultModel.fromJson(Map<String, dynamic>.from(t)))
            .toList()
        : [];

    return UserModel(
      id: _asString(json['id']),
      fullName: computedName.isNotEmpty ? computedName : 'User',
      phoneNumber: _asString(json['phoneNumber']),
      profilePictureUrl: json['profilePictureUrl'] ??
          json['avatarUrl'] ??
          json['AvatarUrl'] ??
          json['Avatar'],
      role: roleString,
      xp: _asInt(json['xp'] ?? json['XP'], defaultValue: 0),
      eloRating: _asInt(json['eloRating'] ?? json['EloRating'], defaultValue: 1000),
      streak: _asInt(json['streak'] ?? json['Streak'], defaultValue: 0),
      points: _asInt(json['points'] ?? json['Points'], defaultValue: 0),
      currentLeagueId:
          _asNullableInt(json['currentLeagueId'] ?? json['CurrentLeagueId']),
      currentLeagueName:
          _asNullableString(json['currentLeagueName'] ?? json['CurrentLeagueName']),
      isPremium: isPremium,
      province: _asNullableString(json['province'] ?? json['Province']),
      gender: _asNullableInt(json['gender'] ?? json['Gender']),
      schoolId: _asNullableInt(json['schoolId'] ?? json['SchoolId']),
      schoolName: _asNullableString(json['schoolName'] ?? json['SchoolName']),
      grade: _asNullableInt(json['grade'] ?? json['Grade']),
      clusterName: _asNullableString(json['clusterName'] ?? json['ClusterName']),
      clusterId: _asNullableInt(json['clusterId'] ?? json['ClusterId']),
      targetUniversity:
          _asNullableString(json['targetUniversity'] ?? json['TargetUniversity']),
      targetUniversityId:
          _asNullableInt(json['targetUniversityId'] ?? json['TargetUniversityId']),
      targetMajorName:
          _asNullableString(json['targetMajorName'] ?? json['TargetMajorName']),
      targetMajorId:
          _asNullableInt(json['targetMajorId'] ?? json['TargetMajorId']),
      targetPassingScore:
          _asNullableInt(json['targetPassingScore'] ?? json['TargetPassingScore']),
      targetPassingScore2024: _asNullableInt(
        json['targetPassingScore2024'] ?? json['TargetPassingScore2024'],
      ),
      targetPassingScore2025: _asNullableInt(
        json['targetPassingScore2025'] ?? json['TargetPassingScore2025'],
      ),
      dateOfBirth: _asNullableString(json['dateOfBirth'] ?? json['DateOfBirth']),
      globalRank: _asInt(json['globalRank'] ?? json['GlobalRank'], defaultValue: 0),
      registrationDate:
          _asNullableString(json['registrationDate'] ?? json['RegistrationDate']),
      age: _asInt(json['age'] ?? json['Age'], defaultValue: 0),
      premiumExpiresAt:
          _asNullableString(json['premiumExpiresAt'] ?? json['PremiumExpiresAt']),
      lastTestResults: testResults,
    );
  }

  static String _asString(dynamic value) => value?.toString() ?? '';

  static String? _asNullableString(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim();
    return str.isEmpty ? null : str;
  }

  static int _asInt(dynamic value, {required int defaultValue}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? defaultValue;
  }

  static int? _asNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

class TestResultModel {
  final String id;
  final int mode;
  final int totalScore;
  final String? subjectName;
  final String finishedAt;

  TestResultModel({
    required this.id,
    required this.mode,
    required this.totalScore,
    this.subjectName,
    required this.finishedAt,
  });

  factory TestResultModel.fromJson(Map<String, dynamic> json) {
    return TestResultModel(
      id: json['id']?.toString() ?? '',
      mode: UserModel._asInt(json['mode'], defaultValue: 1),
      totalScore: UserModel._asInt(json['totalScore'], defaultValue: 0),
      subjectName: UserModel._asNullableString(json['subjectName']),
      finishedAt: UserModel._asString(json['finishedAt'] ?? json['FinishedAt']),
    );
  }
}

class SkillProgressModel {
  final int subjectId;
  final String subjectName;
  final int proficiencyPercent;
  final int correctAnswers;
  final int totalQuestions;

  SkillProgressModel({
    required this.subjectId,
    required this.subjectName,
    required this.proficiencyPercent,
    required this.correctAnswers,
    required this.totalQuestions,
  });

  factory SkillProgressModel.fromJson(Map<String, dynamic> json) {
    return SkillProgressModel(
      subjectId: UserModel._asInt(json['subjectId'], defaultValue: 0),
      subjectName: UserModel._asString(json['subjectName']),
      proficiencyPercent:
          UserModel._asInt(json['proficiencyPercent'], defaultValue: 0),
      correctAnswers: UserModel._asInt(json['correctAnswers'], defaultValue: 0),
      totalQuestions: UserModel._asInt(json['totalQuestions'], defaultValue: 0),
    );
  }
}
