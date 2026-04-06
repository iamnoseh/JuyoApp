import 'package:juyo/features/profile/domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.userId,
    required super.firstName,
    required super.lastName,
    required super.fullName,
    required super.phoneNumber,
    required super.role,
    required super.avatarUrl,
    required super.xp,
    required super.eloRating,
    required super.streak,
    required super.points,
    required super.isPremium,
    required super.province,
    required super.gender,
    required super.schoolId,
    required super.schoolName,
    required super.grade,
    required super.clusterName,
    required super.clusterId,
    required super.targetUniversity,
    required super.targetUniversityId,
    required super.targetMajorName,
    required super.targetMajorId,
    required super.targetPassingScore,
    required super.targetPassingScore2024,
    required super.targetPassingScore2025,
    required super.dateOfBirth,
    required super.globalRank,
    required super.registrationDate,
    required super.age,
    required super.premiumExpiresAt,
    required super.currentLeagueName,
    required super.lastTestResults,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final firstName = _asString(json['firstName'] ?? json['FirstName']);
    final lastName = _asString(json['lastName'] ?? json['LastName']);
    final fullName = '$firstName $lastName'.trim().isNotEmpty
        ? '$firstName $lastName'.trim()
        : _asString(json['userName'] ?? json['username'] ?? json['email']);

    final rawRole = json['role'] ?? json['Role'];
    final role = rawRole is int
        ? (rawRole == 1 ? 'Admin' : 'Student')
        : rawRole?.toString() ?? 'Student';

    final rawPremium = json['isPremium'] ?? json['IsPremium'] ?? false;
    final isPremium = rawPremium is bool
        ? rawPremium
        : rawPremium is int
            ? rawPremium == 1
            : rawPremium.toString().toLowerCase() == 'true';

    final testResultsJson =
        (json['lastTestResults'] ?? json['LastTestResults']) as List<dynamic>?;

    return ProfileModel(
      userId: _asString(json['userId'] ?? json['id']),
      firstName: firstName,
      lastName: lastName,
      fullName: fullName.isNotEmpty ? fullName : 'Пользователь',
      phoneNumber: _asString(json['phoneNumber']),
      role: role,
      avatarUrl: _asNullableString(
        json['profilePictureUrl'] ??
            json['avatarUrl'] ??
            json['AvatarUrl'] ??
            json['Avatar'],
      ),
      xp: _asInt(json['xp'] ?? json['XP'], defaultValue: 0),
      eloRating: _asInt(json['eloRating'] ?? json['EloRating'], defaultValue: 1000),
      streak: _asInt(json['streak'] ?? json['Streak'], defaultValue: 0),
      points: _asInt(json['points'] ?? json['Points'], defaultValue: 0),
      isPremium: isPremium,
      province: _asNullableString(json['province'] ?? json['Province']),
      gender: _asNullableInt(json['gender'] ?? json['Gender']),
      schoolId: _asNullableInt(json['schoolId'] ?? json['SchoolId']),
      schoolName: _asNullableString(json['schoolName'] ?? json['SchoolName']),
      grade: _asNullableInt(json['grade'] ?? json['Grade']),
      clusterName: _asNullableString(json['clusterName'] ?? json['ClusterName']),
      clusterId: _asNullableInt(json['clusterId'] ?? json['ClusterId']),
      targetUniversity: _asNullableString(
        json['targetUniversity'] ?? json['TargetUniversity'],
      ),
      targetUniversityId: _asNullableInt(
        json['targetUniversityId'] ?? json['TargetUniversityId'],
      ),
      targetMajorName: _asNullableString(
        json['targetMajorName'] ?? json['TargetMajorName'],
      ),
      targetMajorId: _asNullableInt(json['targetMajorId'] ?? json['TargetMajorId']),
      targetPassingScore: _asNullableInt(
        json['targetPassingScore'] ?? json['TargetPassingScore'],
      ),
      targetPassingScore2024: _asNullableInt(
        json['targetPassingScore2024'] ?? json['TargetPassingScore2024'],
      ),
      targetPassingScore2025: _asNullableInt(
        json['targetPassingScore2025'] ?? json['TargetPassingScore2025'],
      ),
      dateOfBirth: _asNullableString(json['dateOfBirth'] ?? json['DateOfBirth']),
      globalRank: _asInt(json['globalRank'] ?? json['GlobalRank'], defaultValue: 0),
      registrationDate: _asNullableString(
        json['registrationDate'] ?? json['RegistrationDate'],
      ),
      age: _asInt(json['age'] ?? json['Age'], defaultValue: 0),
      premiumExpiresAt: _asNullableString(
        json['premiumExpiresAt'] ?? json['PremiumExpiresAt'],
      ),
      currentLeagueName: _asNullableString(
        json['currentLeagueName'] ?? json['CurrentLeagueName'],
      ),
      lastTestResults: testResultsJson == null
          ? const []
          : testResultsJson
              .whereType<Map>()
              .map(
                (test) => ProfileTestResult(
                  id: _asString(test['id']),
                  mode: _asInt(test['mode'], defaultValue: 1),
                  totalScore: _asInt(test['totalScore'], defaultValue: 0),
                  subjectName: _asNullableString(test['subjectName']),
                  finishedAt: _asString(test['finishedAt'] ?? test['FinishedAt']),
                ),
              )
              .toList(),
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
