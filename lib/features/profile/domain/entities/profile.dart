import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String userId;
  final String firstName;
  final String lastName;
  final String fullName;
  final String phoneNumber;
  final String role;
  final String? avatarUrl;
  final int xp;
  final int eloRating;
  final int streak;
  final int points;
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
  final String? currentLeagueName;
  final List<ProfileTestResult> lastTestResults;

  const Profile({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.phoneNumber,
    required this.role,
    required this.avatarUrl,
    required this.xp,
    required this.eloRating,
    required this.streak,
    required this.points,
    required this.isPremium,
    required this.province,
    required this.gender,
    required this.schoolId,
    required this.schoolName,
    required this.grade,
    required this.clusterName,
    required this.clusterId,
    required this.targetUniversity,
    required this.targetUniversityId,
    required this.targetMajorName,
    required this.targetMajorId,
    required this.targetPassingScore,
    required this.targetPassingScore2024,
    required this.targetPassingScore2025,
    required this.dateOfBirth,
    required this.globalRank,
    required this.registrationDate,
    required this.age,
    required this.premiumExpiresAt,
    required this.currentLeagueName,
    required this.lastTestResults,
  });

  @override
  List<Object?> get props => [
        userId,
        firstName,
        lastName,
        fullName,
        phoneNumber,
        role,
        avatarUrl,
        xp,
        eloRating,
        streak,
        points,
        isPremium,
        province,
        gender,
        schoolId,
        schoolName,
        grade,
        clusterName,
        clusterId,
        targetUniversity,
        targetUniversityId,
        targetMajorName,
        targetMajorId,
        targetPassingScore,
        targetPassingScore2024,
        targetPassingScore2025,
        dateOfBirth,
        globalRank,
        registrationDate,
        age,
        premiumExpiresAt,
        currentLeagueName,
        lastTestResults,
      ];
}

class ProfileTestResult extends Equatable {
  final String id;
  final int mode;
  final int totalScore;
  final String? subjectName;
  final String finishedAt;

  const ProfileTestResult({
    required this.id,
    required this.mode,
    required this.totalScore,
    required this.subjectName,
    required this.finishedAt,
  });

  @override
  List<Object?> get props => [id, mode, totalScore, subjectName, finishedAt];
}
